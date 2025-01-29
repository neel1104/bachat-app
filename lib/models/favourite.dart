import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Data class representing a Favourite item
class Favourite {
  final int? id;
  final String title;
  final String sql;
  final int priority;
  final String hashKey;

  bool get isGroupBy => sql.contains("GROUP BY");

  Favourite({this.id, required this.title, required this.sql, this.priority = 0, required this.hashKey});

  // Convert a Favourite object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'sql': sql,
      'priority': priority,
      'hashKey': hashKey,
    };
  }

  // Create a Favourite object from a map
  factory Favourite.fromMap(Map<String, dynamic> map) {
    return Favourite(
      id: map['id'],
      title: map['title'],
      sql: map['sql'],
      priority: map['priority'],
      hashKey: map['hashKey'],
    );
  }
}

// Database-related operations
class FavouriteDatabase {
  late Database database;

  Future<void> initializeDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'favourites.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE favourite(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, sql TEXT, priority INTEGER, hashKey TEXT)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        db.execute(
          'DROP TABLE IF EXISTS favourite',
        );
        db.execute(
          'CREATE TABLE favourite(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, sql TEXT, priority INTEGER, hashKey TEXT)',
        );
      },
      version: 2,
    );
  }

  Future<List<Favourite>> loadFavourites() async {
    final List<Map<String, dynamic>> maps = await database.query('favourite', orderBy: 'priority DESC');
    return List.generate(maps.length, (i) => Favourite.fromMap(maps[i]));
  }

  Future<void> addFavourite(Favourite favourite) async {
    await database.insert(
      'favourite',
      favourite.toMap(),
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
