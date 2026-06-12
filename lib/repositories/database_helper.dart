import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  Database? _db;
  final bool inMemory;

  DatabaseHelper._({this.inMemory = false});
  static DatabaseHelper get instance => _instance ??= DatabaseHelper._();

  static void resetForTesting() {
    _instance = DatabaseHelper._(inMemory: true);
  }

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    try {
      final path = inMemory
          ? inMemoryDatabasePath
          : join(await getDatabasesPath(), 'gymapp.db');
      return await openDatabase(
        path,
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      debugPrint('[DatabaseHelper] init error: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE categories (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE exercises ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name TEXT NOT NULL, '
      'weight REAL NOT NULL, '
      'category_id INTEGER NOT NULL, '
      'is_done INTEGER NOT NULL DEFAULT 0, '
      'FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE'
      ')',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS exercises');
      await _onCreate(db, newVersion);
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
