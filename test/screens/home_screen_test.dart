import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:gymapp/providers/category_provider.dart';
import 'package:gymapp/providers/exercise_provider.dart';
import 'package:gymapp/repositories/database_helper.dart';
import 'package:gymapp/screens/home_screen.dart';

Widget _buildApp(CategoryProvider catProvider, ExerciseProvider exProvider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<CategoryProvider>.value(value: catProvider),
      ChangeNotifierProvider<ExerciseProvider>.value(value: exProvider),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late CategoryProvider catProvider;
  late ExerciseProvider exProvider;

  setUp(() async {
    DatabaseHelper.resetForTesting();
    catProvider = CategoryProvider();
    exProvider = ExerciseProvider();
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
  });

  testWidgets('boş listede empty state gösterilir', (tester) async {
    await tester.runAsync(() async {
      await catProvider.load();
      await exProvider.load();
    });
    await tester.pumpWidget(_buildApp(catProvider, exProvider));
    await tester.pump();
    expect(find.text('Henüz kategori yok'), findsOneWidget);
  });

  testWidgets('kategori eklenince listede görünür', (tester) async {
    await tester.runAsync(() async {
      await catProvider.load();
      await exProvider.load();
      await catProvider.add('Omuz');
    });
    await tester.pumpWidget(_buildApp(catProvider, exProvider));
    await tester.pump();
    expect(find.text('Omuz'), findsOneWidget);
  });

  testWidgets('FAB tıklanınca bottom sheet açılır', (tester) async {
    await tester.runAsync(() async {
      await catProvider.load();
      await exProvider.load();
    });
    await tester.pumpWidget(_buildApp(catProvider, exProvider));
    await tester.pump();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Kategori Ekle'), findsOneWidget);
  });
}
