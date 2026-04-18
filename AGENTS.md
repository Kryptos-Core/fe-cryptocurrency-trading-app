# fe-cryptocurrency-trading-app — Cursor, Claude Code, Codex

## Workspace (quan trọng)

Mở **đúng thư mục gốc repo Flutter này** làm folder workspace (cùng cấp `pubspec.yaml`). Team FE clone repo FE, làm việc độc lập; **đồng nhất Vibe Code** nhờ `.cursor/`, `.agents/`, `.codex/`, `.claude/` trong repo — không cần mở monorepo cha.

## Tài liệu team

- [VIBE_CODE.md](./VIBE_CODE.md) — Chuẩn AI coding của team FE
- [CONTRIBUTING-RULES.md](./CONTRIBUTING-RULES.md) — Conventions + PR process
- [docs/security-zones.md](./docs/security-zones.md) — Security zones
- [docs/onboarding/](./docs/onboarding/) — Onboarding guides (day-1, ai-dev, ecc-ref)
- [ARCHITECTURE.md](./ARCHITECTURE.md) — Feature-first Clean Architecture (4-layer)

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

**Lệnh slash / multi-agent ECC:** [ECC-COMMANDS.md](./ECC-COMMANDS.md).

## Upstream ECC — [everything-claude-code](https://github.com/affaan-m/everything-claude-code.git) (tùy chọn)

Dùng khi bạn muốn **Codex toàn máy** hoặc **Claude Code full plugin** giống bản upstream; hằng ngày chỉ mở repo Flutter này vẫn đủ nhờ `.codex/` + `.agents/` đã có sẵn.

| Mục đích | Việc cần làm |
|----------|----------------|
| **Codex trong repo này** | Mở folder này làm workspace; không bắt buộc clone upstream. |
| **Merge ECC → `~/.codex/`** | Clone upstream (trong monorepo cha: `../everything-claude-code`). `cd` vào đó → `npm install` → `bash scripts/sync-ecc-to-codex.sh` (Git Bash / WSL). Tuỳ chọn `--dry-run`, `--update-mcp`. |
| **Plugin Codex (preview)** | Từ **root** clone upstream: `codex plugin install ./` — xem `everything-claude-code/.codex-plugin/README.md`. |
| **Claude Code đầy đủ ECC** | Plugin: `/plugin marketplace add https://github.com/affaan-m/everything-claude-code` → `/plugin install ecc@ecc`. Hoặc OSS: trong clone upstream `npm install` rồi Windows `.\install.ps1`, Unix `./install.sh` (xem upstream README). Repo này chỉ bổ sung ngữ cảnh qua `.claude/CLAUDE.md`. |

Chi tiết và lưu ý xung đột với Vibe Code: [AGENTS.md ở monorepo cha](../AGENTS.md) (mục “Upstream ECC”).

## Nguyên tắc ngắn

1. Không hardcode secret; không commit `.env` thật.
2. `flutter analyze` + test trước khi coi feature xong; ưu tiên TDD cho logic quan trọng.
3. UI/feature bám feature modules + Clean Architecture — [ARCHITECTURE.md](./ARCHITECTURE.md), rules `dart-*` / `web-*`, skill **dart-flutter-patterns** khi cần chi tiết.
4. Trả lời user tiếng Việt khi họ dùng tiếng Việt; thuật ngữ kỹ thuật giữ tiếng Anh chuẩn ngành.
