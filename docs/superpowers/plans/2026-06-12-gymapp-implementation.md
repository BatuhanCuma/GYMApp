# GYMApp Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Flutter iOS uygulaması — egzersiz adı + kilo takibi, local SQLite, dark theme, minimal liste UI.

**Architecture:** UI (HomeScreen) → ChangeNotifier (ExerciseProvider) → Repository (ExerciseRepository) → sqflite. Tek ekran, tüm CRUD işlemleri bottom sheet ve dialog üzerinden.

**Tech Stack:** Flutter/Dart, sqflite ^2.3.3, path ^1.9.0, provider ^6.1.2, sqflite_common_ffi (test)

---

## File Map

| Dosya | Sorumluluk |
|-------|-----------|
| `pubspec.yaml` | Bağımlılıklar |
| `lib/main.dart` | App entry, dark theme, Provider setup |
| `lib/models/exercise.dart` | Exercise data class, toMap/fromMap |
| `lib/repositories/exercise_repository.dart` | sqflite CRUD + DB init |
| `lib/providers/exercise_provider.dart` | ChangeNotifier, liste state |
| `lib/screens/home_screen.dart` | Tüm UI: list, FAB, bottom sheet, dialog |
| `test/models/exercise_test.dart` | Model unit testleri |
| `test/repositories/exercise_repository_test.dart` | Repository unit testleri (sqflite_ffi) |
| `test/screens/home_screen_test.dart` | Widget testleri |

---

## Task 1: Flutter Projesi Oluştur

**Files:**
- Create: `pubspec.yaml` (modify)
- Create: Flutter project scaffold

- [ ] **Step 1: Flutter projesini oluştur**

```powershell
cd C:\Projects\GYMApp
flutter create . --org com.batuhancuma --project-name gymapp --platforms ios,android
```

Expected output: `All done! ...`

- [ ] **Step 2: pubspec.yaml bağımlılıklarını güncelle**

`pubspec.yaml` dosyasındaki `dependencies` ve `dev_dependencies` bloklarını şununla değiştir:

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.3
  path: ^1.9.0
  provider: ^6.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  sqflite_common_ffi: ^2.3.4
  flutter_lints: ^4.0.0
```

- [ ] **Step 3: Bağımlılıkları indir**

```powershell
flutter pub get
```

Expected: `Got dependencies!`

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: flutter project scaffold + dependencies"
```

---

## Task 2: Exercise Model

**Files:**
- Create: `lib/models/exercise.dart`
- Create: `test/models/exercise_test.dart`

- [ ] **Step 1: Failing test yaz**

`test/models/exercise_test.dart`:

```dart
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
```

- [ ] **Step 2: Test'i çalıştır, fail ettiğini doğrula**

```powershell
flutter test test/models/exercise_test.dart
```

Expected: FAIL — `Target of URI doesn't exist`

- [ ] **Step 3: Modeli yaz**

`lib/models/exercise.dart`:

```dart
class Exercise {
  final int? id;
  final String name;
  final double weight;

  Exercise({this.id, required this.name, required this.weight});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'weight': weight,
      };

  factory Exercise.fromMap(Map<String, dynamic> map) => Exercise(
        id: map['id'] as int?,
        name: map['name'] as String,
        weight: (map['weight'] as num).toDouble(),
      );
}
```

- [ ] **Step 4: Testi çalıştır, pass ettiğini doğrula**

```powershell
flutter test test/models/exercise_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/models/exercise.dart test/models/exercise_test.dart
git commit -m "feat: Exercise model with toMap/fromMap"
```

---

## Task 3: Exercise Repository

**Files:**
- Create: `lib/repositories/exercise_repository.dart`
- Create: `test/repositories/exercise_repository_test.dart`

- [ ] **Step 1: Failing test yaz**

`test/repositories/exercise_repository_test.dart`:

```dart
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
```

- [ ] **Step 2: Test'i çalıştır, fail ettiğini doğrula**

```powershell
flutter test test/repositories/exercise_repository_test.dart
```

Expected: FAIL — `Target of URI doesn't exist`

- [ ] **Step 3: Repository'yi yaz**

`lib/repositories/exercise_repository.dart`:

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/exercise.dart';

class ExerciseRepository {
  final bool inMemory;
  Database? _db;

