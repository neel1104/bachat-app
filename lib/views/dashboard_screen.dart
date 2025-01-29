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
      builder: (context) => MultiProvider(providers: [
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
    if (jsonString == null)
      return Center(child: Text("query result not found"));
    // Decode JSON string into a List of Maps
    List<dynamic> jsonList = json.decode(jsonString);

    if (jsonList.isEmpty) {
      return const Center(child: Text('No data available.'));
    }

    // Get all unique keys from the JSON objects
    Set<String> keys = {};
    for (var item in jsonList) {
      keys.addAll(item.keys);
    }

    // Convert the Set of keys to a List for consistent ordering
    List<String> headers = keys.toList();

    // Build the Table rows
    List<TableRow> tableRows = [
      // Header row
      TableRow(
        children: headers.map((key) {
          return Container(
            color: Colors.blueGrey,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              capitalizeHeader(key),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        }).toList(),
      ),
      // Data rows
      ...jsonList.map((item) {
        return TableRow(
          children: headers.map((key) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                item[key]?.toString() ?? '-', // Handle missing keys gracefully
              ),
            );
          }).toList(),
        );
      }).toList()
    ];

    return Card(
        child: Table(
      // border: TableBorder.all(),
      children: tableRows,
    ));
  }
}

String capitalizeHeader(String header) {
  return header
      .replaceAll('_', ' ') // Replace underscores with spaces
      .split(' ') // Split into words
      .map((word) =>
          word[0].toUpperCase() + word.substring(1)) // Capitalize each word
      .join(' '); // Join words back together
}
