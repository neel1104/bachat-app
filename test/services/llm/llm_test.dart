import 'package:bachat/models/favourite.dart';
import 'package:bachat/models/transaction.dart' as mt;
import 'package:bachat/services/llm/llm.dart';
import 'package:test/test.dart';

void main() {
  group('LLMService.smsToTransaction', () {
    test('should return correct list of transactions', () async {
      const testSms = """
A transactions of SGD 9.80 was made with your UOB Card ending 5267 on 19/12/24 at OMA SPOON. 
If unauthorised, call 24/7 Fraud Hotline now
""";
      final mt.Transaction tx =
          await LLMService.smsToListTransactionModel(testSms);
      expect(tx.payee, equals("OMA SPOON"));
      expect(tx.amount, equals(9.8));
      // expect(tx.txDate, equals("2024-12-19"));
      expect(tx.type, equals("debit"));
      expect(tx.category, equals("dining_out"));
      expect(tx.sourceAccount, equals("UOB Card ending 5267"));
    });
  });

  group('transactions query and favourite', () {
    test('should return a valid sql from user query', () async {
      var inputMessage =
      Message.human("my top 5 transactions in the current month");
      final Message aiResponse = await LLMService.chat([inputMessage]);
      expect(
          aiResponse.content,
          equals(
              'SELECT payee, amount, tx_date, type, category, source_account, ref_id\n'
                  'FROM transactions\n'
                  'WHERE tx_date >= DATE(\'now\',\'start of month\')\n'
                  'ORDER BY amount DESC\n'
                  'LIMIT 5'));
    });

    test('should guess favourite attributes from sql', () async {
      const testSQL = 'SELECT payee, amount, tx_date, type, category, source_account, ref_id\n'
          'FROM transactions\n'
          'WHERE tx_date >= DATE(\'now\',\'start of month\')\n'
          'ORDER BY amount DESC\n'
          'LIMIT 5';
      final Favourite fav = await LLMService.prepareFavourite(testSQL);
      expect(fav.title, equals("Recent Transactions by Payee"));
      expect(fav.visualisationType, equals("table"));
    });
  });

  group('group by query and favourite', () {
    test('should return a valid sql from user query', () async {
      var inputMessage =
      Message.human("my top 3 categories in the current month");
      final Message aiResponse = await LLMService.chat([inputMessage]);
      expect(
          aiResponse.content,
          equals(
              'SELECT category, SUM(amount) AS total_spent\n'
                  'FROM transactions\n'
                  'WHERE tx_date >= DATE(\'now\',\'start of month\')\n'
                  'GROUP BY category\n'
                  'ORDER BY total_spent DESC\n'
                  'LIMIT 3'));
    });

    test('should guess favourite attributes from sql', () async {
      const testSQL = 'SELECT category, SUM(amount) AS total_spent\n'
          'FROM transactions\n'
          'WHERE tx_date >= DATE(\'now\',\'start of month\')\n'
          'GROUP BY category\n'
          'ORDER BY total_spent DESC\n'
          'LIMIT 3';
      final Favourite fav = await LLMService.prepareFavourite(testSQL);
      expect(fav.title, equals("Monthly Spending Categories"));
      expect(fav.visualisationType, equals("bar"));
    });
  });
}
