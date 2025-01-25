import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../models/transaction.dart';
import '../services/llm/llm.dart';
import '../services/transaction.dart';

class TransactionListViewModel extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  int isRefreshedTransaction = 0;
  int firstTxLoadLimit = 100;
  final SmsQuery _query = SmsQuery();
  final String smsQuerySenderFilter = 'UOB';
  final int smsQueryLimit = 100;

  List<Transaction> get transactions => _transactions;

  bool get isLoading => _isLoading;

  bool get isSyncing => _isSyncing;

  TransactionListViewModel() {
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();
    _transactions = await TransactionService().fetchAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshTransactionByID(int id) async {
    final index = _transactions.indexWhere((tx) => tx.id == id);
    if (index == -1) return;
    Transaction? tx = await TransactionService().findByID(id);
    if (tx == null) return;
    _transactions[index] = tx;
    notifyListeners();
  }

  Map<String, List<Transaction>> groupedTransactions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastWeek = today.subtract(const Duration(days: 7));

    final Map<String, List<Transaction>> grouped = {
      "Today": [],
      "Yesterday": [],
      "Previous 7 Days": [],
    };

    final Map<String, List<Transaction>> olderByMonth = {};

    for (var tx in transactions) {
      final txDate = tx.txDate?.toLocal();
      if (txDate != null) {
        if (txDate.isAfter(today)) {
          grouped["Today"]?.add(tx);
        } else if (txDate.isAfter(yesterday)) {
          grouped["Yesterday"]?.add(tx);
        } else if (txDate.isAfter(lastWeek)) {
          grouped["Previous 7 Days"]?.add(tx);
        } else {
          final monthKey = DateFormat('MMMM yyyy').format(txDate);
          olderByMonth[monthKey] ??= [];
          olderByMonth[monthKey]?.add(tx);
        }
      }
    }

    // Combine grouped categories with olderByMonth
    return {...grouped, ...olderByMonth};
  }

  // sync helpers start
  void syncTransactions() async {
    _isSyncing = true;
    List<SmsMessage> messages = await _fetchDeviceMessages();

    // find messages which are not yet transactions.
    int messagesToSync = 0;
    List<Future<Transaction>> futures = [];
    for (SmsMessage sms in messages) {
      Transaction? txn = await TransactionService().findByRefID(sms.id!);
      if (txn == null) {
        messagesToSync++;
        futures.add(_saveSmsToTransaction(sms));
      }
    }
    await Future.wait(futures);
    _isSyncing = false;
  }

  Future<Transaction> _guessFieldsFromRawTx(Transaction tx) async {
    var llmTx = await LLMService.smsToListTransactionModel(tx.raw);
    // modify tx object
    return tx.copyWith(
      payee: llmTx.payee,
      amount: llmTx.amount,
      type: llmTx.type,
      category: llmTx.category,
      sourceAccount: llmTx.sourceAccount,
    );
  }

  Future<Transaction> _saveSmsToTransaction(SmsMessage sms) async {
    // first save raw transaction to db
    Transaction tx = await TransactionService().insert(Transaction(
        refId: sms.id!, refSource: "sms", raw: sms.body!, txDate: sms.date));
    // ensure we're not passing empty string to llm
    assert(sms.body != null && sms.body != "");
    // guess
    tx = await _guessFieldsFromRawTx(tx);
    // save
    await TransactionService().update(tx);
    // update state
    transactions.add(tx);
    notifyListeners();
    return tx;
  }

  Future<List<SmsMessage>> _fetchDeviceMessages() async {
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
// sync helpers end
}
