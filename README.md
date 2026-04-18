# Kryptos Core — Flutter App

Ứng dụng **crypto_trading_app**: desktop, web và Android. Kết nối backend qua REST và Socket.IO.

## Tính năng (tổng quan)

- Đăng nhập, giao dịch và theo dõi thị trường qua API backend  
- Biểu đồ, realtime (theo khả năng backend và cấu hình)  
- Đa nền tảng: Windows desktop, Chrome/Edge, Android  

Kiến trúc màn hình và cấu trúc code: [`ARCHITECTURE.md`](ARCHITECTURE.md) (không thay thế README này về bước chạy app).

## Yêu cầu

- **Flutter SDK** `>=3.0.0 <4.0.0` (xem [`pubspec.yaml`](pubspec.yaml))  
- **Android:** JDK 17 + Android SDK khi build Android  
- **Windows:** Visual Studio workload “Desktop development with C++” khi build Windows  

```bash
flutter doctor -v
```

## Pin CMake toolchain (CI/local)

Để tránh khác biệt giữa máy dev, FE pin version Flutter + CMake tại `tools/toolchain-versions.json`.

- **CI:** workflow Windows dùng đúng Flutter/CMake pin trong file này.
- **Local (Windows):** chạy script sau để tải CMake đúng version và prepend vào PATH terminal hiện tại:

```powershell
cd scripts
.\pin-cmake-windows.ps1
```

Tài liệu chi tiết: `scripts/README-FLUTTER.md`.

## Cài đặt và chạy

```bash
cd fe-cryptocurrency-trading-app
flutter pub get
```

**`.env`:** copy từ `.env.example`. `BASE_URL` phải có hậu tố **`/api/v1`**.

| Môi trường | `BASE_URL` gợi ý |
|------------|------------------|
| Windows / Chrome / Edge | `http://127.0.0.1:3000/api/v1` |
| Android Emulator | `http://10.0.2.2:3000/api/v1` |
| Thiết bị thật (cùng Wi-Fi) | `http://<IP-máy-chạy-BE>:3000/api/v1` |

```bash
flutter run
flutter run -d chrome
flutter run -d windows
flutter devices
```

Trong `flutter run`: `r` hot reload, `R` hot restart, `q` thoát.

Sau khi sửa `lib/core/l10n/*.arb`:

```bash
flutter gen-l10n
```

## Backend cần chạy trước

## Gỡ lỗi thường gặp

- **Connection refused:** BE đã bật đúng cổng; Android emulator dùng `10.0.2.2`, không dùng `localhost` của máy host; `BASE_URL` kết thúc bằng `/api/v1`.  
- **401 lâu dần:** token hết hạn — đăng nhập lại.  
- **Thiếu dữ liệu biểu đồ / cặp:** đảm bảo BE đã migration + seed và cấu hình sync (xem `.env.example` của BE).

**Lệnh hữu ích**

```bash
flutter analyze --fatal-infos
dart run import_lint
dart format lib
dart run build_runner build --delete-conflicting-outputs
flutter clean && flutter pub get
flutter test
```

Chi tiết kiến trúc, routing, lint layer: [`ARCHITECTURE.md`](ARCHITECTURE.md). Cấu trúc test: [`test/README.md`](test/README.md).