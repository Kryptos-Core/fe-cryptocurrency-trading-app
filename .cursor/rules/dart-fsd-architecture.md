---
paths:
  - "**/*.dart"
  - "**/lib/**"
---
# Dart/Flutter FSD Architecture

> Enforce Feature-Sliced Design (FSD) + Clean Architecture cho Flutter app.
> Chi tiết: [ARCHITECTURE.md](../../ARCHITECTURE.md)

## Cấu trúc thư mục bắt buộc

```
lib/
├── core/                    # Shared infrastructure
│   ├── constants/           # AppColors, AppTextStyles, AppRoutes, ApiEndpoints
│   ├── di/                  # GetIt service locator setup
│   ├── error/               # Failure types, AppException
│   ├── network/             # Dio client, interceptors, WebSocket
│   ├── providers/           # App-level providers (locale, theme)
│   ├── services/            # Cross-cutting services (analytics, storage wrappers)
│   ├── utils/               # Pure helper functions (formatters, validators)
│   └── wallet_auth/         # SENSITIVE — wallet connect, auth flow
├── data/                    # Data layer (implements domain contracts)
│   ├── datasources/         # Remote (API) + Local (Hive, SecureStorage)
│   ├── models/              # Data transfer objects (JSON serializable)
│   └── repositories/        # Concrete repository implementations
├── domain/                  # Business logic — NO Flutter imports allowed
│   ├── entities/            # Pure Dart business objects
│   ├── repositories/        # Abstract repository interfaces
│   └── usecases/            # Single-responsibility use cases
├── presentation/            # Stateful layer
│   ├── providers/           # Feature-level ChangeNotifier / Riverpod providers
│   ├── widgets/             # Reusable atomic/molecular widgets
│   └── screens/             # Page-level composition (feature screens)
└── screens/                 # Top-level screen routing (legacy; migrate into features)
```

## Quy tắc phụ thuộc (Dependency Rules)

```
presentation → domain ← data
       ↓
      core (shared only)
```

- **domain** không được import Flutter, Dio, Hive, hoặc bất kỳ gói infra nào
- **data** implement contracts từ **domain**, không phụ thuộc **presentation**
- **presentation** chỉ biết đến **domain entities** và **use cases** (không biết đến models)
- **core** là shared — được phép import ở mọi layer nhưng không import từ layer nào

```dart
// BAD: presentation phụ thuộc data model
import 'package:app/data/models/order_model.dart';

// GOOD: presentation dùng domain entity
import 'package:app/domain/entities/order.dart';
```

## Quy tắc tổ chức file

- File mới cho **feature cụ thể** → đặt trong thư mục feature đó, không vào `core/`
- File **shared giữa nhiều feature** → đặt vào layer tương ứng trong `core/` hoặc `domain/`
- Mỗi file tối đa **400 dòng** — tách file nếu vượt
- **Widget file**: 1 widget public per file (private helpers được phép trong cùng file)

## Use Cases

Mỗi use case là 1 class riêng, implements logic duy nhất:

```dart
// BAD: use case làm quá nhiều việc
class OrderUseCase {
  Future<Order> createOrder(...) async { ... }
  Future<void> cancelOrder(...) async { ... }
  Future<List<Order>> getOrderHistory(...) async { ... }
}

// GOOD: tách nhỏ
class CreateOrderUseCase {
  final OrderRepository _repository;
  CreateOrderUseCase(this._repository);
  Future<Either<Failure, Order>> call(CreateOrderParams params) async { ... }
}
```

## Repository Pattern

```dart
// domain/repositories/order_repository.dart (abstract)
abstract class OrderRepository {
  Future<Either<Failure, Order>> createOrder(CreateOrderParams params);
  Future<Either<Failure, List<Order>>> getOrderHistory({int page = 1});
}

// data/repositories/order_repository_impl.dart (concrete)
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remote;
  final OrderLocalDataSource _local;
  // ...
}
```

## Khi thêm feature mới

1. Tạo entity trong `domain/entities/`
2. Tạo abstract repository trong `domain/repositories/`
3. Tạo use cases trong `domain/usecases/`
4. Tạo model trong `data/models/` (với `fromJson`/`toJson`)
5. Implement repository trong `data/repositories/`
6. Tạo provider trong `presentation/providers/`
7. Xây dựng screen trong `presentation/screens/` hoặc `screens/`

## Đăng ký DI

Tất cả dependencies phải đăng ký qua GetIt trong `core/di/`:

```dart
// core/di/injection_container.dart
sl.registerLazySingleton<OrderRepository>(
  () => OrderRepositoryImpl(
    remote: sl(),
    local: sl(),
  ),
);
sl.registerFactory(() => CreateOrderUseCase(sl()));
sl.registerFactory(() => OrderProvider(createOrderUseCase: sl()));
```
