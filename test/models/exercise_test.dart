import 'package:flutter_test/flutter_test.dart';
import 'package:gymapp/models/exercise.dart';

void main() {
  group('Exercise', () {
    test('toMap çıktısı doğru', () {
      final e = Exercise(id: 1, name: 'Curl', weight: 12.5, categoryId: 1);
      expect(e.toMap(), {
        'id': 1,
        'name': 'Curl',
        'weight': 12.5,
        'category_id': 1,
        'is_done': 0,
      });
    });

    test('fromMap ile oluşturma doğru', () {
      final map = {
        'id': 2,
        'name': 'Bench Press',
        'weight': 60.0,
        'category_id': 3,
        'is_done': 1,
      };
      final e = Exercise.fromMap(map);
      expect(e.id, 2);
      expect(e.name, 'Bench Press');
      expect(e.weight, 60.0);
      expect(e.categoryId, 3);
      expect(e.isDone, isTrue);
    });

    test('id null olabilir', () {
      final e = Exercise(name: 'Squat', weight: 80.0, categoryId: 1);
      expect(e.id, isNull);
    });

    test('copyWith çalışır', () {
      final e = Exercise(id: 1, name: 'Curl', weight: 10.0, categoryId: 1);
      final updated = e.copyWith(weight: 15.0, isDone: true);
      expect(updated.weight, 15.0);
      expect(updated.isDone, isTrue);
      expect(updated.name, 'Curl');
    });
  });
}
