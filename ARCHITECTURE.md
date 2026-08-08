# Kryptos Core (Flutter) — Kiến trúc ứng dụng

Ứng dụng **crypto_trading_app** tổ chức theo **Clean Architecture feature-first**, 4 lớp trong mỗi feature (`data` / `domain` / `application` / `presentation`), nền tảng **Android · iOS · Windows · Web** qua Flutter; mạng **Dio + Socket.IO**, DI **GetIt**, state UI **Provider**.

## Luồng phụ thuộc (tóm tắt)

```
presentation (screens, providers, widgets)
       ↓
application (usecases, facade / orchestration services)
       ↓
domain (entities, repository contracts)
       ↑
data (datasources, DTO/models, repository impl)
       ↓
core (network, error, responsive, theme, localization, widgets chung)
```

- **`sl` (`get_it`)**: singleton — `DioClient`, repositories, một số `ChangeNotifier`.
- **`provider`**: `MultiProvider` trong [`lib/app/app.dart`](lib/app/app.dart).

## Cấu trúc `lib/` (snapshot — cập nhật 2026-07-28, verified từ `lib/`)

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── bootstrap/
│   ├── di/injection_container.dart      # Composition root GetIt
│   ├── providers/                       # Provider cross-feature (nếu có)
│   └── router/
│       ├── app_routes.dart              # Path constants, guest allowlist, chỉ số tab shell
│       └── app_router.dart              # GoRouter (ShellRoute `/` + MainScreen; redirect auth)
├── shared/                              # Trống — reserved cho helpers cross-feature (xem mục dưới)
├── core/
│   ├── constants/
│   ├── enums/
│   ├── error/
│   ├── gen_l10n/                        # codegen — không sửa tay
│   ├── l10n/                            # *.arb
│   ├── localization/
│   ├── models/
│   ├── network/
│   ├── responsive/
│   ├── services/                        # service cơ sở (storage, log, v.v.)
│   ├── theme/
│   ├── utils/
│   ├── wallet_auth/                     # multi-platform wallet connector (desktop/mobile/web)
│   └── widgets/                         # Atom UI dùng chung
└── features/
    ├── auth/
    ├── home/
    ├── dashboard/
    ├── markets/
    ├── trading/
    ├── binance_trading/                 # FE mirror API user-binance-credentials (AES-256-GCM)
    ├── wallets/
    ├── orders/
    ├── deposits/
    ├── withdrawals/
    ├── blockchain/
    ├── managed_wallets/
    ├── treasury/
    ├── notifications/
    ├── profile/
    ├── settings/
    ├── user/                            # Entity user + datasource dùng chéo (admin/profile)
    └── admin/                           # users, transactions, currencies, markets, wallet_adjust,
                                         # security_requests, broadcast, payment_config (runtime tabs gồm
                                         # Auth & Security), withdrawal_management, market_maker, …
