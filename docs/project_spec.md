# Project Spec — GYMApp

## Part 1 — Product Requirements

### Who is it for?
Kişisel kullanım — tek bir kullanıcı (arkadaş). Dağıtım kanalı yok, App Store hedefi yok; cihaza direkt kurulum.

### Hangi sorunu çözüyor?

| Problem | Çözüm |
|--------|-------|
| Egzersiz kilolarını WhatsApp'a not alıp sonra bulmakta zorluk çekmek | Dashboard'da egzersiz adı + kilo listesi, anında görünür |
| Hangi hareketi kaç kg ile yapacağını unutmak | Her hareket için kilo bilgisi saklı, güncelleme kolay |
| Farklı hareketler için farklı kilolar denemek ve doğru kiloyu belirlemek | Kilo güncelleme özelliği, geçmiş referans olarak kalır |

### Ürün ne yapıyor?
- **Core loop:** Kullanıcı uygulama açar → dashboard'da tüm hareketleri görür → yeni hareket ekler (isim + kilo) → gerektiğinde kiloyu günceller.
- **Key features:**
  - Egzersiz listesi (isim + kilo)
  - Yeni egzersiz ekleme
  - Kilo güncelleme (inline edit)
  - Egzersiz silme

---

## Part 2 — Technical Design

### Tech Stack

| Katman | Teknoloji |
|-------|-----------|
| Frontend | Flutter (Dart) |
| Local Storage | sqflite (SQLite) |
| State Management | Provider veya Riverpod |
| Platform | iOS (öncelik), Android (sonraki) |
| Dağıtım | Local build, USB deploy |

### Engineering Requirements

**Mevcut sistemler:** Yok (sıfırdan)

**Yeni sistemler:**
- Flutter projesi (iOS target)
- SQLite veritabanı (local, cihazda)
- Basit CRUD katmanı (exercise repository)

### Architecture

```
┌─────────────────────────────────────┐
│           Flutter UI Layer           │
│  HomeScreen (Dashboard)              │
│  AddExerciseSheet (bottom sheet)     │
│  EditWeightDialog                    │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         State Management             │
│  ExerciseProvider / ExerciseNotifier │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Repository Layer             │
│  ExerciseRepository (CRUD)           │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Local Database               │
│  SQLite via sqflite                  │
│  Table: exercises (id, name, weight) │
└─────────────────────────────────────┘
```

### System Design

**State machine (egzersiz):**
```
[Empty] → add → [HasExercises]
[HasExercises] → update weight → [HasExercises]
[HasExercises] → delete → [Empty / HasExercises]
```

**DB Schema:**
```sql
CREATE TABLE exercises (
  id      INTEGER PRIMARY KEY AUTOINCREMENT,
  name    TEXT NOT NULL,
  weight  REAL NOT NULL
);
```

---

## Part 3 — Technical Architecture

### Data Flow

```
User taps "Add"
  → AddExerciseSheet açılır
  → isim + kilo girilir
  → ExerciseProvider.add() çağrılır
  → ExerciseRepository.insert() → sqflite
  → Provider state güncellenir
  → Dashboard yeniden render
```

### Project Structure

```
lib/
├── main.dart
├── models/
│   └── exercise.dart          # Exercise data class
├── repositories/
│   └── exercise_repository.dart  # CRUD + DB init
├── providers/
│   └── exercise_provider.dart    # State management
└── screens/
    └── home_screen.dart          # Dashboard + add/edit UI
```

### Logging Format
`[Repository] Exercise inserted: Curl 5kg`
`[Provider] State updated: 3 exercises`

### Naming Conventions
- Classes: PascalCase (`ExerciseRepository`)
- Fields/variables: camelCase (`exerciseList`)
- Files: snake_case (`exercise_repository.dart`)
- DB table/columns: snake_case (`exercises`, `weight_kg`)
