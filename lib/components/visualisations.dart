import 'dart:convert';

import 'package:flutter/material.dart';

import '../utils/string.dart';

class JSONTable extends StatelessWidget {
  final String jsonString;

  const JSONTable({super.key, required this.jsonString});

  @override
  Widget build(BuildContext context) {
    List<dynamic> jsonList = jsonDecode(jsonString);

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

    List<TableRow> tableRows = [
      // Header row
      TableRow(
        children: headers.map((key) {
          return Container(
            color: Colors.blueGrey,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              capitalize(key),
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
    return Table(
      // border: TableBorder.all(),
      children: tableRows,
    );
  }
}
