# Claude Code — Flutter frontend

**Workspace:** `fe-cryptocurrency-trading-app/` (Flutter / Dart). **Chuan team FE.**

Thu muc `.claude/` la nguon chuan cua FE. Khi mo workspace la root monorepo, FE tu dong duoc nhan dien nhu subdirectory.

## Nguon chi

| File | Ghi chu |
|------|---------|
| `ARCHITECTURE.md` | 4 lop, feature modules, router |
| `VIBE_CODE.md`, `CONTRIBUTING-RULES.md` | Quy uoc team |
| `docs/security-zones.md` | Vung an toan du lieu |
| `README.md` | Setup, chay local |

---

## Kien truc & code

- **4-layer Clean Architecture** + **FSD** (Feature-Scaled Design): xem `ARCHITECTURE.md`.
- **Rules**: `.cursor/rules/` (uu tien `dart-*.md`, `web-*.md`, `common-*`)
- **Skills**: `.cursor/skills/dart-flutter-patterns`, `.cursor/skills/flutter-dart-code-review`

## Chay & kiem tra

```bash
flutter pub get
dart format .
flutter analyze --fatal-infos
dart run import_lint
flutter test
flutter run
```

Test tree: `test/features/...` + `test/core/`, `test/support/`. Layer/routing: `ARCHITECTURE.md`.

## Backend API

Client goi API **repo backend rieng** cua team BE (Git clone doc lap). Contract HTTP/WebSocket: skill **api-design**, README/OpenAPI repo BE, va code client trong `lib/`.

## An toan

- Khong commit `.env` that, khoa private, seed production.
- Khong log secret / token / full JWT trong app.

## Chuan AI — Rules & Skills

| Muc | Duong dan | Ghi chu |
|-----|-----------|---------|
| Rules | `.cursor/rules/` | dart-fsd-architecture, dart-crypto-app-security, dart-*, web-*, common-* |
| Skills | `.cursor/skills/` | dart-flutter-patterns, flutter-dart-code-review, frontend-patterns, frontend-design |

ECC commands (neu can):

```bash
npx ccg-workflow
```

Chi tiet: xem `.cursor/commands/` và `.claude/commands/`.
