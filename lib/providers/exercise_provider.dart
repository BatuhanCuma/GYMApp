import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import '../repositories/exercise_repository.dart';

class ExerciseProvider extends ChangeNotifier {
  final ExerciseRepository _repo;
  List<Exercise> _exercises = [];

  ExerciseProvider({ExerciseRepository? repo})
      : _repo = repo ?? ExerciseRepository();

  List<Exercise> get exercises => List.unmodifiable(_exercises);

  Future<void> load() async {
    _exercises = await _repo.getAll();
    notifyListeners();
  }

  Future<void> add(String name, double weight) async {
    await _repo.insert(Exercise(name: name, weight: weight));
    await load();
  }

  Future<void> updateWeight(Exercise exercise, double newWeight) async {
    await _repo.update(Exercise(id: exercise.id, name: exercise.name, weight: newWeight));
    await load();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await load();
  }
}
