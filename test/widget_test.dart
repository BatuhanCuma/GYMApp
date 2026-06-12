import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:gymapp/main.dart';
import 'package:gymapp/providers/exercise_provider.dart';
import 'package:gymapp/repositories/exercise_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    late ExerciseProvider provider;
    await tester.runAsync(() async {
      provider = ExerciseProvider(repo: ExerciseRepository(inMemory: true));
      await provider.load();
    });
    await tester.pumpWidget(
      ChangeNotifierProvider<ExerciseProvider>.value(
        value: provider,
        child: const GYMApp(),
      ),
    );
    expect(find.text('GYM Tracker'), findsOneWidget);
  });
}
