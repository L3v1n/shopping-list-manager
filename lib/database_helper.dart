import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shopping_list.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price TEXT NOT NULL
      )
    ''');
  }
  
  // CREATE ITEM
  Future<int> insertItem(Map<String, dynamic> item) async {
    final db = await database;
    return await db.insert('items', {
      'name': item['name'],
      'quantity': item['quantity'],
      'price': item['price'],
    });
  }

  // READ ALL ITEMS
  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await database;
    return await db.query('items', orderBy: 'id');
  }

  // UPDATE ITEM
  Future<int> updateItem(Map<String, dynamic> item) async {
    final db = await database;
    return await db.update(
      'items',
      {
        'name': item['name'],
        'quantity': item['quantity'],
        'price': item['price'],
      },
      where: 'id = ?',
      whereArgs: [item['id']],
    );
  }

  // DELETE ITEM
  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE ALL ITEMS
  Future<int> deleteAllItems() async {
    final db = await database;
    return await db.delete('items');
  }
}