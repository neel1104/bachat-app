import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../viewmodels/ai_chat_viewmodel.dart';
import '../viewmodels/favourite_viewmodel.dart';
import '../viewmodels/transaction_form_viewmodel.dart';
import '../viewmodels/transaction_list_viewmodel.dart';
import 'dashboard_screen.dart';
import 'transaction_list_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentPageIndex = 0;

  _MainLayoutState() {
    _ensurePermissions();
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
          NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
              ),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(
                Icons.pie_chart_outline_outlined,
              ),
              label: 'Budgets'),
          NavigationDestination(
              icon: Icon(
                Icons.receipt_long_outlined,
              ),
              label: 'Transactions'),
          // NavigationDestination(icon: Icon(Icons.flag_outlined, ), label: 'Goals'),
          NavigationDestination(
              icon: Icon(
                Icons.settings_outlined,
              ),
              label: 'Settings'),
        ],
      ),
    );
  }

  Widget getPage(int index) {
    switch (index) {
      case 2:
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => TransactionFormViewModel()),
            ChangeNotifierProvider(create: (_) => TransactionListViewModel())
          ],
          child: TransactionListScreen(),
        );
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavouriteViewModel()),
        ChangeNotifierProvider(create: (_) => AIChatViewmodel())
      ],
      child: DashboardScreen(),
    );
  }

  Widget getTitle(int index) {
    switch (index) {
      case 2:
        return Text('Transactions');
    }
    return Text('Dashboard');
  }

  Future<bool> _ensurePermissions() async {
    var permission = await Permission.sms.status;
    var havePermission = permission.isGranted;
    if (!havePermission) {
      await Permission.sms.request();
    }
    return havePermission;
  }
}
