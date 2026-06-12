import 'package:flutter_test/flutter_test.dart';
import 'package:gymapp/models/exercise.dart';

void main() {
  group('Exercise', () {
    test('toMap çıktısı doğru', () {
      final e = Exercise(id: 1, name: 'Curl', weight: 12.5);
      expect(e.toMap(), {'id': 1, 'name': 'Curl', 'weight': 12.5});
    });

    test('fromMap ile oluşturma doğru', () {
      final map = {'id': 2, 'name': 'Bench Press', 'weight': 60.0};
      final e = Exercise.fromMap(map);
      expect(e.id, 2);
      expect(e.name, 'Bench Press');
      expect(e.weight, 60.0);
    });

    test('id null olabilir', () {
      final e = Exercise(name: 'Squat', weight: 80.0);
      expect(e.id, isNull);
    });
  });
}
