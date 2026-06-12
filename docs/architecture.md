# Architecture — GYMApp

## System Overview

Tek katmanlı Flutter uygulaması. Backend yok, her şey cihazda local.

| Katman | Sınıf | Sorumluluğu |
|--------|-------|-------------|
| UI | `HomeScreen` | Dashboard, list, add/edit UI |
| State | `ExerciseProvider` | UI state, provider notifier |
| Repository | `ExerciseRepository` | DB CRUD operasyonları |
| DB | sqflite | SQLite, local persist |
| Model | `Exercise` | Data class (id, name, weight) |

## Data Flow

### Egzersiz Ekleme
```
HomeScreen
  └─► FAB / "Add" butonu tıklanır
        └─► AddExerciseBottomSheet açılır
              └─► Kullanıcı isim + kilo girer, "Kaydet" tıklar
                    └─► ExerciseProvider.addExercise(name, weight)
                          └─► ExerciseRepository.insert(exercise)
                                └─► sqflite INSERT
                          └─► _exercises listesi güncellenir
                                └─► notifyListeners()
                                      └─► HomeScreen yeniden render
```

### Kilo Güncelleme
```
HomeScreen
  └─► Liste item'ına tıklanır / edit ikonu
        └─► EditWeightDialog açılır
              └─► Yeni kilo girilir, "Güncelle" tıklanır
                    └─► ExerciseProvider.updateWeight(id, newWeight)
                          └─► ExerciseRepository.update(exercise)
                                └─► sqflite UPDATE
                          └─► notifyListeners()
```

### Egzersiz Silme
```
HomeScreen
  └─► Swipe-to-delete veya sil butonu
        └─► ExerciseProvider.deleteExercise(id)
              └─► ExerciseRepository.delete(id)
                    └─► sqflite DELETE
              └─► notifyListeners()
```

## Component Architecture

```
HomeScreen
├── AppBar (title: "GYM Tracker")
├── ListView.builder
│   └── ExerciseListTile (name, weight, edit/delete actions)
├── FloatingActionButton → AddExerciseBottomSheet
└── EmptyState widget (liste boşsa)

AddExerciseBottomSheet
├── TextField (egzersiz adı)
├── TextField (kilo)
└── ElevatedButton (Kaydet)

EditWeightDialog
├── TextField (yeni kilo, mevcut değer prefill)
└── TextButton (İptal / Güncelle)
```

## DB Schema

```sql
CREATE TABLE exercises (
  id      INTEGER PRIMARY KEY AUTOINCREMENT,
  name    TEXT NOT NULL,
  weight  REAL NOT NULL
);
```
