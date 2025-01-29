import 'dart:convert';

import 'package:bachat/models/favourite.dart';
import 'package:bachat/viewmodels/ai_chat_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/favourite_viewmodel.dart';
import 'ai_chat_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FavouriteViewModel fvm = context.watch<FavouriteViewModel>();

    return Column(
      children: [
        Center(
          child: Visibility(
              visible: fvm.isLoading, child: CircularProgressIndicator()),
        ),
        Expanded(
            child: ListView(
              children: fvm.favourites
                  .map((fav) => FavouriteListItem(favourite: fav))
                  .toList(),
            )),
        ElevatedButton.icon(
          onPressed: () => _startChat(context),
          icon: Icon(Icons.rocket_launch),
          label: Text("Start chat with AI"),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  void _startChat(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          MultiProvider(providers: [
            ChangeNotifierProvider(create: (_) => AIChatViewmodel()),
            ChangeNotifierProvider(create: (_) => FavouriteViewModel())
          ], child: AIChatScreen()),
    ));
  }
}

class FavouriteListItem extends StatelessWidget {
  final Favourite favourite;

  const FavouriteListItem({super.key, required this.favourite});

  @override
  Widget build(BuildContext context) {
    FavouriteViewModel fvm = context.watch<FavouriteViewModel>();
    String? jsonString = fvm.queryResult(favourite);
    if (jsonString == null) return Center(child: Text("blah"));
    // Decode JSON string into a List of Maps
    List<dynamic> jsonList = jsonDecode(jsonString);

    // Build the Table rows from the JSON data
    List<TableRow> tableRows = [
      // Header row
      const TableRow(children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Category',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Total Spent',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]),
      // Data rows
      ...jsonList.map((item) {
        return TableRow(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(item['category']),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(item['total_spent'].toString()),
          ),
        ]);
      })
    ];

    return Card(child: Table(
      // border: TableBorder.all(),
      children: tableRows,
    ));
  }
}
