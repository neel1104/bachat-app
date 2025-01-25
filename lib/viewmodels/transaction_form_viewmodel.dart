import 'package:bachat/services/llm/llm.dart';
import 'package:flutter/foundation.dart';

import '../models/transaction.dart';
import '../services/transaction.dart';

class TransactionFormViewModel extends ChangeNotifier {
  int? _id;
  bool isLoading = false;
  double? _amount;
  String? _category;
  String? _payee;
  String? _sourceAccount;
  String? _raw;

  String get raw => _raw ?? "";

  double get amount => _amount ?? 0;

  String get category => _category ?? "others";

  String get payee => _payee ?? "";

  String get sourceAccount => _sourceAccount ?? "";

  set amount(double val) => {_amount = val};

  set category(String val) => {_category = val};

  set payee(String val) => {_payee = val};

  set sourceAccount(String val) => {_sourceAccount = val};

  void initTransactionOnce(Transaction tx) {
    if (_id != null) return;
    _id = tx.id;
    _amount = tx.amount;
    _payee = tx.payee;
    _sourceAccount = tx.sourceAccount;
    _category = tx.category;
    _raw = tx.raw;
  }

  Future<void> updateTransaction() async {
    if (_id == null) return;
    _wrapWithLoading(() async {
      await TransactionService().updateByID(_id!,
          amount: _amount,
          payee: payee,
          category: _category,
          sourceAccount: _sourceAccount);
    });
  }

  Future<void> guessTransaction() async {
    if (_raw == null) return;
    if (_raw!.isEmpty) return;
    _wrapWithLoading(() async {
      Transaction llmTx = await LLMService.smsToListTransactionModel(_raw!);
      print("guessTransaction");
      print(llmTx.toMap());
      _amount = llmTx.amount;
      _payee = llmTx.payee;
      _sourceAccount = llmTx.sourceAccount;
      _category = llmTx.category;
    });
  }

  _wrapWithLoading(AsyncCallback fn) async {
    isLoading = true;
    notifyListeners();
    await fn();
    isLoading = false;
    notifyListeners();
  }
}
