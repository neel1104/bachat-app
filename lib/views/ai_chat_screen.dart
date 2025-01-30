import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/llm/llm.dart';
import '../viewmodels/ai_chat_viewmodel.dart';
import '../viewmodels/favourite_viewmodel.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  _AIChatScreenState createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AIChatViewmodel cvm = context.watch<AIChatViewmodel>();
    FavouriteViewModel fvm = context.watch<FavouriteViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.account_balance_wallet, color: Colors.white),
            ),
            SizedBox(width: 10),
            Text('Finance Bot', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Visibility(
            visible: cvm.isLoading || fvm.isLoading,
            child: LinearProgressIndicator(),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: cvm.messages.length,
              itemBuilder: (context, index) {
                bool isUserMessage = cvm.messages[index].isUserMessage;
                if (isUserMessage)
                  return UserMessageListItem(msg: cvm.messages[index]);
                return AIMessageListItem(
                  msg: cvm.messages[index],
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    enabled: !(cvm.isLoading || fvm.isLoading),
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      if (_messageController.text.trim().isNotEmpty) {
                        cvm.sendMessage(_messageController.text.trim());
                        _messageController.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AIMessageListItem extends StatelessWidget {
  final Message msg;

  const AIMessageListItem({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    AIChatViewmodel cvm = context.watch<AIChatViewmodel>();
    FavouriteViewModel fvm = context.watch<FavouriteViewModel>();

    String? queryRes = cvm.runQuery(msg);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.all(10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: queryRes != null
            ? Column(
                children: [
                  Text(
                    queryRes ?? msg.content,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  Divider(),
                  Text(
                    msg.content,
                    style: TextStyle(color: Colors.black, fontSize: 10),
                  ),
                  ElevatedButton.icon(
                      onPressed: () => _handleAddToFavourites(fvm, context),
                      icon: Icon(Icons.favorite),
                      label: Text("Add to dashboard"))
                ],
              )
            : Text(
                queryRes ?? msg.content,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
      ),
    );
  }

  void _handleAddToFavourites(
      FavouriteViewModel fvm, BuildContext context) async {
    try {
      await fvm.addFavourite(msg.content);
      if (context.mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Added to favourites.")));
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("failed to add to favourites.")));
    }
  }
}

class UserMessageListItem extends StatelessWidget {
  const UserMessageListItem({super.key, required this.msg});

  final Message msg;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.all(10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg.content,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
