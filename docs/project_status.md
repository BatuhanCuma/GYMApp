# Project Status — GYMApp

## Milestones

| # | Açıklama | Durum |
|---|----------|-------|
| M0 | Proje Kurulumu | ✅ Tamamlandı |
| M1 | Core CRUD | 🔄 Sıradaki |
| M2 | Polish & iOS Deploy | ⏳ Bekliyor |

## Tamamlananlar

- Proje yapısı ve dokümantasyon kuruldu
- CLAUDE.md, docs/, .claude/ konfigürasyonları hazırlandı
- Git başlatıldı, ilk commit atıldı

## Sıradaki (M1 Checklist)

- [ ] `lib/models/exercise.dart` — Exercise data class
- [ ] `lib/repositories/exercise_repository.dart` — sqflite CRUD + DB init
- [ ] `lib/providers/exercise_provider.dart` — state management
- [ ] `lib/screens/home_screen.dart` — dashboard UI
- [ ] Yeni egzersiz ekleme (bottom sheet)
- [ ] Kilo güncelleme (dialog)
- [ ] Egzersiz silme (swipe-to-delete)
