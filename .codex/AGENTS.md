# ECC for Codex CLI — Flutter Frontend

**Stack:** Flutter / Dart — `fe-cryptocurrency-trading-app/`

## Model Recommendations

| Task Type | Recommended Model |
|-----------|------------------|
| Routine coding, tests, formatting | GPT 5.4 |
| Complex features, architecture | GPT 5.4 |
| Debugging, refactoring | GPT 5.4 |
| Security review | GPT 5.4 |

## Stack Reminder

Repo nay la **Flutter frontend**. Khong tao NestJS, Express, database migration, hay Playwright test trong repo nay. Neu can thay doi API contract, phoi hop voi team BE qua tai lieu/OpenAPI.

## Multi-Agent Support

Codex supports multi-agent workflows with `features.multi_agent = true` in `config.toml`.

- Define roles under `[agents.<name>]` in `config.toml`
- Point each role at a TOML layer under `.codex/agents/`
- Use `/agent` inside Codex CLI to inspect and steer child agents

Sample roles:
- `.codex/agents/explorer.toml` — read-only evidence gathering
- `.codex/agents/reviewer.toml` — correctness/security review
- `.codex/agents/docs-researcher.toml` — API and release-note verification

## Quality Gates (Flutter)

Truoc khi coi mot feature hoan thanh, **bat buoc** chay:

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze --fatal-infos
dart run import_lint
flutter test --coverage
```

Neu Codex vua tao / sua code, ket thuc session bang cach tu chay (hoac nhac user chay) cac lenh tren.

### Checklist tu kiem tra (Codex)

Truoc khi bao "done":
- [ ] `flutter analyze --fatal-infos` sach; `dart run import_lint` sach
- [ ] `flutter test` pass 100%
- [ ] Khong co `print()` hoac `debugPrint()` ngoai debug build guard
- [ ] Khong co hardcode URL, token, private key
- [ ] Domain layer khong import Flutter/Dio
- [ ] Widget moi co widget test co ban

## Security Without Hooks

Codex lacks hooks, security enforcement is instruction-based:
1. Always validate inputs at system boundaries
2. Never hardcode secrets — use environment variables
3. Run `flutter analyze --fatal-infos`, `dart run import_lint`, and `flutter test` before committing
4. Review `git diff` before every push
5. Use `sandbox_mode = "workspace-write"` in config

## Key Differences from Claude Code

| Feature | Claude Code | Codex CLI |
|---------|------------|-----------|
| Hooks | 8+ event types | Not yet supported |
| Context file | CLAUDE.md + AGENTS.md | AGENTS.md only |
| Skills | Skills loaded via plugin | `.agents/skills/` directory |
| Commands | `/slash` commands | Instruction-based |
| Agents | Subagent Task tool | Multi-agent via `/agent` and `[agents.<name>]` roles |
| Security | Hook-based enforcement | Instruction + sandbox |
| MCP | Full support | Supported via `config.toml` and `codex mcp add` |
