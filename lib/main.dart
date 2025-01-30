import 'package:flutter/material.dart';

import 'views/_main_layout.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bachat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainLayout(),
    );
  }
}
