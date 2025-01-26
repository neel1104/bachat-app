import 'package:flutter/widgets.dart';

import '../models/favorite.dart';

class FavouriteViewModel extends ChangeNotifier{
  final FavouriteModel _favouriteModel = FavouriteModel();

  FavouriteViewModel(){
    _favouriteModel.initializeDatabase();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _favouriteModel.closeDatabase();
  }

  Future<List<Map<String, dynamic>>> getFavourites() async {
    return await _favouriteModel.loadFavourites();
  }

  Future<void> addFavourite(String title, String sql) async {
    await _favouriteModel.addFavourite(title, sql);
  }

  Future<void> removeFavourite(int id) async {
    await _favouriteModel.removeFavourite(id);
  }
}
