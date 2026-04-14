# ECC Commands Reference — Flutter Team

## Cursor Slash Commands

| Command | Dùng khi |
|---------|----------|
| `/ecc:plan` | Lập kế hoạch feature trước khi code |
| `/ecc:flutter-review` | Review Dart/Flutter code vừa viết |
| `/ecc:flutter-build` | Build fail, cần giải thích lỗi |
| `/ecc:flutter-test` | Run test + analyze coverage |
| `/ecc:tdd` | Start TDD workflow cho feature |
| `/ecc:security-review` | Security scan (trước khi commit) |
| `/ecc:code-review` | General code quality review |
| `/ecc:docs` | Update/tạo documentation |
| `/ecc:verify` | Verify implementation theo plan |
| `/ecc:prune` | Xóa dead code, unused imports |

## Claude Code Slash Commands

```bash
/ecc:plan "mô tả feature"      # Planning agent
/ecc:tdd                        # TDD guide agent
/ecc:flutter-review             # Flutter reviewer agent
/ecc:security-review            # Security reviewer agent
/ecc:verify                     # Verification loop
/ecc:docs                       # Doc updater
/ecc:sessions                   # Xem session history
/ecc:resume-session             # Resume session cũ
```

## Multi-Agent (CCG — Interactive Only)

```bash
cd fe-cryptocurrency-trading-app
npx ccg-workflow
```

Dùng cho tasks cần nhiều agents phối hợp (plan → implement → review → verify).

## Skill Reference

Skills trong `.cursor/skills/` (Cursor) và `.agents/skills/` (Codex):

| Skill | Mục đích |
|-------|----------|
| `dart-flutter-patterns` | FSD architecture, widget patterns, state management |
| `api-design` | API consumer patterns (Dio, WebSocket client) |
| `security-review` | Security vulnerabilities |
| `tdd-workflow` | Test-driven development |
| `frontend-design` | UI/UX quality, accessibility |
| `documentation-lookup` | Tra cứu Flutter/Dart docs via Context7 |

## Quality Checklist (copy vào PR description)

```markdown
## Quality Checklist
- [ ] flutter analyze --fatal-infos: PASS
- [ ] flutter test: PASS (coverage >= 80%)
- [ ] dart format: no changes
- [ ] No hardcoded URLs/tokens
- [ ] Domain layer has no Flutter/Dio imports
- [ ] New widgets have widget tests
- [ ] VIBE_CODE.md conventions followed
```
