import 'package:flutter/material.dart';

class SyncPlaceholder extends StatelessWidget {
  final VoidCallback onPressed;
  final int limit;

  const SyncPlaceholder(
      {super.key, required this.onPressed, required this.limit});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
        child: SizedBox(
            child: ElevatedButton.icon(
                onPressed: onPressed,
                icon: Icon(Icons.sync),
                label: Text("Sync last $limit messages."))));
  }
}