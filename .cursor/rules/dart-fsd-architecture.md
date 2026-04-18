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
├── app/                     # Composition root + bootstrap
│   ├── di/injection_container.dart   # GetIt — đăng ký toàn app
│   └── router/
│       ├── app_routes.dart           # Path constants, guest allowlist, tab indices
│       └── app_router.dart           # GoRouter + ShellRoute shell `/` + MainScreen
├── core/                    # Infrastructure & UI chung
│   ├── constants/, network/, error/, services/, utils/, wallet_auth/
│   ├── localization/, theme/, responsive/, widgets/
│   └── l10n/, gen_l10n/
├── shared/                  # Tùy chọn — helpers cross-feature (README định hướng)
└── features/<feature>/       # data / domain / application / presentation
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
- **core** là shared — được phép import ở mọi layer; **không** import `features/*/…` trừ các path được liệu kê trong [`import_analysis_options.yaml`](../../import_analysis_options.yaml) (`core_no_features` ignore — legacy đang được thu gọn).

**Kiểm tra boundary (CI):** `dart run import_lint` — không dùng plugin analyzer `custom_lint` cho package này; rule nằm trong `import_analysis_options.yaml`.

```dart
// BAD: presentation import trực tiếp DTO
import 'package:app/features/orders/data/models/order_model.dart';

// GOOD: presentation dùng domain entity
import 'package:app/features/orders/domain/entities/order.dart';
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

1. Tạo entity trong `features/<f>/domain/entities/`
2. Tạo abstract repository trong `features/<f>/domain/repositories/`
3. Tạo use cases trong `features/<f>/application/usecases/`
4. Tạo model trong `features/<f>/data/models/` (`fromJson`/`toJson`)
5. Implement repository trong `features/<f>/data/repositories/`
6. Tạo provider trong `features/<f>/presentation/providers/`
7. Xây screen trong `features/<f>/presentation/screens/`

## Đăng ký DI

Dependencies đăng ký qua GetIt trong [`app/di/injection_container.dart`](../../lib/app/di/injection_container.dart):

```dart
// app/di/injection_container.dart
sl.registerLazySingleton<OrderRepository>(
  () => OrderRepositoryImpl(
    remote: sl(),
    local: sl(),
  ),
);
sl.registerFactory(() => CreateOrderUseCase(sl()));
sl.registerFactory(() => OrderProvider(createOrderUseCase: sl()));
```
