# Tài liệu — fe-cryptocurrency-trading-app

> Last reviewed: 2026-07-28 — verified against `lib/`, `pubspec.yaml`, `docs/`.

Đây là chỉ mục toàn bộ tài liệu trong repo Flutter frontend. Team FE dùng repo này làm workspace độc lập (xem `AGENTS.md`); BE NestJS là repo riêng — API contract đối chiếu qua OpenAPI/Swagger.

## Onboarding

| File | Mục đích |
|------|---------|
| [`README.md`](../README.md) | Setup, env vars, scripts, nền tảng hỗ trợ. |
| [`docs/onboarding/day-1-setup.md`](onboarding/day-1-setup.md) | Clone → pub get → analyze → test. |

## Architecture & Coding Style

| File | Mục đích |
|------|---------|
| [`ARCHITECTURE.md`](../ARCHITECTURE.md) | Feature-first Clean Architecture (4 lớp), GoRouter, `import_lint`, layout `test/features/`. |
| [`test/README.md`](../test/README.md) | Tổ chức test (`features/<name>`, `core/`, `support/`), navigation/router tests. |
| [`AGENTS.md`](../AGENTS.md), [`VIBE_CODE.md`](../VIBE_CODE.md), [`CONTRIBUTING-RULES.md`](../CONTRIBUTING-RULES.md) | AI workflow, conventions, PR process. Lệnh slash: xem `.cursor/commands/` và `.claude/commands/`. |

## Security

| File | Mục đích |
|------|---------|
| [`docs/security-zones.md`](security-zones.md) | Vùng nhạy cảm — wallet, orders, withdrawals, binance_trading, treasury, … |
| `.cursor/rules/dart-crypto-app-security.md` | Rule Cursor: secure storage, obscureText, không log balance. |

## Workflow liên quan BE

| Liên kết | Mô tả |
|---------|-------|
| [`WALLETCONNECT_PROJECT_ID` ↔ BE `REOWN_PROJECT_ID`](../README.md) | Cùng project ID Reown Cloud; xem `be/docs/WALLETCONNECT.md` để biết desktop QR + relay. |
| `BASE_URL` | FE `BASE_URL` ↔ BE `API_PUBLIC_URL` (`/api/v1`); xem `be/README.md` và `be/DEPLOYMENT.md`. |
| API contract | Tham chiếu OpenAPI `/api/docs` của BE — `be/src/main.ts` (`SwaggerModule`). |

## Cấu trúc `lib/` nhanh

- `lib/app/` — `app.dart`, DI, router, providers, bootstrap.
- `lib/core/` — network, theme, localization, wallet_auth, services, utils, widgets.
- `lib/features/<feature>/` — feature-first với `data/`, `domain/`, `application/`, `presentation/`.

Xem chi tiết: [`ARCHITECTURE.md`](../ARCHITECTURE.md).

## Scripts / commands thường dùng

```bash
flutter pub get
flutter analyze --fatal-infos
dart run import_lint
flutter test --coverage
```

Xem thêm trong [`README.md`](../README.md) mục **Scripts hữu ích**.