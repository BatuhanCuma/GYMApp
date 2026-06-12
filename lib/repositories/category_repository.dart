import 'package:flutter/foundation.dart' hide Category;

import '../models/category.dart';
import 'database_helper.dart';

class CategoryRepository {
  final _helper = DatabaseHelper.instance;

  Future<List<Category>> getAll() async {
    try {
      final db = await _helper.database;
      final maps = await db.query('categories', orderBy: 'id ASC');
      return maps.map(Category.fromMap).toList();
    } catch (e) {
      debugPrint('[CategoryRepository] getAll error: $e');
      return [];
    }
  }

  Future<int> insert(Category category) async {
    try {
      final db = await _helper.database;
      final map = category.toMap()..remove('id');
      return await db.insert('categories', map);
    } catch (e) {
      debugPrint('[CategoryRepository] insert error: $e');
      return -1;
    }
  }

  Future<void> delete(int id) async {
    try {
      final db = await _helper.database;
      await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('[CategoryRepository] delete error: $e');
    }
  }
}
