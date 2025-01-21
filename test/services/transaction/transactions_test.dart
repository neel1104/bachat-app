import 'package:test/test.dart';
import 'package:bachat/models/transaction.dart' as mt;


void main() {
  group('TransactionModel', () {
    test('should map json to model successfully', () async {
      final mt.Transaction tx = mt.Transaction.fromMap({
        "payee": "OMA SPOON",
        "amount": 9,
        "date": "19/12/24",
        "type": "debit",
        "category": "Dining",
        "source_account": "UOB Card ending 5267",
      });
      expect(tx.payee, equals("OMA SPOON"));
      expect(tx.amount, equals(9.0));
      expect(tx.txDate, equals("19/12/24"));
      expect(tx.type, equals("debit"));
      expect(tx.category, equals("Dining"));
      expect(tx.sourceAccount, equals("UOB Card ending 5267"));
    });
  });
}
