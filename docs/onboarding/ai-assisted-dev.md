# AI-Assisted Development — Flutter Team

Hướng dẫn sử dụng AI (Cursor, Claude Code, Codex) để vibe code trong repo Flutter.

## Triết lý Vibe Code

**Vibe Code** = AI làm boilerplate, human làm decisions. AI gợi ý code, human review và quyết định merge.

**Không phải:** "AI viết hết, mình approve blindly."  
**Đúng là:** "AI accelerate, mình steer và verify."

## Cursor — AI Inline

### Rules đã có sẵn

Khi mở đúng folder `fe-cryptocurrency-trading-app/`, Cursor tự áp:
- `dart-*` rules: FSD architecture, testing, security
- `dart-fsd-architecture.md`: cấu trúc layer, dependency rules
- `dart-crypto-app-security.md`: private key safety, token management
- `web-*` rules: UI quality, accessibility
- `common-*` rules: testing (TDD, 80% coverage), git workflow, code style

### Agents trong Cursor

Gõ `/` trong chat để xem slash commands ECC:
- `/ecc:flutter-review` — review Dart code
- `/ecc:tdd` — start TDD workflow (write test first)
- `/ecc:security-review` — security scan
- `/ecc:flutter-build` — build error analysis

### Workflows thường dùng

**Tạo feature mới:**
```
1. Dùng /ecc:plan để lập kế hoạch
2. Tạo entity trong domain/
3. Tạo use case với test trước (TDD)
4. Implement data layer
5. Tạo provider + widget
6. Run: flutter test + flutter analyze
```

**Debug lỗi:**
```
Chat với AI: "Explain this error: [paste error]"
Hoặc: /ecc:flutter-build nếu build fail
```

## Claude Code — Deep Analysis

Dùng khi cần suy nghĩ sâu về architecture hoặc multi-file refactoring.

```bash
cd fe-cryptocurrency-trading-app
claude

# Trong Claude Code:
# /ecc:plan "Add order history feature"
# /ecc:flutter-review src/presentation/screens/trading.dart
# /ecc:docs "Update ARCHITECTURE.md with new trading screen"
```

**Khi nào dùng Claude Code thay vì Cursor:**
- Refactoring ảnh hưởng 5+ files
- Architecture decisions
- Security audit
- Viết docs

## Codex CLI — Automation Tasks

```bash
cd fe-cryptocurrency-trading-app
codex

# Codex tự load .codex/config.toml + .agents/skills/
```

Dùng Codex cho:
- Tạo boilerplate code theo pattern
- Chạy analysis không cần interactive
- Multi-agent exploration của codebase

## Quality Gates — Bắt buộc trước mỗi PR

```bash
dart format --set-exit-if-changed .   # Format check
flutter analyze --fatal-infos          # Lint
flutter test --coverage                # Tests
```

Nếu CI fail, **không** merge cho đến khi fix.

## Prompt Patterns Hay Dùng

```
"Theo FSD architecture trong ARCHITECTURE.md, tạo use case [X] cho feature [Y]"
"Viết widget test cho [WidgetName] theo AAA pattern"
"Review code này theo rules dart-crypto-app-security.md: [paste code]"
"Implement [feature] theo TDD: viết test trước, sau đó implementation"
```

## Không Làm

- Commit code AI generate mà không đọc
- Bỏ qua `flutter analyze` warnings
- Lưu private key / token vào SharedPreferences
- Hardcode URL API
- Import Flutter trong `domain/`
