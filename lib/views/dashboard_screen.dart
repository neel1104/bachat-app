import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/visualisations.dart';
import '../models/favourite.dart';
import '../viewmodels/ai_chat_viewmodel.dart';
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
            child: fvm.favourites.isEmpty
                ? Center( // handling empty state
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info),
                      Text(
                        "Head over to the AI chat to add widgets here!",
                        softWrap: true,
                      )
                    ],
                  ))
                : ListView(
                    children: fvm.favourites
                        .map((fav) => FavouriteListItem(favourite: fav))
                        .toList(),
                  )),
        ElevatedButton.icon(
          onPressed: () => _startChat(context, fvm),
          icon: Icon(Icons.rocket_launch),
          label: Text("Start chat with AI"),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  void _startChat(BuildContext context, FavouriteViewModel fvm) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => MultiProvider(providers: [
        ChangeNotifierProvider(create: (_) => AIChatViewmodel()),
        ChangeNotifierProvider(create: (_) => FavouriteViewModel())
      ], child: AIChatScreen()),
    ));
    fvm.refresh();
  }
}

class FavouriteListItem extends StatelessWidget {
  final Favourite favourite;

  const FavouriteListItem({super.key, required this.favourite});

  @override
  Widget build(BuildContext context) {
    FavouriteViewModel fvm = context.watch<FavouriteViewModel>();
    String? jsonString = fvm.queryResult(favourite);
    if (jsonString == null) {
      return const Center(child: Text('No data available.'));
    }

    return Card(
        child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Text(
              favourite.title.isNotEmpty ? favourite.title : "",
              softWrap: true,
            )),
            IconButton(
              onPressed: () => {_handleRemoveFavourite(context, fvm)},
              icon: Icon(Icons.favorite),
            )
          ],
        ),
        JSONTable(
          jsonString: jsonString,
        )
      ],
    ));
  }

  void _handleRemoveFavourite(
      BuildContext context, FavouriteViewModel fvm) async {
    fvm.removeFavourite(favourite.id!).then((_) => fvm.refresh());
  }
}
