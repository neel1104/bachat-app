class Transaction {
  final int? id;
  final String? payee;
  final double? amount;
  final DateTime? txDate;
  final String? type;
  final String? category;
  final String? sourceAccount;
  final bool isIncluded;
  final int refId;
  final String? refSource;
  final String raw;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Transaction({
    required this.txDate,
    required this.refId,
    required this.refSource,
    required this.raw,
    this.id,
    this.payee = "",
    this.amount = 0,
    this.type = "debit",
    this.category = "others",
    this.sourceAccount = "",
    this.isIncluded = true,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor for creating a Transaction object from a database row (Map<String, dynamic>).
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      payee: map['payee'] as String?,
      amount: map['amount'] as double?,
      txDate: map['tx_date'] != null ? DateTime.parse(map['tx_date'] as String) : null,
      type: map['type'] as String?,
      category: map['category'] as String?,
      sourceAccount: map['source_account'] as String?,
      isIncluded: ((map['is_included'] ?? 1) as int) == 1,
      refId: (map['ref_id'] ?? 0) as int,
      refSource: map['ref_source'] as String?,
      raw: (map['raw'] ?? "") as String,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }

  // Method to convert a Transaction object into a Map<String, dynamic> for database insertion.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'payee': payee,
      'amount': amount,
      'tx_date': txDate?.toIso8601String(),
      'type': type,
      'category': category,
      'source_account': sourceAccount,
      'is_included': isIncluded ? 1 : 0,
      'ref_id': refId,
      'ref_source': refSource,
      'raw': raw,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

extension TransactionCopyWith on Transaction {
  Transaction copyWith({
    int? id,
    String? payee,
    double? amount,
    DateTime? txDate,
    String? type,
    String? category,
    String? sourceAccount,
    bool? isIncluded,
    int? refId,
    String? refSource,
    String? raw,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      payee: payee ?? this.payee,
      amount: amount ?? this.amount,
      txDate: txDate ?? this.txDate,
      type: type ?? this.type,
      category: category ?? this.category,
      sourceAccount: sourceAccount ?? this.sourceAccount,
      isIncluded: isIncluded ?? this.isIncluded,
      refId: refId ?? this.refId,
      refSource: refSource ?? this.refSource,
      raw: raw ?? this.raw,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
