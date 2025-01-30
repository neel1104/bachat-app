import 'package:flutter/foundation.dart';

import '../models/favourite.dart';
import '../services/llm/llm.dart';
import '../services/transaction.dart';

class FavouriteViewModel extends ChangeNotifier {
  final FavouriteDatabase _favouriteService = FavouriteDatabase();
  List<Favourite> favourites = [];
  bool isLoading = false;
  Map<String, String> _queryCache = {};

  FavouriteViewModel() {
    _favouriteService.initializeDatabase().then((_) => _loadFavourites());
  }

  void refresh() {
    _favouriteService.initializeDatabase().then((_) => _loadFavourites());
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _favouriteService.closeDatabase();
  }

  Future<void> _loadFavourites() async {
    isLoading = true;
    notifyListeners();

    favourites = await _favouriteService.loadFavourites();
    List<Future> fs = [];
    for (Favourite fav in favourites) {
      fs.add(_buildQueryCache(fav));
    }
    await Future.wait(fs);
    isLoading = false;
    notifyListeners();
  }

  String? queryResult(Favourite fav) {
    return _queryCache[fav.hashKey];
  }

  Future<void> addFavourite(String sql) async {
    isLoading = true;
    notifyListeners();
    Favourite favourite = await _favouriteService
        .addFavourite(Favourite(sql: sql, hashKey: _buildHashKey(sql)));
    Favourite llmFav = await LLMService.prepareFavourite(sql);
    await _favouriteService.updateFavourite(favourite.id!,
        title: llmFav.title, visualisationType: llmFav.visualisationType);
    isLoading = false;
    notifyListeners();
  }

  Future<void> removeFavourite(int id) async {
    await _favouriteService.removeFavourite(id);
  }

  Future<void> _buildQueryCache(Favourite fav) async {
    if (_queryCache[fav.hashKey] == null) {
      String jsonString = await TransactionService().rawQuery(fav.sql);
      _queryCache[fav.hashKey] = jsonString;
    }
  }

  String _buildHashKey(String sql) {
    return shortHash(sql);
  }
}
