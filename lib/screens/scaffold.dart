import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'tab_transactions.dart';

class AppContainer extends StatefulWidget {
  const AppContainer({super.key});

  @override
  State<AppContainer> createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  int currentPageIndex = 0;

  Widget getPage(int index) {
    switch(index) {
      case 0:
        return Dashboard();
      case 2:
        return TransactionsTab();
    }
    return Dashboard();
  }

  Widget getTitle(int index) {
    switch(index) {
      case 0:
        return Text('Finance Dashboard');
      case 2:
        return Text('Transactions');
    }
    return Text('Finance Dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: getTitle(currentPageIndex),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {},
          ),
        ],
      ),
      body: getPage(currentPageIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) => {
          setState(() {
            currentPageIndex = index;
          })
        },
        // indicatorColor: Colors.amber,
        destinations: [
          NavigationDestination(icon: Icon(Icons.home_outlined,), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline_outlined,), label: 'Budgets'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined,), label: 'Transactions'),
          // NavigationDestination(icon: Icon(Icons.flag_outlined, ), label: 'Goals'),
          NavigationDestination(icon: Icon(Icons.settings_outlined,), label: 'Settings'),
        ],
      ),
    );
  }
}