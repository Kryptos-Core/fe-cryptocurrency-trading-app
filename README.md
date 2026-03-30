# Kryptos Core — Flutter App

Ứng dụng desktop/web/Android cho nền tảng giao dịch (**package:** `crypto_trading_app`). Giao tiếp với backend NestJS qua REST (**Dio**) và realtime (**Socket.IO**).

## Yêu cầu

- **Flutter SDK:** `>=3.0.0 <4.0.0` (xem [`pubspec.yaml`](pubspec.yaml))
- **Dart:** đi kèm Flutter
- **Android:** JDK 17, Android SDK (khi build/run Android)
- **Windows:** Visual Studio workload “Desktop development with C++” (khi build Windows)

Kiểm tra môi trường:

```bash
flutter doctor -v
```

## Cài đặt

```bash
cd fe-cryptocurrency-trading-app
flutter pub get
```

### Cấu hình API (bắt buộc)

```bash
copy .env.example .env
```

Chỉnh `BASE_URL` trong `.env` (phải **kèm** `/api/v1`):

| Môi trường chạy app | `BASE_URL` gợi ý |
|---------------------|------------------|
| Windows / Chrome / Edge | `http://127.0.0.1:3000/api/v1` |
| Android Emulator | `http://10.0.2.2:3000/api/v1` |
| Máy thật (cùng WiFi) | `http://<IP-máy-chạy-BE>:3000/api/v1` |

Ứng dụng load `.env` lúc khởi động (`flutter_dotenv`). Chi tiết logic URL: [`lib/core/constants/api_constants.dart`](lib/core/constants/api_constants.dart).

### Localization

Sau khi sửa `lib/l10n/*.arb`:

```bash
flutter gen-l10n
```

## Chạy ứng dụng

```bash
# Thiết bị mặc định
flutter run

# Web (nhanh cho UI)
flutter run -d chrome

# Windows desktop
flutter run -d windows

# Liệt kê thiết bị
flutter devices
```

Trong session `flutter run`: `r` hot reload, `R` hot restart, `q` thoát.

## Backend

Backend NestJS là **`be-cryptocurrency-trading-app`** (cùng workspace). Khởi chạy tối thiểu:

```bash
cd ../be-cryptocurrency-trading-app
npm install
cp env.example .env
# MySQL + Redis (docker-compose.infrastructure.yml)
npm run migration:run
npm run db:seed
npm run start:dev
```

Kiểm tra: `GET http://127.0.0.1:3000/api/v1/health`

**Wallet / đăng nhập ví:** đặt **`WALLETCONNECT_PROJECT_ID`** (hoặc `REOWN_PROJECT_ID`) trong `.env` FE; **cùng Project ID** trong `.env` BE. Chi tiết luồng (Reown mobile, QR legacy, API): [`be-cryptocurrency-trading-app/docs/WALLETCONNECT.md`](../be-cryptocurrency-trading-app/docs/WALLETCONNECT.md).

## Kiến trúc mã nguồn

```
lib/
├── main.dart
├── core/                 # constants, DI (GetIt), network (Dio), utils
├── data/                 # models, datasources, repository implementations
├── domain/               # entities, repository contracts, use cases
├── presentation/         # providers (Provider), widgets, một số màn feature
├── screens/              # màn hình chính (home, admin, orders, wallets, …)
├── gen_l10n/             # generated — không sửa tay
└── l10n/                 # app_en.arb, app_vi.arb
```

Mô tả sâu hơn: [`ARCHITECTURE.md`](ARCHITECTURE.md).

## Công nghệ chính

| Thành phần | Thư viện |
|------------|----------|
| State (UI) | `provider` |
| Dependency injection | `get_it` |
| HTTP | `dio` |
| JSON models | `json_annotation` + `json_serializable` / `freezed` (nơi dùng) |
| Lưu local | `shared_preferences`, `hive` |
| Realtime | `socket_io_client` (namespace trading; origin từ `ApiConstants`) |
| Biểu đồ | Lightweight Charts qua `webview_windows` (Windows) |
| Đa ngôn ngữ | `flutter_localizations` + ARB |
| Push (mobile) | `firebase_core`, `firebase_messaging`, local notifications |

## Lệnh hữu ích

```bash
flutter analyze
dart format lib

# Sinh code (khi đổi model có annotation)
dart run build_runner build --delete-conflicting-outputs

flutter clean && flutter pub get   # khi build lỗi cache
```

## Gỡ lỗi thường gặp

**Không gọi được API / connection refused**

- Backend đã chạy và đúng cổng `3000`.
- Android emulator: dùng `10.0.2.2`, không dùng `localhost` của máy host.
- Kiểm tra `BASE_URL` trong `.env` có đuôi `/api/v1`.

**401 sau một thời gian**

- Token hết hạn — đăng nhập lại; interceptor có thể đã xóa token và đưa về màn login.

**Đồ thị / cặp không có dữ liệu**

- Đảm bảo backend đã seed/sync markets; xem gợi ý trong [`.env.example`](.env.example) (đồng bộ exchange, khởi động lại BE nếu cần).

## Nền tảng

Dự án có **Windows**, **Web**, **Android**. Không có thư mục `ios/` trong repo hiện tại.

## Script bổ sung

- [`scripts/README-FLUTTER.md`](scripts/README-FLUTTER.md) — ghi chú script hỗ trợ Flutter (nếu có).
