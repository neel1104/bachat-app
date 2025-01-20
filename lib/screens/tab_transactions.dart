import 'package:bachat/screens/tx_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/transactions/transactions.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key});

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  List<TransactionModel> _txs = [];
  int firstTxLoadLimit = 100;
  final SmsQuery _query = SmsQuery();
  final String smsQuerySenderFilter = 'UOB';
  final int smsQueryLimit = 100;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() async {
    var txList = await TransactionsService().findAll(limit: firstTxLoadLimit);
    setState(() {
      _txs = txList;
    });
  }

  void _onSyncPressed(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("loading messages"),
    ));
    List<SmsMessage> messages = await _loadMessages();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("loaded ${messages.length} messages"),
      ));
    }
    // find messages which are not yet transactions.
    int messagesToSync = 0;
    for (SmsMessage message in messages) {
      TransactionModel? txn =
          await TransactionsService().findByRefID(message.id!);
      if (txn == null) {
        messagesToSync++;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("missing $messagesToSync transactions")));
  }

  Future<bool> _ensurePermission() async {
    var permission = await Permission.sms.status;
    var havePermission = permission.isGranted;
    if (!havePermission) {
      await Permission.sms.request();
    }
    return havePermission;
  }

  Future<List<SmsMessage>> _loadMessages() async {
    final messages = await _query.querySms(
      kinds: [
        SmsQueryKind.inbox,
      ],
      address: smsQuerySenderFilter,
      count: smsQueryLimit,
      sort: true,
    );
    return messages;
  }

  void _initMessages() async {
    if (!await _ensurePermission()) {
      return null;
    }
    await _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: _txs.isNotEmpty
          ? CustomScrollView(
              slivers: [
                SearchPlaceholder(),
                _SyncPlaceholder(onPressed: () => _onSyncPressed(context)),
                _TransactionsListView(transactions: _txs),
              ],
            )
          : Center(
              child: Text(
                'No transactions found :(',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}

class SearchPlaceholder extends StatelessWidget {
  const SearchPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
        child: SizedBox(
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter a search term',
        ),
      ),
    ));
  }
}

class _SyncPlaceholder extends StatelessWidget {
  final VoidCallback onPressed;

  const _SyncPlaceholder({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
        child: SizedBox(
            child: ElevatedButton.icon(
                onPressed: onPressed,
                icon: Icon(Icons.sync),
                label: Text("Sync last 100 messages."))));
  }
}

class _TransactionsListView extends StatelessWidget {
  const _TransactionsListView({
    required this.transactions,
  });

  final List<TransactionModel> transactions;

  void openTransaction(BuildContext context, TransactionModel tx) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TransactionFormScreen(
              tx: tx,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: transactions.length,
      itemBuilder: (BuildContext context, int i) {
        TransactionModel tx = transactions[i];

        return Card(
          child: ListTile(
            leading: categoryIcon(tx.category),
            trailing: Text(tx.amount.toString()),
            title: Text(tx.category),
            subtitle: Text("${tx.date} @ ${tx.payee}"),
            onTap: () => openTransaction(context, tx),
            // isThreeLine: true,
          ),
        );
      },
    );
  }
}

Icon categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case "dining":
      return Icon(Icons.dining);
    case "transport":
      return Icon(Icons.directions_car);
  }
  return Icon(Icons.paid);
}
