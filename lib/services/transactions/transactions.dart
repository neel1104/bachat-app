import 'dart:async';
import 'package:sqflite/sqflite.dart';

enum TransactionType {
  credit("credit"),
  debit("debit");

  final String value;
  const TransactionType(this.value);

  factory TransactionType.fromValue(String value) {
    return TransactionType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid TransactionType value: $value'),
    );
  }
}

class TransactionModel {
  final int? id; // Primary key
  final String payee;
  final double amount;
  final String date; // ISO 8601 format (YYYY-MM-DD)
  final TransactionType type;
  final String category;
  final String sourceAccount;
  final int refID;

  TransactionModel({
    this.id,
    required this.payee,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    required this.sourceAccount,
    required this.refID,
  });

  // Convert a Transaction object to a Map for SQLite
  Map<String, dynamic> toMap() => {
    'id': id,
    'payee': payee,
    'amount': amount,
    'date': date,
    'type': type.value,
    'category': category,
    'source_account': sourceAccount,
    'ref_id': refID,
  };

  // Create a Transaction object from a Map
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      payee: map['payee'] as String,
      amount: (map['amount'] is int ? (map['amount'] as int).toDouble() : map['amount']) as double,
      date: map['date'] as String,
      type: TransactionType.fromValue(map['type'] as String),
      category: map['category'] as String? ?? "Unknown",
      sourceAccount: map['source_account'] as String,
      refID: map['ref_id'] as int? ?? 0,
    );
  }
}

extension TransactionModelCopyWith on TransactionModel {
  TransactionModel copyWith({int? id, TransactionType? type, String? category}) {
    return TransactionModel(
      id: id ?? this.id,
      payee: payee,
      amount: amount,
      date: date,
      type: type ?? this.type,
      category: category ?? this.category,
      sourceAccount: sourceAccount,
      refID: refID,
    );
  }
}


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
      version: 4,
      onCreate: (db, version) async {
        await _createOrUpgradeDatabase(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _createOrUpgradeDatabase(db);
      },
    );
  }

  Future<void> _createOrUpgradeDatabase(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableName');
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payee TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        source_account TEXT NOT NULL,
        $refIDColName INTEGER NOT NULL UNIQUE
      )
    ''');
  }
  
  Future<TransactionModel> insert(TransactionModel txn) async {
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

  Future<TransactionModel> update(TransactionModel txn) async {
    final db = await database;
    final txnMap = txn.toMap();
    try {
      final id = await db.update(
        tableName,
        txnMap,
      );
      return txn.copyWith(id: id);
    } catch (e) {
      throw Exception('Failed to insert transaction: $e');
    }
  }
  
  Future<List<TransactionModel>> findAll({int? limit}) async {
    limit ??= 100;
    final db = await database;
    try {
      final result = await db.query(tableName, orderBy: "date DESC");
      return result.map((row) => TransactionModel.fromMap(row)).toList();
    } catch (e) {
      throw Exception('Failed to query transactions: $e');
    }
  }

  Future<TransactionModel?> findByRefID(int refID) async {
    final db = await database;
    try {
      final result = await db.query(
        tableName,
        where: "$refIDColName = ?",
        whereArgs: [refID],
        limit: 1,
      );
      return result.isNotEmpty ? TransactionModel.fromMap(result.first) : null;
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