  ExerciseRepository({this.inMemory = false});

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = inMemory ? inMemoryDatabasePath : join(await getDatabasesPath(), 'gymapp.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) => db.execute(
        'CREATE TABLE exercises (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, weight REAL NOT NULL)',
      ),
    );
  }

  Future<List<Exercise>> getAll() async {
    final db = await database;
    final maps = await db.query('exercises', orderBy: 'id DESC');
    return maps.map(Exercise.fromMap).toList();
  }

  Future<int> insert(Exercise exercise) async {
    final db = await database;
    final map = exercise.toMap()..remove('id');
    return db.insert('exercises', map);
  }

  Future<void> update(Exercise exercise) async {
    final db = await database;
    await db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await database;
    await db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
```

- [ ] **Step 4: Testi çalıştır, pass ettiğini doğrula**

```powershell
flutter test test/repositories/exercise_repository_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/repositories/exercise_repository.dart test/repositories/exercise_repository_test.dart
git commit -m "feat: ExerciseRepository with sqflite CRUD"
```

---

## Task 4: Exercise Provider

**Files:**
- Create: `lib/providers/exercise_provider.dart`

- [ ] **Step 1: Provider'ı yaz**

`lib/providers/exercise_provider.dart`:

```dart
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
```

- [ ] **Step 2: Tüm testleri çalıştır**

```powershell
flutter test
```

Expected: `All tests passed!`

- [ ] **Step 3: Commit**

```bash
git add lib/providers/exercise_provider.dart
git commit -m "feat: ExerciseProvider ChangeNotifier"
```

---

## Task 5: main.dart — Dark Theme + Provider Setup

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: main.dart'ı yaz**

`lib/main.dart` içeriğini tamamen şununla değiştir:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/exercise_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ExerciseProvider()..load(),
      child: const GYMApp(),
    ),
  );
}

class GYMApp extends StatelessWidget {
  const GYMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GYM Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFBB86FC),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/main.dart
git commit -m "feat: dark theme + Provider setup in main.dart"
```

---

## Task 6: Home Screen UI

**Files:**
- Create: `lib/screens/home_screen.dart`
- Create: `test/screens/home_screen_test.dart`

- [ ] **Step 1: Failing widget testi yaz**

`test/screens/home_screen_test.dart`:

```dart
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
    final provider = ExerciseProvider(repo: ExerciseRepository(inMemory: true));
    await provider.load();
    await tester.pumpWidget(_buildApp(provider));
    await tester.pump();
    expect(find.text('Henüz egzersiz yok'), findsOneWidget);
  });

  testWidgets('egzersiz eklenince listede görünür', (tester) async {
    final provider = ExerciseProvider(repo: ExerciseRepository(inMemory: true));
    await provider.load();
    await provider.add('Curl', 12.5);
    await tester.pumpWidget(_buildApp(provider));
    await tester.pump();
    expect(find.text('Curl'), findsOneWidget);
    expect(find.text('12.5 kg'), findsOneWidget);
  });

  testWidgets('FAB tıklanınca bottom sheet açılır', (tester) async {
    final provider = ExerciseProvider(repo: ExerciseRepository(inMemory: true));
    await provider.load();
    await tester.pumpWidget(_buildApp(provider));
    await tester.pump();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Egzersiz Ekle'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Test'i çalıştır, fail ettiğini doğrula**

```powershell
flutter test test/screens/home_screen_test.dart
```

Expected: FAIL — `Target of URI doesn't exist`

- [ ] **Step 3: Home Screen'i yaz**

`lib/screens/home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../providers/exercise_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GYM Tracker'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: Consumer<ExerciseProvider>(
        builder: (context, provider, _) {
          if (provider.exercises.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fitness_center, size: 64, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    'Henüz egzersiz yok',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Eklemek için + bas',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.exercises.length,
            itemBuilder: (context, index) {
              return _ExerciseTile(exercise: provider.exercises[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        backgroundColor: const Color(0xFFBB86FC),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddExerciseSheet(),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  const _ExerciseTile({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('exercise_${exercise.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade800,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<ExerciseProvider>().delete(exercise.id!);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            exercise.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${exercise.weight} kg',
              style: const TextStyle(
                color: Color(0xFFBB86FC),
                fontSize: 14,
              ),
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white38),
            onPressed: () => _showEditDialog(context),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: exercise.weight.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          exercise.name,
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Kilo (kg)',
            labelStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFBB86FC)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFBB86FC)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                ctx.read<ExerciseProvider>().updateWeight(exercise, val);
                Navigator.pop(ctx);
              }
            },
            child: const Text(
              'Güncelle',
              style: TextStyle(color: Color(0xFFBB86FC)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddExerciseSheet extends StatefulWidget {
  const _AddExerciseSheet();

  @override
  State<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<_AddExerciseSheet> {
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final weight = double.tryParse(_weightController.text.trim());
    if (name.isEmpty || weight == null || weight <= 0) return;
    context.read<ExerciseProvider>().add(name, weight);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Egzersiz Ekle',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Egzersiz adı',
              labelStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFBB86FC)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFBB86FC)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Kilo (kg)',
              labelStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFBB86FC)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFBB86FC)),
              ),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBB86FC),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Kaydet',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Tüm testleri çalıştır**

```powershell
flutter test
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/screens/home_screen.dart test/screens/home_screen_test.dart
git commit -m "feat: HomeScreen UI — list, FAB, bottom sheet, edit dialog"
```

---

## Task 7: Push & İlk Build

**Files:**
- No new files

- [ ] **Step 1: `flutter analyze` çalıştır**

```powershell
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 2: GitHub'a push et**

```bash
git push origin main
```

- [ ] **Step 3: GitHub Actions'ı izle**

`https://github.com/BatuhanCuma/GYMApp/actions` adresine git. Build tamamlanınca **Artifacts** bölümünden `GYMApp-iOS.zip` indir.

- [ ] **Step 4: IPA'yı çıkar**

`GYMApp-iOS.zip` içinden `GYMApp.ipa` dosyasını çıkar.

---

## Self-Review Notları

- Model, Repository ve Provider arasındaki tip tutarlılığı kontrol edildi: `Exercise`, `int id`, `double weight` tüm dosyalarda aynı.
- `inMemory` parametresi sadece test ortamında kullanılıyor, production'da `false` default.
- `exercises` getter'ı `List.unmodifiable` döndürüyor — UI state'i dışarıdan değiştiremiyor.
- Validation: boş isim ve sıfır/negatif kilo her iki formda da engelleniyor.
