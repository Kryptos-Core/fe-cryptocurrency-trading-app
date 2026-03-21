# Kryptos Core (Flutter) — Kiến trúc ứng dụng

Ứng dụng **crypto_trading_app** tổ chức theo hướng **Clean Architecture / layered**: domain ở giữa, data triển khai repository, presentation + `screens` gắn UI với backend qua **Dio** và **Socket.IO**.

## Luồng phụ thuộc (tóm tắt)

```
screens / presentation/widgets
        ↓ Consumer / Provider / trực tiếp sl<>
presentation/providers (ChangeNotifier)
        ↓
domain (entities, use cases, repository interfaces)
        ↓ implements
data (repositories, datasources, models)
        ↓
core (DioClient, ApiConstants, DI, errors, utils)
```

- **`get_it` (`sl`)**: đăng ký singleton — `DioClient`, `TokenService`, data sources, repositories, use cases, một số `ChangeNotifier` (ví dụ `LocaleProvider`).
- **`provider`**: bọc widget tree trong `main.dart`; màn hình dùng `context.read` / `Consumer` với các provider như `AuthProvider`, `MarketsProvider`, `WalletsProvider`, …

## Cấu trúc thư mục `lib/`

```
lib/
├── main.dart                 # dotenv, Firebase (mobile), MultiProvider
├── core/
│   ├── constants/            # api_constants.dart (BASE_URL, endpoints)
│   ├── di/                   # injection_container.dart (GetIt)
│   ├── providers/          # locale_provider.dart, theme_provider.dart
│   ├── error/                # failures, exceptions
│   ├── network/              # dio_client.dart, interceptors
│   ├── services/             # token, cache, notifications, …
│   └── utils/
├── data/
│   ├── datasources/          # *remote_datasource.dart
│   ├── models/               # JSON DTOs
│   └── repositories/         # *repository_impl.dart
├── domain/
│   ├── entities/
│   ├── repositories/         # abstract contracts
│   └── usecases/
├── presentation/
│   ├── providers/            # auth, markets, orders, wallets, admin, treasury, …
│   ├── widgets/
│   └── screens/              # một số feature (blockchain, managed wallets, payment_config, …)
├── screens/                  # màn chính: main, home, login, admin, orders, …
├── gen_l10n/                 # generated — không sửa tay
└── l10n/                     # app_en.arb, app_vi.arb
```

## Màn hình tiêu biểu (`lib/screens/`)

Auth & shell: `login_screen`, `register_screen`, `main_screen`, `home_screen`, `settings_screen`, `profile_screen`.

Giao dịch & thị trường: `markets_list_screen`, `market_detail_screen`, `advanced_trading_screen`, `orders_screen`, `dashboard_screen`, `currencies_list_screen`, `currency_detail_screen`.

Ví & nạp: `wallets_overview_screen`, `wallet_detail_screen`, `deposits_screen`, `wallet_api_screen`, …

Admin / vận hành: `admin_user_list_screen`, `admin_user_detail_screen`, `admin_transactions_screen`, `admin_currencies_screen`, `admin_wallet_adjust_screen`, `security_requests_review_screen`, `broadcast_notification_screen`, …

Market maker: `market_maker/market_maker_hub_screen`, `market_maker_config_screen`.

## Mạng & realtime

- **HTTP:** `ApiConstants.baseUrl` (từ `.env` `BASE_URL` hoặc default theo nền tảng). Android emulator: `http://10.0.2.2:3000/api/v1`.
- **Socket.IO:** `ApiConstants.webSocketUrl` / namespace trading — dùng cho feed giá, v.v.

## i18n

ARB trong `lib/l10n/`; chạy `flutter gen-l10n`. Locale lưu `SharedPreferences` qua **`LocaleProvider`** (`lib/core/providers/locale_provider.dart`); đổi ngôn ngữ tại **Settings** (và các chỗ bind `LocaleProvider` khác nếu có).

## Tài liệu thêm

- [README.md](README.md) — cài đặt, chạy, backend kèm theo
- [scripts/README-FLUTTER.md](scripts/README-FLUTTER.md) — script cài Flutter trên Windows
