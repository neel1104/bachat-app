import 'dart:convert';
import 'dart:io';
import 'package:bachat/services/transactions/transactions.dart';
import 'package:http/http.dart' as http;

import 'prompts.dart';

class Message {
  final String role;
  final String content;

  const Message._({required this.role, required this.content});

  factory Message.human(String message) => Message._(role: "user", content: message);

  factory Message.ai(String message) => Message._(role: "assistant", content: message);

  factory Message.system(String message) => Message._(role: "system", content: message);

  Map<String, String> toMap() => {"role": role, "content": content};
}

class LLMService {
  static const String apiKey = "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";
  static const String modelID = "meta-llama/Llama-3.2-3B-Instruct";
  static const String modelEndpoint =
      "https://api-inference.huggingface.co/models/$modelID/v1/chat/completions";

  static const Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $apiKey",
  };

  static Future<List<TransactionModel>> smsToListTransactionModel(String sms) async {
    final body = {
      "max_tokens": 2048,
      "model": modelID,
      "temperature": 0.5,
      "top_p": 0.7,
      "messages": [
        Message.system(smsToJSONSystemPrompt).toMap(),
        Message.human(sms).toMap(),
      ]
    };

    try {
      final response = await _postRequest(body);

      if (response.statusCode == 200) {
        final assistantResponse = jsonDecode(response.body)['choices']?[0]?['message']?['content'];
        if (assistantResponse == null) {
          throw FormatException("Assistant response missing in the API response");
        }

        final cleanedJsonStr = assistantResponse
            .replaceAll("`", "")
            .replaceAll("json", "")
            .replaceAll("\n", "");

        final transactionsListJson = jsonDecode(cleanedJsonStr) as List<dynamic>;
        return transactionsListJson
            .map((tx) => TransactionModel.fromMap(tx as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException('Request failed with status: ${response.statusCode}.', uri: Uri.parse(modelEndpoint));
      }
    } catch (error) {
      print("Error in smsToListTransactionModel: $error");
      rethrow;
    }
  }

  static Future<Message> chat(List<Message> messages) async {
    messages.insert(0, Message.system(userQuerySystemPrompt));

    final body = {
      "max_tokens": 2048,
      "model": modelID,
      "temperature": 0.5,
      "top_p": 0.7,
      "messages": messages.map((msg) => msg.toMap()).toList(),
    };

    try {
      final response = await _postRequest(body);

      if (response.statusCode == 200) {
        final choices = jsonDecode(response.body)['choices'] as List<dynamic>;
        if (choices.isEmpty || choices[0]['message']['role'] != 'assistant') {
          throw FormatException("Invalid or missing assistant response in the API response");
        }
        return Message.ai(choices[0]['message']['content']);
      } else {
        throw HttpException('Request failed with status: ${response.statusCode}.', uri: Uri.parse(modelEndpoint));
      }
    } catch (error) {
      print("Error in chat: $error");
      rethrow;
    }
  }

  static Future<http.Response> _postRequest(Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse(modelEndpoint),
      headers: headers,
      body: jsonEncode(body),
    );
  }
}
