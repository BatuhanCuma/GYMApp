# CLAUDE.md — GYMApp

## 1. Project Goal & Design

### Project Goal
Arkadaş için kişisel kullanım gym takip uygulaması. Egzersiz kilolarını WhatsApp'ta not alma alışkanlığının yerini alan, basit ve hızlı bir dashboard: hareket ekle, kilosunu gir, güncelle. Fazlası yok.

### Architecture Overview
Flutter tek sayfa uygulaması. UI → Provider (state) → Repository → sqflite (local SQLite). Backend yok, her şey cihazda. Detaylar: `docs/architecture.md`

### Data Flow
```
UI action → ExerciseProvider → ExerciseRepository → sqflite → notifyListeners() → UI re-render
```

### Design Style Guide

**Tech Stack**
| Katman | Teknoloji |
|--------|-----------|
| Frontend | Flutter / Dart |
| Storage | sqflite (SQLite, local) |
| State | Provider |
| Platform | iOS (öncelik), Android (sonraki) |

**Visual Style**
- Sade, dark veya light — arkadaşın tercihine göre
- Material Design 3 bileşenleri
- Gereksiz animasyon yok, hızlı açılış öncelikli

**Component Patterns**
- Her CRUD işlemi için Provider metodu
- Repository sınıfı DB'ye direkt erişir, UI dokunmaz
- Bottom sheet → ekleme, Dialog → güncelleme

**Core UX Principles**
- Ana ekranda her şey görünür, scroll minimum
- Kilo güncelleme tek dokunuşla ulaşılabilir
- Boş state'de yönlendirici mesaj

**Copy Tone**
Türkçe, kısa ve net. "Egzersiz Ekle", "Kiloyu Güncelle".

---

## 2. Constraints & Policies

### Security
- Uygulama secret içermiyor; .env kullanılmıyor
- Gelecekte API eklenirse: secret'lar asla koda yazılmaz, .env.example'a şablon eklenir

### Code Quality
- Her DB operasyonu try/catch ile sarılır
- Log format: `[System] Message` — örnek: `[Repository] Exercise inserted: Curl 5kg`
- Test: Widget testleri M2'de; M1'de manuel test yeterli

### Dependencies
**Onaylı paketler:**
- `sqflite` — local SQLite
- `path` — DB dosya yolu
- `provider` — state management

Yeni paket eklemeden önce sor.

---

## 3. Repository Etiquette

### Branching
```
main              → stabil, deploy edilebilir
feature/<x>       → yeni özellik
fix/<x>           → bug fix
milestone/<x>     → milestone branch
```

### Git Workflow
`feature/<x>` → commit → merge to main → branch sil

### Commits
Kısa, imperative: `feat: add exercise CRUD`, `fix: weight update not persisting`

### Pull Requests
Tek geliştirici olduğu için PR zorunlu değil; merge direkt yapılabilir.

### Before Pushing
- [ ] `flutter analyze` temiz
- [ ] Temel akış test edildi (ekle, güncelle, sil)
- [ ] .env staged değil

---

## 4. Commands

### Test
```bash
flutter test
```

### Build
```bash
flutter build ios --release
flutter run                    # simulator
flutter run -d <device-id>    # gerçek cihaz
```

### Git
```bash
git add <files>
git commit -m "feat: ..."
```

### Environment Variables
Bu projede secret yok. Gelecekte eklenirse `.env.example`'a şablon eklenir.

---

## 5. Documentation

| Dosya | İçerik |
|-------|--------|
| `docs/project_spec.md` | Ürün gereksinimleri, teknik tasarım, mimari |
| `docs/architecture.md` | Data flow diyagramları, component yapısı |
| `docs/milestones.md` | Milestone takibi (checkbox) |
| `docs/project_status.md` | Mevcut durum ve sıradaki adımlar |

### Rules
- Major milestone sonrası `docs/` güncelle
- Yeni özellik eklenince `docs/architecture.md` güncelle
- Milestone tamamlanınca `docs/milestones.md`'de işaretle
