import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:gymapp/models/exercise.dart';
import 'package:gymapp/repositories/exercise_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late ExerciseRepository repo;

  setUp(() async {
    repo = ExerciseRepository(inMemory: true);
  });

  tearDown(() async {
    await repo.close();
  });

  group('ExerciseRepository', () {
    test('boş DB getAll boş liste döner', () async {
      final list = await repo.getAll();
      expect(list, isEmpty);
    });

    test('insert sonrası getAll egzersizi döner', () async {
      await repo.insert(Exercise(name: 'Curl', weight: 10.0));
      final list = await repo.getAll();
      expect(list.length, 1);
      expect(list.first.name, 'Curl');
      expect(list.first.weight, 10.0);
    });

    test('update kiloyu günceller', () async {
      final id = await repo.insert(Exercise(name: 'Curl', weight: 10.0));
      await repo.update(Exercise(id: id, name: 'Curl', weight: 15.0));
      final list = await repo.getAll();
      expect(list.first.weight, 15.0);
    });

    test('delete egzersizi kaldırır', () async {
      final id = await repo.insert(Exercise(name: 'Curl', weight: 10.0));
      await repo.delete(id);
      final list = await repo.getAll();
      expect(list, isEmpty);
    });
  });
}
