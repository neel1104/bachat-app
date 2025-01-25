import 'package:bachat/viewmodels/transaction_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SyncPlaceholder extends StatelessWidget {
  final VoidCallback onPressed;
  final int limit;

  const SyncPlaceholder(
      {super.key, required this.onPressed, required this.limit});

  @override
  Widget build(BuildContext context) {
    final lvm = context.watch<TransactionListViewModel>();
    return SliverToBoxAdapter(
        child: SizedBox(
            child: Column(
      children: [
        ElevatedButton.icon(
            onPressed: !lvm.isSyncing ? () => _handleSync(context, lvm) : null,
            icon: Icon(Icons.sync),
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("Sync last $limit messages.")],
            )),
        Visibility(
          visible: lvm.isSyncing,
          child: LinearProgressIndicator(),
        ),
      ],
    )));
  }

  void _handleSync(BuildContext context, TransactionListViewModel lvm) async {
    int count = await lvm.syncTransactions();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("synced $count transaction(s)!")));
  }
}
