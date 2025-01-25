import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final String title;
  final int current;
  final int total;

  const ProgressBar(
      {super.key,
        required this.title,
        required this.current,
        required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        SizedBox(height: 4.0),
        LinearProgressIndicator(
          value: current / total,
          backgroundColor: Colors.grey[300],
          color: Colors.blue,
        ),
        SizedBox(height: 8.0),
      ],
    );
  }
}