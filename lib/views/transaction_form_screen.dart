import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../components/transaction_form.dart';
import '../viewmodels/transaction_form_viewmodel.dart';
import '../viewmodels/transaction_list_viewmodel.dart';

class TransactionFormScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final Transaction tx;

  TransactionFormScreen({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TransactionFormViewModel()),
          ChangeNotifierProvider(create: (_) => TransactionListViewModel())
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Edit Transaction'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: TransactionForm(
                  tx: tx,
                ),
              ),
            ),
          ),
        ));
  }
}
