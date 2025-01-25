import 'dart:io';

import 'package:bachat/models/transaction.dart' as mt;
import 'package:bachat/services/category.dart';
import 'package:bachat/viewmodels/transaction_list_viewmodel.dart';
import 'package:bachat/views/transaction_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransactionsListView extends StatefulWidget {
  const TransactionsListView({super.key});

  @override
  State<StatefulWidget> createState() => _TransactionsListViewState();
}

class _TransactionsListViewState extends State<TransactionsListView> {
  int refreshedID = 0;

  @override
  Widget build(BuildContext context) {
    final lvm = context.watch<TransactionListViewModel>();
    final groupedTransactions = lvm.groupedTransactions();

    return lvm.isLoading
        ? _LoadingState()
        : lvm.transactions.isEmpty
            ? _EmptyState()
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final keys = groupedTransactions.keys.toList();
                    final groupKey = keys[index];
                    final groupTransactions =
                        groupedTransactions[groupKey] ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (groupTransactions.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              groupKey,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ...groupTransactions.map(
                          (tx) => Card(
                            child: ListTile(
                              tileColor: tx.id == refreshedID
                                  ? Colors.green
                                  : tx.amount == 0
                                      ? Colors.yellow
                                      : null,
                              leading: Icon(CategoryService()
                                  .findByVal(tx.category ?? "")
                                  .iconData),
                              trailing: Text(tx.amount.toString()),
                              title: Text(tx.category ?? ""),
                              subtitle: Text(
                                  "${DateFormat('MMMM dd').format(tx.txDate!.toLocal())} @ ${tx.payee}"),
                              onTap: () =>
                                  _navigateToEditScreen(context, tx, lvm),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  childCount: groupedTransactions.keys.length,
                ),
              );
  }

  void _navigateToEditScreen(BuildContext context, mt.Transaction transaction,
      TransactionListViewModel lvm) async {
    final updatedTransaction = await Navigator.push<mt.Transaction>(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionFormScreen(tx: transaction),
      ),
    );

    if (updatedTransaction != null) {
      await lvm.refreshTransactionByID(transaction.id!);
      setState(() {
        refreshedID = transaction.id!;
      });
      // _resetRefreshedIDWithDelay();
    }
  }

  void _resetRefreshedIDWithDelay() async {
    sleep(Duration(seconds: 1));
    setState(() {
      refreshedID = 0;
    });
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Center(child: Text("no transactions yet :("));
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Text("loading..."));
}
