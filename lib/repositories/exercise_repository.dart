import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import 'database_helper.dart';

class ExerciseRepository {
  final _helper = DatabaseHelper.instance;

  Future<List<Exercise>> getAll() async {
    try {
      final db = await _helper.database;
      final maps = await db.query('exercises', orderBy: 'id ASC');
      return maps.map(Exercise.fromMap).toList();
    } catch (e) {
      debugPrint('[ExerciseRepository] getAll error: $e');
      return [];
    }
  }

  Future<List<Exercise>> getByCategory(int categoryId) async {
    try {
      final db = await _helper.database;
      final maps = await db.query(
        'exercises',
        where: 'category_id = ?',
        whereArgs: [categoryId],
        orderBy: 'id ASC',
      );
      return maps.map(Exercise.fromMap).toList();
    } catch (e) {
      debugPrint('[ExerciseRepository] getByCategory error: $e');
      return [];
    }
  }

  Future<int> insert(Exercise exercise) async {
    try {
      final db = await _helper.database;
      final map = exercise.toMap()..remove('id');
      return await db.insert('exercises', map);
    } catch (e) {
      debugPrint('[ExerciseRepository] insert error: $e');
      return -1;
    }
  }

  Future<void> update(Exercise exercise) async {
    try {
      final db = await _helper.database;
      await db.update(
        'exercises',
        exercise.toMap(),
        where: 'id = ?',
        whereArgs: [exercise.id],
      );
    } catch (e) {
      debugPrint('[ExerciseRepository] update error: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      final db = await _helper.database;
      await db.delete('exercises', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('[ExerciseRepository] delete error: $e');
    }
  }

  Future<void> resetDoneForCategory(int categoryId) async {
    try {
      final db = await _helper.database;
      await db.update(
        'exercises',
        {'is_done': 0},
        where: 'category_id = ?',
        whereArgs: [categoryId],
      );
    } catch (e) {
      debugPrint('[ExerciseRepository] resetDoneForCategory error: $e');
    }
  }
}
