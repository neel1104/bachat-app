import 'package:bachat/models/category.dart';
import 'package:bachat/services/category.dart';
import 'package:bachat/services/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../models/transaction.dart' as mt;

class TransactionFormScreen extends StatefulWidget {
  final mt.Transaction tx;

  const TransactionFormScreen({super.key, required this.tx});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  DateTime? _selectedDateTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Transaction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TransactionForm(
            selectedDateTime: _selectedDateTime,
            onPickDateTime: () => _pickDateTime(context),
            tx: widget.tx,
            onGuess: ()=>{},
            onSave: ()=>{},
          ),
        ),
      ),
    );
  }

  void _handleSave (txn) async {
    TransactionsService().update(txn);
  }

  void _pickDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null && context.mounted) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }
}

class TransactionForm extends StatelessWidget {
  final DateTime? selectedDateTime;
  final VoidCallback onPickDateTime;
  final mt.Transaction tx;
  final VoidCallback onSave;
  final VoidCallback onGuess;

  const TransactionForm({
    super.key,
    required this.selectedDateTime,
    required this.onPickDateTime,
    required this.tx,
    required this.onSave,
    required this.onGuess,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: tx.txDate?.toLocal().toString(),
          readOnly: true,
          decoration: InputDecoration(
            hintText: selectedDateTime == null
                ? 'Transaction time'
                : DateFormat('yyyy-MM-dd – HH:mm').format(selectedDateTime!),
            border: UnderlineInputBorder(),
          ),
          onTap: onPickDateTime,
        ),
        SizedBox(height: 16.0),
        DropdownButtonFormField(
          value: tx.category,
          items: availableCategories(),
          onChanged: (value) {},
          decoration: InputDecoration(
            hintText: 'Select category',
            border: UnderlineInputBorder(),
          ),
        ),
        SizedBox(height: 16.0),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Source Account',
          ),
          initialValue: tx.sourceAccount,
          // readOnly: true,
        ),
        SizedBox(height: 16.0),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Payee',
          ),
          initialValue: tx.payee,
          // readOnly: true,
        ),
        SizedBox(height: 16.0),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Amount',
          ),
          initialValue: tx.amount.toString(),
          readOnly: true,
        ),
        SizedBox(height: 24.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              onPressed: onSave,
              label: Text('Save'),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.auto_awesome),
              onPressed: onGuess,
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
          initialValue: tx.raw,
          style: TextStyle(),
          readOnly: true,
        )
      ],
    );
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
                SizedBox(width: 8.0),
                Text(category.val),
              ],
            ),
          ))
      .toList();
}

class FormField extends StatelessWidget {
  final String title;
  final Widget child;

  const FormField({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
        child,
      ],
    );
  }
}
