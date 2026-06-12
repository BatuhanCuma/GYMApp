import 'package:flutter/foundation.dart' hide Category;

import '../models/category.dart';
import '../repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repo;
  List<Category> _categories = [];

  CategoryProvider({CategoryRepository? repo})
      : _repo = repo ?? CategoryRepository();

  List<Category> get categories => List.unmodifiable(_categories);

  Future<void> load() async {
    try {
      _categories = await _repo.getAll();
    } catch (e) {
      debugPrint('[CategoryProvider] load error: $e');
      _categories = [];
    }
    notifyListeners();
  }

  Future<void> add(String name) async {
    await _repo.insert(Category(name: name));
    await load();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await load();
  }
}
