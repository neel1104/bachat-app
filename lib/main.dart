import 'package:flutter/material.dart';

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



