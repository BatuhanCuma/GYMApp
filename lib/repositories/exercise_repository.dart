import 'package:flutter/foundation.dart';
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
    try {
      final path = inMemory ? inMemoryDatabasePath : join(await getDatabasesPath(), 'gymapp.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, _) => db.execute(
          'CREATE TABLE exercises (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, weight REAL NOT NULL)',
        ),
      );
    } catch (e) {
      debugPrint('[Repository] DB init error: $e');
      rethrow;
    }
  }

  Future<List<Exercise>> getAll() async {
    try {
      final db = await database;
      final maps = await db.query('exercises', orderBy: 'id DESC');
      return maps.map(Exercise.fromMap).toList();
    } catch (e) {
      debugPrint('[Repository] getAll error: $e');
      return [];
    }
  }

  Future<int> insert(Exercise exercise) async {
    try {
      final db = await database;
      final map = exercise.toMap()..remove('id');
      return await db.insert('exercises', map);
    } catch (e) {
      debugPrint('[Repository] insert error: $e');
      return -1;
    }
  }

  Future<void> update(Exercise exercise) async {
    try {
      final db = await database;
      await db.update(
        'exercises',
        exercise.toMap(),
        where: 'id = ?',
        whereArgs: [exercise.id],
      );
    } catch (e) {
      debugPrint('[Repository] update error: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      final db = await database;
      await db.delete('exercises', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('[Repository] delete error: $e');
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
