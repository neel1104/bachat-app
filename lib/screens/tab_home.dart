import 'dart:convert';
import 'dart:math';

import 'package:bachat/services/llm/llm.dart';
import 'package:bachat/services/transactions/transactions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chatUI;

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user');
  final _llmUser = const types.User(id: 'llm');

  @override
  Widget build(BuildContext context) => chatUI.Chat(
    messages: _messages,
    onSendPressed: _handleSendPressed,
    user: _user,
  );

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  List<Message> _mapChatMsgToLLMMsg(){
    List<Message> llmMsgs = [];
    for (types.Message chatMsg in _messages.reversed) {
      if (chatMsg.author.id == "user") {
        llmMsgs.add(Message.human((chatMsg as types.TextMessage).text));
        continue;
      }
      llmMsgs.add(Message.ai((chatMsg as types.TextMessage).text));
    }
    return llmMsgs;
  }

  Future<void> _callLLM() async {
    Message response = await LLMService.chat(_mapChatMsgToLLMMsg());
    print("response from llm: ${response.toMap()}");
    _addMessage(types.TextMessage(
      author: _llmUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: response.content,
    ));
    _callDB(response.content);
  }

  Future<void> _callDB(String query) async {
    assert (query.contains("SELECT"));
    assert(query.contains("FROM"));
    assert(query.contains("transactions"));

    var response = await TransactionsService().rawQuery(query);
    print("response from db: $response");
    _addMessage(types.TextMessage(
      author: _llmUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: response,
    ));
  }

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    _addMessage(textMessage);
    await _callLLM();
  }
}
