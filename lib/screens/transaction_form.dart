import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../services/category.dart';
import '../viewmodels/transaction_form_viewmodel.dart';

class TransactionForm extends StatelessWidget {
  final Transaction tx;

  const TransactionForm({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final fvm = context.watch<TransactionFormViewModel>();
    fvm.initTransactionOnce(tx);

    print("TransactionForm.build ${fvm.category}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(visible: fvm.isLoading, child: LinearProgressIndicator()),
        TextFormField(
          initialValue: tx.txDate == null
              ? ''
              : DateFormat('yyyy-MM-dd – HH:mm').format(tx.txDate!),
          readOnly: true,
          decoration: const InputDecoration(
            hintText: 'Transaction time',
            border: UnderlineInputBorder(),
          ),
          // onTap: onPickDateTime,
        ),
        const SizedBox(height: 16.0),
        DropdownButtonFormField<String>(
          value: fvm.category,
          items: availableCategories(),
          onChanged: (value) => {fvm.category = value ?? ""},
          decoration: const InputDecoration(
            hintText: 'Select category',
            border: UnderlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Source Account',
          ),
          initialValue: fvm.sourceAccount,
          onChanged: (value) => {fvm.sourceAccount = value},
          validator: (value) =>
              value?.isEmpty ?? true ? 'Source account is required' : null,
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Payee',
          ),
          initialValue: fvm.payee,
          onChanged: (value) => {fvm.payee = value},
          validator: (value) =>
              value?.isEmpty ?? true ? 'Payee is required' : null,
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Amount',
          ),
          initialValue: fvm.amount.toString(),
          keyboardType: TextInputType.number,
          onChanged: (value) => {fvm.amount = double.parse(value)},
          validator: (value) => (double.tryParse(value ?? '') ?? 0) <= 0
              ? 'Enter a valid amount'
              : null,
        ),
        SizedBox(height: 24.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              onPressed: () => {_handleSave(context, fvm)},
              label: Text('Save'),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.auto_awesome),
              onPressed: fvm.guessTransaction,
              label: Text('Guess'),
            )
          ],
        ),
        SizedBox(height: 16.0),
        TextFormField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Raw',
          ),
          initialValue: fvm.raw,
          style: TextStyle(),
          readOnly: true,
        )
      ],
    );
  }

  _handleSave(BuildContext context, TransactionFormViewModel fvm) async {
    try {
      await fvm.updateTransaction();
      if (context.mounted) Navigator.of(context).pop(tx);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("failed to save due to error: $e"),
        ));
      }
    }
  }
}

List<DropdownMenuItem<String>> availableCategories() {
  List<Category> categories = CategoryService().fetchAll();
  return categories
      .map((category) => DropdownMenuItem(
            value: category.val,
            child: Row(
              children: [
                Icon(category.iconData),
                const SizedBox(width: 8.0),
                Text(category.val),
              ],
            ),
          ))
      .toList();
}
