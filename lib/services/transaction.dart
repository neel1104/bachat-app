import 'dart:async';
import 'package:sqflite/sqflite.dart';

import 'package:bachat/models/transaction.dart' as mt;

class TransactionsService {
  static final TransactionsService _instance = TransactionsService._internal();
  static const String tableName = "transactions";
  static const String refIDColName = "ref_id";

  static Database? _database;

  TransactionsService._internal();

  factory TransactionsService() => _instance;

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
  
  Future<List<mt.Transaction>> findAll({int? limit}) async {
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

  Future<String> rawQuery(String rawQuery) async {
    final db = await database;
    try {
      final result = await db.rawQuery(rawQuery);
      return result.toString();
    } catch (e) {
      throw Exception('Failed to execute raw query: $e');
    }
  }
}
