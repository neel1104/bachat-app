import 'package:bachat/screens/tab_raw_messages.dart';
import 'package:bachat/services/transactions/transactions.dart';
import 'package:flutter/material.dart';

import '../components/form_fields.dart';
import '../services/llm/llm.dart';

const successSnackBar = SnackBar(
  content: Text('Yay! It worked!'),
);

const failureSnackBar = SnackBar(
  content: Text('Sorry! It didn\'t work!'),
);

class MsgDetailScreen extends StatefulWidget {
  const MsgDetailScreen({super.key, required this.sms});

  final MySmsMessage sms;

  @override
  State<MsgDetailScreen> createState() => _MsgDetailScreenState();
}

class _MsgDetailScreenState extends State<MsgDetailScreen> {
  @override
  void initState() {
    super.initState();
    _tryLoadTxFromDB();
  }

  TransactionModel? tx;
  bool isLoading = true;

  void startLoading() {
    setState(() {
      isLoading = true;
    });
  }

  void finishLoading() {
    setState(() {
      isLoading = false;
    });
  }

  void _tryLoadTxFromDB() async {
    startLoading();
    TransactionModel? dbTx =
        await TransactionsService().findByRefID(widget.sms.id!);
    if (dbTx != null) {
      setState(() {
        tx = dbTx;
      });
    }
    finishLoading();
  }

  void _handleGuessPressed() async {
    startLoading();
    var listTxs = await LLMService.smsToListTransactionModel(widget.sms.body!);
    if (listTxs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(failureSnackBar);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
    setState(() {
      tx = listTxs[0];
      tx = tx?.copyWith(id:widget.sms.id);
    });
    finishLoading();
  }

  void _handleSavePressed() async {
    startLoading();
    var txService = TransactionsService();
    if (tx != null) {
      var newTx = await txService.update(tx!);
      debugPrint("txservice.insert(tx): ${newTx.toMap()}");
      ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
    }
    finishLoading();
  }

  void _handleTypeChanged(dynamic newValue) {
    if (newValue! is String) {
      return;
    }
    setState(() {
      tx = tx?.copyWith(type:TransactionType.fromValue(newValue));
    });
  }

  ValueChanged? _handleStringFieldChanged(String field) {
    return (dynamic newValue) {
      print(
          "_handleStringFieldChanged called for field: $field with value: $newValue");
      setState(() {
        switch (field) {
          case "category":
            setState(() {
              tx = tx?.copyWith(category:newValue);
            });
        }
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
            padding: const EdgeInsets.all(10.0),
            child: isLoading
                ? Center(
                    child: Text("loading..."),
                  )
                : ListView(
                    children: [
                      Visibility(
                        visible: isLoading,
                        child: LinearProgressIndicator(),
                      ),
                      FixedStringField(label: "Date", value: tx?.date ?? ""),
                      FixedStringField(
                        label: "Type",
                        value: tx?.type.value ?? "",
                      ),
                      TextInputField(
                          label: "Category",
                          value: tx?.category ?? "",
                          onChanged: _handleStringFieldChanged("category")),
                      FixedStringField(
                          label: "Source Account",
                          value: tx?.sourceAccount ?? ""),
                      FixedStringField(label: "Payee", value: tx?.payee ?? ""),
                      FixedStringField(
                          label: "Amount", value: tx?.amount.toString() ?? ""),
                      Padding(padding: EdgeInsets.all(20)),
                      Divider(),
                      FixedStringField(label: "Raw", value: widget.sms.body!),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        spacing: 10.0,
                        children: [
                          transactionActionButton(
                              Icon(Icons.auto_awesome),
                              "Guess!",
                              !isLoading ? _handleGuessPressed : null),
                          transactionActionButton(Icon(Icons.save), "Save",
                              !isLoading ? _handleSavePressed : null),
                        ],
                      ),
                    ],
                  )));
  }
}

Widget transactionActionButton(
    Icon icon, String label, VoidCallback? onPressedHandler) {
  return ElevatedButton.icon(
    onPressed: onPressedHandler,
    icon: icon,
    label: Text(label),
  );
}
