import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('serials.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE serials (
        id INTEGER PRIMARY KEY,
        name TEXT,
        image TEXT,
        status TEXT
      )
    ''');
  }

  Future<void> insertSerial(Map<String, dynamic> serial) async {
    final db = await instance.database;
    await db.insert('serials', serial, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> fetchSerials() async {
    final db = await instance.database;
    return await db.query('serials');
  }

  Future<void> updateStatus(int id, String status) async {
    final db = await instance.database;
    await db.update(
      'serials',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
