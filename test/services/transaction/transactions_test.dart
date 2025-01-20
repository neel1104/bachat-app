import 'package:test/test.dart';
import 'package:bachat/services/transactions/transactions.dart';


void main() {
  group('TransactionModel', () {
    test('should map json to model successfully', () async {
      final TransactionModel tx = TransactionModel.fromMap({
        "payee": "OMA SPOON",
        "amount": 9,
        "date": "19/12/24",
        "type": "debit",
        "category": "Dining",
        "source_account": "UOB Card ending 5267",
      });
      expect(tx.payee, equals("OMA SPOON"));
      expect(tx.amount, equals(9.0));
      expect(tx.date, equals("19/12/24"));
      expect(tx.type, equals(TransactionType.debit));
      expect(tx.category, equals("Dining"));
      expect(tx.sourceAccount, equals("UOB Card ending 5267"));
    });
  });
}
