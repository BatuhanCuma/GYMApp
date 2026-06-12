import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:gymapp/providers/exercise_provider.dart';
import 'package:gymapp/repositories/exercise_repository.dart';
import 'package:gymapp/screens/home_screen.dart';

Widget _buildApp(ExerciseProvider provider) {
  return ChangeNotifierProvider<ExerciseProvider>.value(
    value: provider,
    child: const MaterialApp(home: HomeScreen()),
  );
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('boş listede empty state gösterilir', (tester) async {
    late ExerciseProvider provider;
    await tester.runAsync(() async {
      provider = ExerciseProvider(repo: ExerciseRepository(inMemory: true));
      await provider.load();
    });
    await tester.pumpWidget(_buildApp(provider));
    await tester.pump();
    expect(find.text('Henüz egzersiz yok'), findsOneWidget);
  });

  testWidgets('egzersiz eklenince listede görünür', (tester) async {
    late ExerciseProvider provider;
    await tester.runAsync(() async {
      provider = ExerciseProvider(repo: ExerciseRepository(inMemory: true));
      await provider.load();
      await provider.add('Curl', 12.5);
    });
    await tester.pumpWidget(_buildApp(provider));
    await tester.pump();
    expect(find.text('Curl'), findsOneWidget);
    expect(find.text('12.5 kg'), findsOneWidget);
  });

  testWidgets('FAB tıklanınca bottom sheet açılır', (tester) async {
    late ExerciseProvider provider;
    await tester.runAsync(() async {
      provider = ExerciseProvider(repo: ExerciseRepository(inMemory: true));
      await provider.load();
    });
    await tester.pumpWidget(_buildApp(provider));
    await tester.pump();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Egzersiz Ekle'), findsOneWidget);
  });
}
