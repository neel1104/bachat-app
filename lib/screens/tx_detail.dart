import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:bachat/services/transactions/transactions.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionModel tx;
  const TransactionFormScreen({super.key, required this.tx});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  DateTime? _selectedDateTime;

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
          _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

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
          ),
        ),
      ),
    );
  }
}

class TransactionForm extends StatelessWidget {
  final DateTime? selectedDateTime;
  final VoidCallback onPickDateTime;
  final TransactionModel tx;

  const TransactionForm({
    super.key,
    required this.selectedDateTime,
    required this.onPickDateTime,
    required this.tx,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormField(
          title: 'Timestamp',
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: selectedDateTime == null
                  ? 'Select date and time'
                  : DateFormat('yyyy-MM-dd – HH:mm').format(selectedDateTime!),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onTap: onPickDateTime,
          ),
        ),
        SizedBox(height: 16.0),
        FormField(
          title: 'Category',
          child: DropdownButtonFormField<String>(
            value: tx.category,
            items: availableCategories(),
            onChanged: (value) {},
            decoration: InputDecoration(
              hintText: 'Select category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.0),
        // FormField(
        //   title: 'Source account',
        //   child: DropdownButtonFormField<String>(
        //     items: [
        //       DropdownMenuItem(
        //         child: Text('Account 1'),
        //         value: 'Account 1',
        //       ),
        //       DropdownMenuItem(
        //         child: Text('Account 2'),
        //         value: 'Account 2',
        //       ),
        //     ],
        //     onChanged: (value) {},
        //     decoration: InputDecoration(
        //       hintText: 'Select source account',
        //       border: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(8.0),
        //       ),
        //     ),
        //   ),
        // ),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Source Account',
          ),
          initialValue: tx.sourceAccount,
          readOnly: true,
        ),
        SizedBox(height: 16.0),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Payee',
          ),
          initialValue: tx.payee,
          readOnly: true,
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
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {

            },
            child: Text('Save'),
          ),
        ),
      ],
    );
  }
}

List<DropdownMenuItem<String>> availableCategories () {
  return[
    DropdownMenuItem(
      value: 'Shopping',
      child: Row(
        children: [
          Icon(Icons.shopping_cart),
          SizedBox(width: 8.0),
          Text('Shopping'),
        ],
      ),
    ),
    DropdownMenuItem(
      value: 'Dining',
      child: Row(
        children: [
          Icon(Icons.restaurant),
          SizedBox(width: 8.0),
          Text('Dining'),
        ],
      ),
    ),
    DropdownMenuItem(
      value: 'Transportation',
      child: Row(
        children: [
          Icon(Icons.directions_car),
          SizedBox(width: 8.0),
          Text('Transportation'),
        ],
      ),
    ),
    DropdownMenuItem(
      value: 'Unknown',
      child: Row(
        children: [
          Icon(Icons.question_mark),
          SizedBox(width: 8.0),
          Text('-'),
        ],
      ),
    )
  ];
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
