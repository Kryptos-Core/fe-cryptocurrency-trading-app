# Vibe Code — Flutter frontend

**Vibe Code** là tên gọi chuẩn AI-assisted development của team: cùng một bộ rules, skills, hooks và hướng dẫn agent (ECC-aligned) để mọi người dùng Cursor / Copilot / Claude Code / Codex vẫn thống nhất style, bảo mật và quy trình.

## Workspace (cách mở repo — chuẩn team)

- **Cursor / VS Code / Codex CLI:** `File → Open Folder` và chọn **thư mục gốc của repo Flutter này** (cùng cấp với `pubspec.yaml`, `lib/`, `.cursor/`).
- **Không** dùng workspace là cả monorepo cha chứa nhiều app — team FE chỉ cần clone **repo FE** và mở đúng một folder đó để `globs` / hooks / `AGENTS.md` khớp đường dẫn.
- Backend là **repo Git riêng**; đồng bộ contract API qua tài liệu / OpenAPI / rule `api-design`, không phụ thuộc vào mở chung một folder lớn.

## Cấu trúc trong repo

| Thư mục / file | Mục đích |
|-----------------|----------|
| `.cursor/rules/` | Rules Cursor (`.mdc`, `common-*.md`, Dart/Flutter, web…) — **nguồn chính** cho convention |
| `.cursor/hooks/` + `hooks.json` | Hook Cursor (format, cảnh báo secret, shell guard, …) |
| `.cursor/agents/`, `.cursor/commands/` | Agent & slash command ECC trên Cursor |
| `.github/instructions/` | Bản mirror cho **GitHub Copilot Chat / Agent** (`applyTo` theo file) |
| `.github/copilot-instructions.md` | Điểm vào Copilot + hướng dẫn dùng instructions |
| `.agents/skills/` | Skills **Codex CLI** (OpenAI): mỗi skill có `SKILL.md` + `agents/openai.yaml` |
| `.agents/plugins/marketplace.json` | Metadata plugin Codex (nếu dùng marketplace local) |
| `.codex/config.toml` | Codex: sandbox, MCP, `multi_agent`, profiles |
| `.codex/AGENTS.md` | Bổ sung chỉ cho Codex (MCP, `/agent`, …) |
| `.claude/CLAUDE.md` | Bối cảnh nhanh cho **Claude Code** trong repo FE |
| `AGENTS.md` | Mục lục chung + liên kết tới `.cursor/AGENTS.md` |
| `ECC-COMMANDS.md` | Tra cứu lệnh ECC / CCG khi cần |

## Lọc skill AI (không gói chéo BE)

- **Đã gỡ** khỏi FE: skill NestJS, `backend-patterns`, `database-migrations`, React/Next (`frontend-*`, `nextjs-turbopack`), Playwright (`e2e-testing`), `bun-runtime`.
- **Giữ** cho Cursor: `dart-flutter-patterns` và các skill chung (security, TDD, API consumer, MCP, v.v.).
- **Codex** (`.agents/skills/`): không còn backend-only / web-E2E trùng stack BE; xem thư mục để biết danh sách hiện tại.

## Ưu tiên rule theo ngữ cảnh (Flutter)

1. `dart-*`, `flutter-fe-atomic-fsd.mdc`
2. `web-*` (UI chất lượng, a11y, performance)
3. `common-*` (coding style, security, testing, git)
4. `api-design-*`, `pagination-*` khi gọi REST/WebSocket tới backend

## Glob / `applyTo` (Cursor & Copilot)

Mọi `globs` (`.mdc`) và `applyTo` (`.github/instructions/*.md`) **phải tính từ root repo Flutter** (folder bạn vừa mở làm workspace), **không** dùng tiền tố `fe-.../` hay `be-.../` của layout monorepo nhiều project.

- **Flutter FSD:** `**/*.dart`
- **API hiện đại (client):** `**/*.{dart,json,yml,yaml,md}`
- **DB/backend rule trong repo FE:** chỉ `**/*.sql` (hầu như không có file; tránh gắn nhầm lên Dart). Chi tiết CSDL/backend xem rule API + persona.

## Việc cần làm khi chỉnh rule

1. Sửa file trong **`.cursor/rules/`** (đây là nguồn đúng trong repo app).
2. Cập nhật **`.github/instructions/*.instructions.md`** trong **cùng repo** cho khớp (`applyTo` song song với `globs`). Nếu copy rule từ nơi khác, luôn **sửa glob/`applyTo` theo root repo đơn** (xem mục trên).

## Codex / MCP

- Cấu hình MCP nằm trong `.codex/config.toml` (GitHub, Context7, Exa, …). Token/API key cấp qua biến môi trường theo tài liệu từng server.
- Windows: block `notify` macOS đã tắt trong `config.toml`; bổ sung sau nếu cần toast.

## Upstream [everything-claude-code](https://github.com/affaan-m/everything-claude-code.git) (tùy chọn)

- **Repo upstream** trong monorepo cha: `everything-claude-code/` (tham chiếu; không sửa khi chỉ làm feature app).
- **Codex CLI:** làm việc trong repo Flutter này là đủ cho project-local. Muốn đồng bộ MCP/prompt toàn máy vào `~/.codex/`, vào clone upstream → `npm install` → `bash scripts/sync-ecc-to-codex.sh` (Git Bash / WSL). Plugin preview: `codex plugin install ./` tại root upstream.
- **Claude Code:** repo này có `.claude/CLAUDE.md`. Full skill/hook/command của ECC: cài plugin `ecc@ecc` từ marketplace upstream hoặc chạy `install.ps1` / `install.sh` trong clone upstream (xem upstream README).
- Bảng tóm tắt: [AGENTS.md](./AGENTS.md) mục “Upstream ECC”; chi tiết: [AGENTS.md ở monorepo cha](../AGENTS.md).

## Flutter — checklist nhanh

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

## Đồng bộ giữa các bản sao Vibe Code (tùy chọn)

Nếu team có thêm một “repo mẫu” hoặc bản monorepo nội bộ, có thể **copy** `.cursor/`, `.github/`, `.agents/`, `.codex/`, `.claude/` rồi **rà lại glob/`applyTo`** cho đúng workspace một repo (mục trên). Nguồn chuẩn cho team FE vẫn là **repo Flutter này**.
