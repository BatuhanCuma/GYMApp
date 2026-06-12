import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import '../repositories/exercise_repository.dart';

class ExerciseProvider extends ChangeNotifier {
  final ExerciseRepository _repo;
  List<Exercise> _exercises = [];

  ExerciseProvider({ExerciseRepository? repo})
      : _repo = repo ?? ExerciseRepository();

  List<Exercise> get exercises => List.unmodifiable(_exercises);

  List<Exercise> forCategory(int categoryId) =>
      _exercises.where((e) => e.categoryId == categoryId).toList();

  Future<void> load() async {
    try {
      _exercises = await _repo.getAll();
    } catch (e) {
      debugPrint('[ExerciseProvider] load error: $e');
      _exercises = [];
    }
    notifyListeners();
  }

  Future<void> add(String name, double weight, int categoryId) async {
    await _repo.insert(Exercise(name: name, weight: weight, categoryId: categoryId));
    await load();
  }

  Future<void> updateWeight(Exercise exercise, double newWeight) async {
    await _repo.update(exercise.copyWith(weight: newWeight));
    await load();
  }

  Future<void> toggleDone(Exercise exercise) async {
    await _repo.update(exercise.copyWith(isDone: !exercise.isDone));
    await load();
  }

  Future<void> resetCategory(int categoryId) async {
    await _repo.resetDoneForCategory(categoryId);
    await load();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await load();
  }
}
