import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:gymapp/main.dart';
import 'package:gymapp/providers/category_provider.dart';
import 'package:gymapp/providers/exercise_provider.dart';
import 'package:gymapp/repositories/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    DatabaseHelper.resetForTesting();
    late CategoryProvider catProvider;
    late ExerciseProvider exProvider;
    await tester.runAsync(() async {
      catProvider = CategoryProvider();
      exProvider = ExerciseProvider();
      await catProvider.load();
      await exProvider.load();
    });
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CategoryProvider>.value(value: catProvider),
          ChangeNotifierProvider<ExerciseProvider>.value(value: exProvider),
        ],
        child: const GYMApp(),
      ),
    );
    expect(find.text('GYM Tracker'), findsOneWidget);
  });
}
