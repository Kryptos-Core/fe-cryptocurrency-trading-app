# fe-cryptocurrency-trading-app — Cursor, Claude Code, Codex

> Last reviewed: 2026-07-28 — verified against `.cursor/`, `.agents/`, `.codex/`, `.claude/`.

## Workspace (quan trọng)

Mở **đúng thư mục gốc repo Flutter này** làm folder workspace (cùng cấp `pubspec.yaml`). Team FE clone repo FE, làm việc độc lập; **đồng nhất Vibe Code** nhờ `.cursor/`, `.agents/`, `.codex/`, `.claude/` trong repo — không cần mở monorepo cha.

## Tài liệu team

- [VIBE_CODE.md](./VIBE_CODE.md) — Chuẩn AI coding của team FE
- [CONTRIBUTING-RULES.md](./CONTRIBUTING-RULES.md) — Conventions + PR process
- [docs/security-zones.md](./docs/security-zones.md) — Security zones
- [docs/onboarding/day-1-setup.md](./docs/onboarding/day-1-setup.md) — setup ngày đầu
- [ARCHITECTURE.md](./ARCHITECTURE.md) — Feature-first Clean Architecture (4-layer), `go_router`, `import_lint`, layout `test/features/`

## Stack

- **Flutter / Dart** — `lib/`, `test/`, `pubspec.yaml`. Kiến trúc: [ARCHITECTURE.md](./ARCHITECTURE.md).

## ECC (đã tích hợp sẵn)

| Thành phần | Vai trò |
|------------|---------|
| `.cursor/rules/` + hooks | Rules & automation Cursor |
| `.cursor/agents`, `commands` | Agent/command ECC cho Cursor |
| `.agents/skills/` | Skills Codex (OpenAI) — `SKILL.md` + `agents/openai.yaml` |
| `.codex/` | `config.toml`, MCP, multi-agent Codex CLI |
| `.claude/CLAUDE.md` | Ngữ cảnh nhanh cho Claude Code |

**Hướng dẫn agent chi tiết (nguyên tắc, orchestration, testing, security):** [`.cursor/AGENTS.md`](./.cursor/AGENTS.md).

**Lệnh slash / multi-agent ECC:** xem `.cursor/commands/` và `.claude/commands/`.

## Optional upstream

The upstream ECC project can be used for personal machine-wide sync, but it is not part of the team's default workflow. Day-to-day work stays in this repo.

## Nguyên tắc ngắn

1. Không hardcode secret; không commit `.env` thật.
2. `flutter analyze --fatal-infos`, `dart run import_lint`, và `flutter test` trước khi coi feature xong; ưu tiên TDD cho logic quan trọng.
3. UI/feature bám feature modules + Clean Architecture — [ARCHITECTURE.md](./ARCHITECTURE.md), rules `dart-*` / `web-*`, skill **dart-flutter-patterns** khi cần chi tiết.
4. **Luôn luôn trả lời user bằng tiếng Việt có dấu** cho mọi phản hồi, kế hoạch, tài liệu; thuật ngữ kỹ thuật (Flutter, widget, state, route, wallet, v.v.) giữ tiếng Anh chuẩn ngành. Xem chi tiết ở [`.cursor/rules/common/language-vi.md`](./.cursor/rules/common/language-vi.md).
