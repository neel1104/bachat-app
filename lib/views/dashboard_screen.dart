import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/ai_chat_viewmodel.dart';
import '../viewmodels/favourite_viewmodel.dart';
import 'ai_chat_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _startChat(context),
        label: Text("Start Chat"),
      ),
    );
  }

  void _startChat(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => FavouriteViewModel(),
          ),
          ChangeNotifierProvider(
            create: (_) => AIChatViewmodel(),
          )
        ],
        child: AIChatScreen(),
      ),
    ));
  }
}
