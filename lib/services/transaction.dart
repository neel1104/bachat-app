import 'dart:async';
import 'package:sqflite/sqflite.dart';

import 'package:bachat/models/transaction.dart' as mt;

class TransactionService {
  static final TransactionService _instance = TransactionService._internal();
  static const String tableName = "transactions";
  static const String refIDColName = "ref_id";

  static Database? _database;

  TransactionService._internal();

  factory TransactionService() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/transactions.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {

  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payee TEXT,
        amount REAL,
        tx_date TIMESTAMP,
        type TEXT,
        category TEXT,
        source_account TEXT,
        is_included INTEGER NOT NULL DEFAULT 1,
        $refIDColName INTEGER NOT NULL UNIQUE,
        ref_source TEXT,
        raw TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }
  
  Future<mt.Transaction> insert(mt.Transaction txn) async {
    final db = await database;
    final txnMap = txn.toMap();
    try {
      final id = await db.insert(
        tableName,
        txnMap,
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      return txn.copyWith(id: id);
    } catch (e) {
      throw Exception('Failed to insert transaction: $e');
    }
  }

  Future<mt.Transaction> update(mt.Transaction txn) async {
    final db = await database;
    final txnMap = txn.toMap();
    try {
      final rowsUpdated = await db.update(
        tableName,
        txnMap,
        where: "id = ?",
        whereArgs: [txn.id],
      );
      print("update: rowsUpdated: $rowsUpdated");
      return txn;
    } catch (e) {
      throw Exception('Failed to insert transaction: $e');
    }
  }

  Future<void> updateByID(int id, {
    double? amount,
    String? category,
    String? payee,
    String? sourceAccount
  }) async {
    final db = await database;
    try {
      Map<String, dynamic> fieldsToUpdate = {};
      if (amount != null) fieldsToUpdate['amount'] = amount;
      if (category != null) fieldsToUpdate['category'] = category;
      if (payee != null) fieldsToUpdate['payee'] = payee;
      if (sourceAccount != null) fieldsToUpdate['source_account'] = sourceAccount;
      final rowsUpdated = await db.update(
        tableName,
        fieldsToUpdate,
        where: "id = ?",
        whereArgs: [id],
      );
      print("updateFields: rowsUpdated: $rowsUpdated");
      print("fields updated: $fieldsToUpdate");
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }
  
  Future<List<mt.Transaction>> fetchAll({int? limit}) async {
    limit ??= 100;
    final db = await database;
    try {
      final result = await db.query(tableName, orderBy: "tx_date DESC");
      return result.map((row) => mt.Transaction.fromMap(row)).toList();
    } catch (e) {
      throw Exception('Failed to query transactions: $e');
    }
  }

  Future<mt.Transaction?> findByRefID(int refID) async {
    final db = await database;
    try {
      final result = await db.query(
        tableName,
        where: "$refIDColName = ?",
        whereArgs: [refID],
        limit: 1,
      );
      return result.isNotEmpty ? mt.Transaction.fromMap(result.first) : null;
    } catch (e) {
      throw Exception('Failed to query transaction by refID: $e');
    }
  }

  Future<mt.Transaction?> findByID(int id) async {
    final db = await database;
    try {
      final result = await db.query(
        tableName,
        where: "id = ?",
        whereArgs: [id],
        limit: 1,
      );
      return result.isNotEmpty ? mt.Transaction.fromMap(result.first) : null;
    } catch (e) {
      throw Exception('Failed to query transaction by id: $e');
    }
  }

  Future<String> rawQuery(String rawQuery) async {
    final db = await database;
    try {
      final result = await db.rawQuery(rawQuery);
      return result.toString();
    } catch (e) {
      throw Exception('Failed to execute raw query: $e');
    }
  }

  Future<Map<String, double>> topSpendsByCategory(DateTime endDate, Duration duration) async {
    final db = await database;

    // Calculate the start date
    final startDate = endDate.subtract(duration);

    try {
      final result = await db.query(
        tableName,
        columns: ["SUM(amount) as spends", "category"],
        where: "tx_date BETWEEN ? AND ?",
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
        groupBy: "category",
        orderBy: "spends DESC", // Sort by spends in descending order
        limit: 10,
      );

      // Convert the result to Map<String, double>
      return {
        for (var row in result) row['category'] as String: (row['spends'] as num).toDouble()
      };
    } catch (e) {
      throw Exception('Failed to execute top spends by category: $e');
    }
  }
}
