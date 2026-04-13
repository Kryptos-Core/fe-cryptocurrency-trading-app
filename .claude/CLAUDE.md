# Claude Code — Flutter frontend

**Workspace:** mở **root repo Flutter** (folder có `pubspec.yaml`) — chuẩn team FE; không cần mở monorepo cha.

Ngữ cảnh session: `.claude/`. **Vibe Code / ECC:** [VIBE_CODE.md](../VIBE_CODE.md) · [AGENTS.md](../AGENTS.md) · [ECC-COMMANDS.md](../ECC-COMMANDS.md).

## Kiến trúc & code

- [ARCHITECTURE.md](../ARCHITECTURE.md), [README.md](../README.md)
- Rules Cursor: `.cursor/rules/` (ưu tiên `dart-*`, `flutter-fe-atomic-fsd.mdc`, `common-*`, `web-*`)

## Chạy & kiểm tra

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run
```

## Backend API

Client gọi API **repo backend riêng** của team BE (Git clone độc lập). Contract HTTP/WebSocket: `.cursor/rules/api-design-architecture-patterns.mdc`, `pagination-best-practices.mdc`.

## An toàn

- Không commit `.env` thật, khóa private, seed production.
- Không log secret / token / full JWT trong app.

## ECC — CCG / lệnh multi-agent

Interactive only:

```bash
npx ccg-workflow
```

Chi tiết: [ECC-COMMANDS.md](../ECC-COMMANDS.md).
