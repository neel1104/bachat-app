import 'package:flutter/foundation.dart';

import '../services/llm/llm.dart';
import '../services/transaction.dart';

class AIChatViewmodel extends ChangeNotifier {
  List<Message> messages = [];
  bool isLoading = false;
  final Map<String, String> _queryResultsCache = {};

  String? runQuery(Message msg) {
    return _queryResultsCache[_hashKey(msg)];
  }

  void sendMessage(String content) {
    // Add user message
    messages = [
      ...messages,
      Message.human(content),
    ];
    notifyListeners();

    _sendChatHistoryToLLM();
  }

  void _sendChatHistoryToLLM() async {
    isLoading = true;
    notifyListeners();
    try {
      Message llmRes = await LLMService.chat(_history());
      messages = [...messages, llmRes];
      _buildQueryCache(llmRes);
    } catch (e) {
      print("failed to talk with llm due to error: $e");
    }
    isLoading = false;
    notifyListeners();
  }

  void _buildQueryCache(Message msg) async {
    if (msg.role != "assistant") return;
    if (!msg.isSQL) return;
    try {
      String queryRes = await TransactionService().rawQuery(msg.content);
      _queryResultsCache[_hashKey(msg)] = queryRes;
      notifyListeners();
    } catch (e) {
      _queryResultsCache[_hashKey(msg)] =
          "failed to run query in database with error: $e";
      print("failed to run query in database with error: $e");
    }
  }

  List<Message> _history() {
    List<Message> history = [];
    for (Message msg in messages) {
      history.add(msg);
    }
    return history;
  }

  String _hashKey(Message msg) {
    return shortHash(msg.content).toString();
  }
}
