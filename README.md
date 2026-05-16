# Kryptos Core — Flutter App

Ứng dụng giao dịch tiền mã hóa đa nền tảng (Windows, Chrome/Edge, Android). Kết nối backend qua REST và Socket.IO.

## Tính năng chính

- Đăng nhập, giao dịch và theo dõi thị trường
- Biểu đồ realtime
- Liên kết ví & WalletConnect
- Đa nền tảng: Windows, Web, Android

## Yêu cầu

- **Flutter SDK** `>=3.0.0 <4.0.0` (xem [pubspec.yaml](pubspec.yaml))
- **Android:** JDK 17 + Android SDK
- **Windows:** Visual Studio Desktop development workload

Kiểm tra môi trường:

```bash
flutter doctor -v
```

## Cài đặt và chạy

### 1. Backend cần chạy trước

Backend phải đang chạy tại `http://127.0.0.1:3000/api/v1`.

### 2. Cài đặt Flutter

```bash
cd fe-cryptocurrency-trading-app
flutter pub get
```

### 3. Biến môi trường

Tạo file `.env` từ `.env.example`. `BASE_URL` phải có hậu tố `/api/v1`.

| Môi trường | BASE_URL |
|------------|----------|
| Windows / Chrome / Edge | http://127.0.0.1:3000/api/v1 |
| Android Emulator | http://10.0.2.2:3000/api/v1 |
| Thiết bị thật (cùng Wi-Fi) | http://<IP-máy-BE>:3000/api/v1 |

### 4. Chạy app

```bash
flutter run
flutter run -d chrome
flutter run -d windows
```

| Phím tắt | Chức năng |
|----------|-----------|
| `r` | Hot reload |
| `R` | Hot restart |
| `q` | Thoát |

## Scripts hữu ích

```bash
flutter analyze --fatal-infos   # Lint + type check
dart run import_lint            # Import layer lint
dart format lib                 # Format code
flutter test                    # Run tests
flutter clean && flutter pub get  # Reset cache
```

## Gỡ lỗi thường gặp

| Vấn đề | Giải pháp |
|--------|-----------|
| Connection refused | Backend đã bật; Android dùng `10.0.2.2` thay `localhost` |
| 401 lâu dần | Token hết hạn — đăng nhập lại |
| Thiếu dữ liệu biểu đồ | Backend đã migration + seed + sync |

## Kiến trúc

Chi tiết kiến trúc, routing, lint layer: [ARCHITECTURE.md](ARCHITECTURE.md).
