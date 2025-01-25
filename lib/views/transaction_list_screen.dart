import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/list_container.dart';
import '../components/search_container.dart';
import '../components/sync_container.dart';
import '../viewmodels/transaction_list_viewmodel.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TransactionListViewModel>();

    return Container(
        padding: const EdgeInsets.all(10.0),
        child: CustomScrollView(
          slivers: [
            SearchPlaceholder(),
            SyncPlaceholder(onPressed: () => {}, limit: 100),
            viewModel.transactions.isNotEmpty
                ? TransactionsListView()
                : _EmptyState(),
          ],
        ));
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        child: Center(
          child: Text(
            'No transactions found :(',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

}

