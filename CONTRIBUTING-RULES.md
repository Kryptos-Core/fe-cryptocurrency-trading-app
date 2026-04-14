# Contributing Rules — Flutter Team

## Quick Reference

**Rule priority:** `dart-*` → `web-*` → `common-*`

**Stack:** Flutter/Dart only. Không tạo NestJS, SQL migration, hay Node script trong repo này.

## Before You Code

1. Đọc [VIBE_CODE.md](./VIBE_CODE.md) nếu chưa đọc
2. Đọc [ARCHITECTURE.md](./ARCHITECTURE.md) nếu feature ảnh hưởng đến layer structure
3. Dùng `/ecc:plan` (Cursor) trước khi implement feature phức tạp (>= 3 files)

## Code Conventions

### Architecture

- **Feature-Sliced Design (FSD):** mỗi feature là một slice với `domain/`, `data/`, `presentation/`
- Domain layer independent: không import Flutter, Dio, local storage
- Repository pattern: `domain/repositories/` khai báo interface, `data/repositories/` implement

### Dart Style

```dart
// ✓ Immutable data classes với Freezed
@freezed
class Order with _$Order {
  const factory Order({required String id, required OrderSide side}) = _Order;
}

// ✓ Either cho error handling
Future<Either<Failure, Order>> createOrder(CreateOrderParams p);

// ✓ Functional style với dartz
return result.fold(
  (failure) => Left(failure),
  (order) => Right(order),
);
```

### Naming

| Loại | Convention | Ví dụ |
|------|-----------|-------|
| Classes | PascalCase | `OrderUseCase`, `TradeRepository` |
| Variables/functions | camelCase | `currentOrder`, `fetchOrders()` |
| Constants | UPPER_SNAKE | `API_TIMEOUT_MS` |
| Files | snake_case | `order_use_case.dart` |
| Test files | `*_test.dart` | `order_use_case_test.dart` |

## Testing Requirements

- **Mọi use case** phải có unit test
- **Mọi repository** phải có integration test (mock HTTP client)
- **Mọi widget màn hình chính** phải có widget test
- Coverage minimum: **80%**

```bash
flutter test --coverage
# Xem report: open coverage/html/index.html
```

## Git Workflow

```bash
# Branch naming
feature/trading-order-history
fix/login-jwt-refresh
chore/update-flutter-sdk

# Commit format
feat: add order history pagination
fix: resolve JWT refresh race condition
test: add widget test for TradingScreen
```

## PR Requirements

- Title: `<type>: <short description>` (< 72 chars)
- Body: dùng template PR (copy từ `docs/onboarding/ecc-commands-quick-ref.md`)
- Minimum 1 reviewer
- CI phải pass (flutter analyze + flutter test)
- Không merge PR mà mình tự approve

## Security Requirements

Đọc [docs/security-zones.md](./docs/security-zones.md). Không commit:
- `.env` file thật
- Private keys hoặc seed phrases
- JWT tokens
- API keys của production

Dùng hook `before-submit-prompt.js` sẽ warning nếu prompt chứa secrets.
