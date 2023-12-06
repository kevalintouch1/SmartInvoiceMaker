import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'item.dart';

class DatabaseHelper {
  static const String dbName = 'items.db';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), dbName);
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        quantity INTEGER,
        price REAL,
        total REAL
      )
    ''');
  }

  Future<List<Item>> getItems() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('items');

    return List.generate(maps.length, (index) {
      return Item(
        id: maps[index]['id'],
        name: maps[index]['name'],
        quantity: maps[index]['quantity'],
        price: maps[index]['price'],
      );
    });
  }
}