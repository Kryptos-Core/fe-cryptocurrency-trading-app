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
│   ├── wallet_auth/          # WalletBrandLoginConnector + resolver (web / desktop / mobile)
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

## Thư viện chính (tóm tắt)

| Thành phần | Package |
|------------|---------|
| State | `provider` |
| DI | `get_it` |
| HTTP | `dio` |
| JSON | `json_annotation` + codegen |
| Local | `shared_preferences`, `hive` |
| Realtime | `socket_io_client` |
| Biểu đồ (Windows) | Lightweight Charts qua `webview_windows` |
| i18n | `flutter_localizations` + ARB |
| Push (mobile) | `firebase_core`, `firebase_messaging`, local notifications |

## Màn hình tiêu biểu (`lib/screens/`)

Auth & shell: `login_screen`, `register_screen`, `main_screen`, `home_screen`, `settings_screen`, `profile_screen`.

Giao dịch & thị trường: `markets_list_screen`, `market_detail_screen`, `advanced_trading_screen`, `orders_screen`, `dashboard_screen`, `currencies_list_screen`, `currency_detail_screen`.

Ví & nạp: `wallets_overview_screen`, `wallet_detail_screen`, `deposits_screen`, `wallet_api_screen`, …

**Ví / WalletConnect:** **Đăng nhập** — `wallet_connect_auth_login_dialog.dart`: **Android/iOS** — Reown AppKit (`reown_appkit`, `reown_wallet_auth_config.dart`) → `/auth/wallet-verify`. **Desktop native** — QR từ **`POST /auth/wallet/wc/init`** (server **SignClient** + relay khi có project id; poll `status`). **Web** — extension (bridge JS); WC modal tùy chọn — xem [`docs/WALLETCONNECT_FLUTTER_WEB.md`](docs/WALLETCONNECT_FLUTTER_WEB.md). **Liên kết ví (đã JWT)** — `link_wallet_dialog.dart`, `wc_qr_session_card`, `wc_deeplink_launcher`, … (QR **`/blockchain/wallets/wc/*`**). Tron (web): TronLink. Biến môi trường & API: [`../be-cryptocurrency-trading-app/docs/WALLETCONNECT.md`](../be-cryptocurrency-trading-app/docs/WALLETCONNECT.md) (bảng **Primary stack**).

## Guest và tích xanh email

**Guest** = chưa đăng nhập (không JWT), không phải `role` trên server. **Tích xanh** (`Icons.verified`) khi `email_verified` (OTP / xác minh inbox). Khác với KYC (`identity_verified`).

Admin / vận hành: `admin_user_list_screen`, `admin_user_detail_screen`, `admin_transactions_screen`, `admin_currencies_screen`, `admin_wallet_adjust_screen`, `security_requests_review_screen`, `broadcast_notification_screen`, …

Market maker: `market_maker/market_maker_hub_screen`, `market_maker_config_screen`.

## Mạng & realtime

- **HTTP:** `ApiConstants.baseUrl` (từ `.env` `BASE_URL` hoặc default theo nền tảng). Android emulator: `http://10.0.2.2:3000/api/v1`.
- **Socket.IO:** `ApiConstants.webSocketUrl` / namespace trading — dùng cho feed giá, v.v.

## i18n

ARB trong `lib/l10n/`; chạy `flutter gen-l10n`. Locale lưu `SharedPreferences` qua **`LocaleProvider`** (`lib/core/providers/locale_provider.dart`); đổi ngôn ngữ tại **Settings** (và các chỗ bind `LocaleProvider` khác nếu có).