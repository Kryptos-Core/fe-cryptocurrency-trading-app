# ECC — lệnh thông dụng (repo Flutter)

Tài liệu tham nhanh cho [Everything Claude Code](https://github.com/affaan-m/everything-claude-code). Phần lớn là **slash command trong Claude Code**; trong **Cursor** dùng `.cursor/commands/` và `.cursor/skills/`.

**Workspace:** mở **thư mục gốc repo này** (cùng cấp với `pubspec.yaml`) trong Cursor / VS Code / Codex — **không** mở folder monorepo cha. Backend NestJS là **repo riêng** của team BE; contract API xem rule `.cursor/rules/api-design-architecture-patterns.mdc`.

Xem thêm [CLAUDE.md](.claude/CLAUDE.md), [AGENTS.md](AGENTS.md), [VIBE_CODE.md](VIBE_CODE.md).

**Claude Code CLI + plugin ECC:** **`/ecc:<tên>`** (ví dụ `/ecc:plan`). Tiền tố `/plan`, `/tdd`, … nếu team cấu hình trong `~/.claude/commands/` hoặc `.claude/commands/`. **Cursor:** có thể dùng `/plan`, `/flutter-test`, … qua `.cursor/commands/`.

---

## Lên kế hoạch & kiến trúc

| Mục đích | Lệnh / gọi ý |
|----------|----------------|
| Blueprint tính năng | **`/ecc:plan`** (CLI); Cursor: **`/plan`** |
| Luồng lớn / module | Cùng `/plan`, hoặc agent **architect** / **code-architect** trong prompt |

---

## Code & chất lượng (Dart / Flutter)

| Mục đích | Lệnh / gọi ý |
|----------|----------------|
| TDD | **`/ecc:tdd`** (CLI); Cursor: **`/tdd`** |
| Review sau khi sửa | **`/ecc:code-review`** (CLI); Cursor: **`/code-review`** |
| Build / analyze lỗi | Cursor: **`/flutter-build`**, sửa theo `flutter analyze` |
| Test | Cursor: **`/flutter-test`** |
| Review Flutter cụ thể | Cursor: **`/flutter-review`** |
| Pattern Flutter (BLoC, Riverpod, navigation, Dio…) | Skill **`dart-flutter-patterns`** trong `.cursor/skills/` — nhắc trong prompt |
| Lỗi build Dart/Flutter | Agent **dart-build-resolver**; review UI **flutter-reviewer** |
| API client / contract | **api-design**, **documentation-lookup** (Context7) |

---

## Bảo mật & dữ liệu

| Mục đích | Gọi ý |
|----------|--------|
| Checklist bảo mật | Skill **security-review** trong prompt |
| Rule Dart security | `.cursor/rules/dart-security.md` |

---

## Test & kiểm thử

| Mục đích | Lệnh terminal / Cursor |
|----------|-------------------------|
| Unit / widget test | `flutter test` — Cursor **`/flutter-test`** |
| E2E / integration | `integration_test` theo cấu trúc dự án (không dùng Playwright trong repo này) |
| Coverage | Cấu hình theo team (`coverage` package, v.v.) |

---

## Dọn code & tài liệu

| Mục đích | Lệnh |
|----------|------|
| Dead code | **`/ecc:refactor-clean`** (CLI); Cursor: **`/refactor-clean`** |
| Cập nhật docs | **`/ecc:update-docs`** (CLI); Cursor: **`/update-docs`** |

---

## Vòng verify & context

| Mục đích | Lệnh / gọi ý |
|----------|----------------|
| Checkpoint / verify | **`/ecc:checkpoint`**, **`/ecc:verify`** (CLI); Cursor tương đương nếu có |
| Nén context | Skill **strategic-compact** hoặc `/compact` (Claude Code) |

---

## Multi-model (CCG)

Sau khi **`npx ccg-workflow`** và init CCG (xem [CLAUDE.md](.claude/CLAUDE.md)): **`/ecc:multi-plan`**, **`/ecc:multi-execute`**, … (Claude CLI).

---

## Workflow ngắn (Flutter app)

1. **`/plan`** → phạm vi (màn hình, state, API gọi vào BE).  
2. Code → **`/tdd`** khi cần.  
3. **`flutter analyze`** / **`/flutter-build`** khi lỗi compile.  
4. Trước merge: **`/code-review`**, **security-review**.  
5. UI kiến trúc: **`dart-flutter-patterns`**, rule **`flutter-fe-atomic-fsd.mdc`**.

---

## Xem đầy đủ

- **Claude Code:** `/plugin list ecc@ecc`  
- **Cursor:** `.cursor/commands/`, `.cursor/skills/`
