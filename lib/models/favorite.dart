import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FavouriteModel {
  late Database database;

  Future<void> initializeDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'favourites.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE favourite(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, sql TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<List<Map<String, dynamic>>> loadFavourites() async {
    return await database.query('favourite');
  }

  Future<void> addFavourite(String title, String sql) async {
    await database.insert(
      'favourite',
      {'title': title, 'sql': sql},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavourite(int id) async {
    await database.delete(
      'favourite',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> closeDatabase() async {
    await database.close();
  }
}
