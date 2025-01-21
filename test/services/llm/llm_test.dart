import 'package:test/test.dart';

import 'package:bachat/services/llm/llm.dart';
import 'package:bachat/models/transaction.dart' as mt;


void main() {
  group('LLMService.smsToJSON', () {
    test('should return correct list of transactions', () async {
      const testSms = """
A transactions of SGD 9.80 was made with your UOB Card ending 5267 on 19/12/24 at OMA SPOON. 
If unauthorised, call 24/7 Fraud Hotline now
""";
      final mt.Transaction tx = await LLMService.smsToListTransactionModel(testSms);
      expect(tx.payee, equals("OMA SPOON"));
      expect(tx.amount, equals(9.8));
      // expect(tx.txDate, equals("2024-12-19"));
      expect(tx.type, equals("debit"));
      expect(tx.category, equals("dining_out"));
      expect(tx.sourceAccount, equals("UOB Card ending 5267"));
    });
  });
}
