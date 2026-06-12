import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/exercise.dart';

class ExerciseRepository {
  final bool inMemory;
  Database? _db;

  ExerciseRepository({this.inMemory = false});

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = inMemory ? inMemoryDatabasePath : join(await getDatabasesPath(), 'gymapp.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) => db.execute(
        'CREATE TABLE exercises (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, weight REAL NOT NULL)',
      ),
    );
  }

  Future<List<Exercise>> getAll() async {
    final db = await database;
    final maps = await db.query('exercises', orderBy: 'id DESC');
    return maps.map(Exercise.fromMap).toList();
  }

  Future<int> insert(Exercise exercise) async {
    final db = await database;
    final map = exercise.toMap()..remove('id');
    return db.insert('exercises', map);
  }

  Future<void> update(Exercise exercise) async {
    final db = await database;
    await db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await database;
    await db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
