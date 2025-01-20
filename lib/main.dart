import 'package:flutter/material.dart';

import 'screens/tab_raw_messages.dart';
import 'screens/tab_transactions.dart';
import 'screens/tab_home.dart';
import 'screens/scaffold.dart';


void main() {
  runApp(const BachatApp());
}

class BachatApp extends StatelessWidget {
  const BachatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AppContainer(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bachat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.auto_awesome)),
                Tab(icon: Icon(Icons.receipt)),
                Tab(icon: Icon(Icons.sms)),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              HomeTab(),
              TransactionsTab(),
              RawMessagesTab(),
            ],
          ),

        ),
      ),

      // home: const RawMessagesTab(title: 'Bachat'),
    );
  }
}




