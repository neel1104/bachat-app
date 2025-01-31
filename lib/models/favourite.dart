import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Data class representing a Favourite item
class Favourite {
  final int? id;
  final String title;
  final String sql;
  final int priority;
  final String hashKey;
  final String visualisationType;

  bool get isGroupBy => sql.contains("GROUP BY");

  Favourite({this.id, this.title = "", required this.sql, this.priority = 0, required this.hashKey, this.visualisationType = "table"});

  // Convert a Favourite object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'sql': sql,
      'priority': priority,
      'hashKey': hashKey,
      'visualisationType': visualisationType
    };
  }

  // Create a Favourite object from a map
  factory Favourite.fromMap(Map<String, dynamic> map) {
    return Favourite(
      id: map['id'],
      title: map['title'],
      sql: map['sql'] ?? "",
      priority: map['priority'] ?? 0,
      hashKey: map['hashKey'] ?? "",
    );
  }

  Favourite copyWith({
    int? id,
    String? title,
    String? sql,
    int? priority,
    String? hashKey,
    String? visualisationType,
  }) {
    return Favourite(
      id: id ?? this.id,
      title: title ?? this.title,
      sql: sql ?? this.sql,
      priority: priority ?? this.priority,
      hashKey: hashKey ?? this.hashKey,
      visualisationType: visualisationType ?? this.visualisationType,
    );
  }
}

// Database-related operations
class FavouriteDatabase {
  late Database database;
  final tableName = 'favourite';

  Future<void> initializeDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'favourites.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, sql TEXT, priority INTEGER, hashKey TEXT, visualisationType TEXT)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        db.execute(
          'DROP TABLE IF EXISTS favourite',
        );
        db.execute(
          'CREATE TABLE $tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, sql TEXT, priority INTEGER, hashKey TEXT, visualisationType TEXT)',
        );
      },
      version: 3,
    );
  }

  Future<List<Favourite>> loadFavourites() async {
    final List<Map<String, dynamic>> maps = await database.query('favourite', orderBy: 'priority DESC');
    return List.generate(maps.length, (i) => Favourite.fromMap(maps[i]));
  }

  Future<Favourite> addFavourite(Favourite favourite) async {
    int insertedID = await database.insert(
      tableName,
      favourite.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return favourite.copyWith(id: insertedID);
  }

  Future<void> updateFavourite(int id, {String? title, String? visualisationType}) async {
    // Create a map with only the fields that need to be updated
    Map<String, dynamic> updatedValues = {};
    if (title != null) updatedValues['title'] = title;
    if (visualisationType != null) updatedValues['visualisationType'] = visualisationType;

    // If there are no fields to update, return early
    if (updatedValues.isEmpty) return;

    await database.update(
      tableName, // Table name
      updatedValues, // Values to update
      where: 'id = ?', // Condition
      whereArgs: [id], // Arguments for condition
    );
  }

  Future<void> removeFavourite(int id) async {
    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> closeDatabase() async {
    await database.close();
  }
}
