import 'package:bachat/screens/tx_detail.dart';
import 'package:bachat/services/category.dart';
import 'package:bachat/services/llm/llm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';


import '../models/transaction.dart' as mt;
import '../services/transaction.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key});

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  List<mt.Transaction> _txs = [];
  int firstTxLoadLimit = 100;
  final SmsQuery _query = SmsQuery();
  final String smsQuerySenderFilter = 'UOB';
  final int smsQueryLimit = 100;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10.0),
        child: CustomScrollView(
          slivers: [
            SearchPlaceholder(),
            _SyncPlaceholder(
                onPressed: () => _onSyncPressed(context), limit: smsQueryLimit),
            _txs.isNotEmpty
                ? _TransactionsListView(transactions: _txs)
                : SliverToBoxAdapter(
                    child: SizedBox(
                      child: Center(
                        child: Text(
                          'No transactions found :(',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
          ],
        ));
  }

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
    if (!await _ensurePermission()) {
      return null;
    }
    if (!context.mounted) {
      return null;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("loading messages"),
    ));

    List<SmsMessage> messages = await _loadMessages();

    // find messages which are not yet transactions.
    int messagesToSync = 0;
    for (SmsMessage sms in messages) {
      mt.Transaction? txn = await TransactionsService().findByRefID(sms.id!);
      if (txn == null) {
        messagesToSync++;
        _saveSmsToTransaction(sms);
      }
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "loaded ${messages.length} messages, missing $messagesToSync transactions")));
    }
  }

  Future<void> _saveSmsToTransaction(SmsMessage sms) async {
    // first save to db
    mt.Transaction tx = await TransactionsService().insert(mt.Transaction(
        refId: sms.id!, refSource: "sms", raw: sms.body!, txDate: sms.date));
    // ensure we're not passing empty string to llm
    assert(sms.body != null && sms.body != "");
    var llmTx = await LLMService.smsToListTransactionModel(sms.body!);
    // modify tx object
    tx = tx.copyWith(
        payee: llmTx.payee,
        amount: llmTx.amount,
        type: llmTx.type,
        category: llmTx.category,
        sourceAccount: llmTx.sourceAccount,
    );
    await TransactionsService().update(tx);
    setState(() {
      _txs.add(tx);
    });
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
  final int limit;

  const _SyncPlaceholder(
      {super.key, required this.onPressed, required this.limit});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
        child: SizedBox(
            child: ElevatedButton.icon(
                onPressed: onPressed,
                icon: Icon(Icons.sync),
                label: Text("Sync last $limit messages."))));
  }
}

class _TransactionsListView extends StatelessWidget {
  const _TransactionsListView({
    required this.transactions,
  });

  final List<mt.Transaction> transactions;

  void openTransaction(BuildContext context, mt.Transaction tx) {
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
        mt.Transaction tx = transactions[i];

        return Card(
          child: ListTile(
            tileColor: tx.amount == 0 ? Colors.yellow : null,
            leading: categoryIcon(tx.category ?? ""),
            trailing: Text(tx.amount.toString()),
            title: Text(tx.category ?? ""),
            subtitle: Text("${tx.txDate?.toLocal()} @ ${tx.payee}"),
            onTap: () => openTransaction(context, tx),
            // isThreeLine: true,
          ),
        );
      },
    );
  }
}

Icon categoryIcon(String category) {
  return Icon(CategoryService().findByVal(category).iconData);
}
