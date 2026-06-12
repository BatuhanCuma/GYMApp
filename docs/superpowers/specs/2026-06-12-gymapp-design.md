# GYMApp Design Spec
**Date:** 2026-06-12

## Overview
Kişisel kullanım gym takip uygulaması. Tek kullanıcı, iOS first, Flutter. Egzersiz adı + kilo saklama, güncelleme, silme. WhatsApp'a not alma alışkanlığının yerini alır.

## Approach
Minimal liste (A seçeneği) — düz ListView, tek ekran, FAB ile ekleme, kalem ikonu ile düzenleme, sola kaydır ile silme.

## Screens & Flow

### HomeScreen (tek ekran)
- **AppBar:** "GYM Tracker"
- **ListView:** Her egzersiz için `ExerciseTile`
  - Sol: egzersiz adı (büyük) + kilo altında (küçük)
  - Sağ: kalem ikonu → `EditWeightDialog`
  - Sola kaydır → kırmızı sil aksiyonu (`Dismissible`)
- **EmptyState:** Liste boşsa — "Henüz egzersiz yok\nEklemek için + bas"
- **FAB (+):** `AddExerciseBottomSheet` açar

### AddExerciseBottomSheet
- TextField: Egzersiz adı
- TextField: Kilo (sayısal, kg)
- "Kaydet" butonu → validate → provider.add() → kapat

### EditWeightDialog
- Mevcut kilo prefill edilmiş TextField
- "İptal" / "Güncelle" butonları

## Visual Design
- **Tema:** Dark
- **Arka plan:** `#121212`
- **Tile arka plan:** `#1E1E1E`
- **Vurgu rengi:** `#BB86FC` (Material Purple)
- **Font:** Default Flutter (Roboto)

## Architecture

### Katmanlar
```
UI (HomeScreen) → Provider (ExerciseProvider) → Repository (ExerciseRepository) → sqflite
```

### Dosya Yapısı
```
lib/
├── main.dart
├── models/
│   └── exercise.dart
├── repositories/
│   └── exercise_repository.dart
├── providers/
│   └── exercise_provider.dart
└── screens/
    └── home_screen.dart
```

### Data Model
```dart
class Exercise {
  final int? id;
  final String name;
  final double weight;
}
```

### DB Schema
```sql
CREATE TABLE exercises (
  id      INTEGER PRIMARY KEY AUTOINCREMENT,
  name    TEXT NOT NULL,
  weight  REAL NOT NULL
);
```

### State Flow
```
UI → Provider.method() → Repository.dbOp() → sqflite
                       ← List<Exercise>    ←
     notifyListeners() → UI rebuild
```

## Dependencies
- `sqflite` — SQLite local storage
- `path` — DB file path
- `provider` — state management

## Validation Rules
- Egzersiz adı boş olamaz
- Kilo 0'dan büyük olmalı
- Kilo sayısal olmak zorunda

## Out of Scope (M1)
- Exercise kategorileri
- Geçmiş / log
- Bildirimler
- Set/rep takibi