```

> `lib/examples/` không tồn tại trong repo hiện tại (chỉ reserved trong comment); `lib/shared/` rỗng, đợi nhu cầu thật mới thêm helper theo nguyên tắc YAGNI.

Mỗi feature có thể có đủ `data/` · `domain/` · `application/` · `presentation/` (feature "mỏng" có thể không có `data/`).

### `lib/shared/` vs `lib/core/`

- **`core/`** — hạ tầng và UI atom dùng app-wide (network, theme, formatter, widget nhỏ tái dùng).
- **`shared/`** — dành cho **helpers / model nhẹ gắn domain** khi **nhiều feature** cần cùng một khái niệm nhưng không muốn nhét vào một feature cụ thể. Hiện thư mục rỗng; UI chọn currency / cặp vẫn chủ yếu trong `features/markets/presentation/widgets/`.

### Application services chéo feature

Logic realtime / orchestration gắn một bounded context nhưng được gọi từ nhiều feature (ví dụ socket thông báo) đặt trong **`features/<feature>/application/`** — ví dụ:

- `features/notifications/application/services/fcm_service.dart`
- `features/notifications/application/services/notifications_socket_service.dart`

### Điều hướng (`go_router`)

- **`AppRoutes`** (`app/router/app_routes.dart`): đường dẫn có tên (`/orders`, `/settings`, `/admin/...`, v.v.), `guestAllowlist`, hằng chỉ số tab bottom nav (khớp `MainScreen`).
- **`createAppRouter(AuthProvider)`** (`app/router/app_router.dart`): `MaterialApp.router` dùng cấu hình này; **redirect** guest → `/login` khi path không nằm allowlist; user đã đăng nhập vào `/login` hoặc `/register` → về `/`.
- **Shell**: route `/` bọc trong **`ShellRoute`** (pass-through `child`), bên trong là **`MainScreen`** — chuyển tab vẫn là **state cục bộ** trong `MainScreen`, không đổi URL theo tab.
- Màn được **đẩy chồng** (orders, settings, admin, treasury, …) là các **`GoRoute` cùng cấp** với shell; từ UI dùng `context.push(AppRoutes....)` (không `Navigator.push` chuỗi `MaterialPageRoute` trong `MainScreen`).

### Runtime settings admin UI

`features/admin/payment_config/` hiển thị runtime settings theo category. ADMIN thấy tab **Auth & Security** (`auth_security` / `ConfigCategory.authSecurity`), hiện chứa boolean `EMAIL_VERIFICATION_REQUIRED` với default hiệu lực `true`. Tắt setting này khiến backend bypass email OTP cho đổi password/email, contact-email OTP và thêm/xóa ví; UI gọi category endpoint `GET/PATCH /api/v1/system-configs/runtime/auth_security`. Định nghĩa key, fallback env và migration enum là source of truth phía backend; xem `../be-cryptocurrency-trading-app/docs/ARCHITECTURE.md#email-verification-runtime-setting`.

## Đa nền tảng & responsive

- Phân nhánh native **conditional import**: ví dụ [`lib/core/utils/checkout_tab_preopen.dart`](lib/core/utils/checkout_tab_preopen.dart), wallet auth connectors trong [`lib/core/wallet_auth/`](lib/core/wallet_auth/).
- Layout: [`lib/core/responsive/app_responsive.dart`](lib/core/responsive/app_responsive.dart).

## i18n

ARB: [`lib/core/l10n/`](lib/core/l10n/) · cấu hình [`l10n.yaml`](l10n.yaml) (`arb-dir`, `output-dir`: `lib/core/gen_l10n`). Chạy codegen: `flutter gen-l10n`.

## Kiểm thử

- **Feature tests** — [`test/features/<feature>/...`](test/) mirror gần đúng `lib/features/<feature>/...` (screens, providers, domain, data).
- **Core tests** — [`test/core/`](test/core/) cho utils, services, constants.
- **Support** — [`test/support/`](test/support/) stub/fake dùng chung; import tương đối theo độ sâu file test (hoặc `package:` khi phù hợp).

Widget/unit tests có thể import `package:crypto_trading_app/features/...` trực tiếp. Test chạm navigation có thể cần bối cảnh giống app (`GoRouter` / providers) tùy scenario — xem [`test/README.md`](test/README.md).

## Rào chặn layer & CI

- **`import_lint` (^0.1.6)** — quy tắc regexp trong [`import_analysis_options.yaml`](import_analysis_options.yaml): ví dụ `presentation` không import `features/*/data/`, `domain` không import data (có ignore có chủ đích), `core` không import `features/` (có ignore legacy). Chạy: `dart run import_lint`.
- **`analysis_options.yaml`** không gắn plugin `custom_lint` cho `import_lint` (tránh xung đột toolchain); lint boundary chạy **CLI** như trên và trong CI.

**Gate local / CI (Windows workflow):** `flutter analyze --fatal-infos` → `dart run import_lint` → `flutter test` → (tùy pipeline) `flutter build windows`.
