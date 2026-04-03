# Kryptos Core — Flutter App

Ứng dụng desktop / web / Android (**package:** `crypto_trading_app`). Gọi API NestJS qua REST (**Dio**) và realtime (**Socket.IO**).

## Yêu cầu

- **Flutter SDK:** `>=3.0.0 <4.0.0` (xem [`pubspec.yaml`](pubspec.yaml))
- **Android:** JDK 17 + Android SDK (khi build Android)
- **Windows:** Visual Studio workload “Desktop development with C++” (khi build Windows)

```bash
flutter doctor -v
```

## Cài đặt và chạy

```bash
cd fe-cryptocurrency-trading-app
flutter pub get
```

**`.env` (bắt buộc):** copy từ `.env.example`, chỉnh `BASE_URL` (phải kèm `/api/v1`):

| Môi trường | `BASE_URL` gợi ý |
|------------|------------------|
| Windows / Chrome / Edge | `http://127.0.0.1:3000/api/v1` |
| Android Emulator | `http://10.0.2.2:3000/api/v1` |
| Thiết bị thật (cùng WiFi) | `http://<IP-máy-BE>:3000/api/v1` |

```bash
# Thiết bị mặc định
flutter run

flutter run -d chrome    # web
flutter run -d windows   # Windows desktop
flutter devices
```

Trong session `flutter run`: `r` hot reload, `R` hot restart, `q` thoát.

**Localization** — sau khi sửa `lib/l10n/*.arb`:

```bash
flutter gen-l10n
```

## Backend (cùng workspace)

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

## Gỡ lỗi thường gặp

**Connection refused / không gọi được API**

- Backend đã chạy, đúng cổng (thường `3000`).
- Emulator Android: dùng `10.0.2.2`, không dùng `localhost` của máy host.
- `BASE_URL` trong `.env` có đuôi `/api/v1`.

**401 sau một thời gian**

- Token hết hạn — đăng nhập lại.

**Đồ thị / cặp không có dữ liệu**

- Backend đã seed/sync markets; xem gợi ý trong [`.env.example`](.env.example).

**Lệnh khác**

```bash
flutter analyze
dart format lib
dart run build_runner build --delete-conflicting-outputs   # khi đổi model có annotation
flutter clean && flutter pub get
```

## Tài liệu thêm

- Kiến trúc & màn hình: [`ARCHITECTURE.md`](ARCHITECTURE.md)
- Script hỗ trợ (nếu có): [`scripts/README-FLUTTER.md`](scripts/README-FLUTTER.md)
