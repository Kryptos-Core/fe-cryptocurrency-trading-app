You are an AI coding assistant for the cryptocurrency trading app Flutter frontend.

## Project Context

This is a Flutter/Dart app for cryptocurrency trading. It follows Clean Architecture with Feature-Sliced Design (FSD).

**Tech Stack:** Flutter >= 3.0.0, Dart, Provider (state), Dio (HTTP), Hive (local storage), WalletConnect (wallet auth), Firebase (push notifications)

**Architecture (feature-first Clean Architecture — see repo `ARCHITECTURE.md`):**
- `lib/features/<feature>/{domain,data,application,presentation}` — per feature; **domain** must not import Flutter/Dio.
- `lib/app/` — `app.dart`, DI (`injection_container.dart`), **`router/`** (`go_router`, `AppRoutes`, shell route for `/`).
- `lib/core/` — infrastructure (network, theme, utils, shared widgets).
- `lib/shared/` — optional cross-feature helpers (currently README only).

**Routing:** Prefer `context.push(AppRoutes.*)` / `GoRouter`; avoid ad-hoc `Navigator.push(MaterialPageRoute(...))` from shell screens.

## Conventions to Follow

1. **Immutability**: Always use Freezed for data classes. Return new objects, never mutate.
2. **Error handling**: Use `dartz` Either<Failure, T> for use cases. Never swallow errors.
3. **Domain independence**: `domain/` must not import Flutter, Dio, or local storage packages.
4. **Testing**: Every use case and repository must have tests. Minimum 80% coverage.
5. **Naming**: snake_case files, PascalCase classes, camelCase variables. Boolean: `is`/`has`/`can` prefix.

## Security Rules

- **NEVER** store private keys or seed phrases in SharedPreferences — use flutter_secure_storage
- **NEVER** log sensitive data (addresses + balances together, session tokens, private keys)
- **ALWAYS** use `obscureText: true` for seed phrase inputs
- **ALWAYS** show confirmation dialogs before financial actions (order submission)
- JWT tokens must be stored securely and refreshed via interceptor

## Code Style

```dart
// Prefer Freezed for domain models
@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    required String marketId,
    required OrderSide side,
    required OrderStatus status,
  }) = _Order;
}

// Use case returns Either
Future<Either<Failure, Order>> call(CreateOrderParams params);

// Provider (ChangeNotifier) — update state immutably
void setOrders(List<Order> orders) {
  _orders = List.unmodifiable(orders);
  notifyListeners();
}
```

## What NOT to Do

- Do not add NestJS, SQL migrations, or Node.js scripts to this repo
- Do not import backend-specific packages in domain layer
- Do not skip `flutter analyze --fatal-infos` or `dart run import_lint`
- Do not hardcode API URLs (use `.env` or constants file)
- Do not commit `.env` files

## Quality Gates

Before marking any task complete, ensure:
1. `dart format --set-exit-if-changed .` passes
2. `flutter analyze --fatal-infos` passes
3. `dart run import_lint` passes (layer boundaries)
4. `flutter test` passes with >= 80% coverage
5. No `print()` outside debug guards
