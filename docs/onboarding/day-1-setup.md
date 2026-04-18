# Onboarding — ngày đầu

```bash
git clone <fe-repo-url>
cd fe-cryptocurrency-trading-app
flutter pub get
cp .env.example .env    # BASE_URL kết thúc /api/v1 — xem README

flutter analyze --fatal-infos
dart run import_lint
flutter test

flutter devices
flutter run
```

Kiến trúc và routing: [ARCHITECTURE.md](../../ARCHITECTURE.md). Slash commands AI: [ECC-COMMANDS.md](../../ECC-COMMANDS.md).
