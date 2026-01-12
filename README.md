# Cryptocurrency Trading App - Flutter

Ứng dụng giao dịch tiền ảo được xây dựng với Flutter.

## Yêu cầu hệ thống

### 1. Flutter SDK
- Version: 3.38.6 trở lên
- Download: https://flutter.dev/docs/get-started/install/windows
- Cài đặt:
  1. Tải Flutter SDK (zip)
  2. Giải nén vào `C:\src\flutter`
  3. Thêm `C:\src\flutter\bin` vào PATH environment variable
  4. Khởi động lại terminal

### 2. JDK 17
- Version: JDK 17 (bắt buộc cho Android build)
- Download: https://adoptium.net/temurin/releases/?version=17
- Cài đặt:
  1. Tải JDK 17 Windows x64 MSI
  2. Chạy installer
  3. Set biến môi trường:
     ```powershell
     [Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-17", "User")
     ```

### 3. Android SDK
- Cài đặt Android Command Line Tools:
  1. Tải: https://developer.android.com/studio#command-tools
  2. Giải nén vào `C:\Android\cmdline-tools\latest`
  3. Set biến môi trường:
     ```powershell
     [Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", "C:\Android", "User")
     [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Android\cmdline-tools\latest\bin;C:\Android\platform-tools;C:\Android\emulator", "User")
     ```
  4. Cài SDK packages:
     ```powershell
     sdkmanager --sdk_root=C:\Android "platform-tools" "build-tools;34.0.0" "platforms;android-34" "cmdline-tools;latest" "ndk;28.2.13676358" "emulator" "system-images;android-34;google_apis;x86_64"
     ```
  5. Accept licenses:
     ```powershell
     sdkmanager --sdk_root=C:\Android --licenses
     ```

### 4. Android Emulator (Optional)
Tạo Android Virtual Device:
```powershell
avdmanager create avd -n "pixel_6_api_34" -k "system-images;android-34;google_apis;x86_64" --device "pixel_6"
```

## Cài đặt dự án

### 1. Clone repository
```bash
git clone https://gitlab.duthu.net/cryptocurrency-trading-app/fe-cryptocurrency-trading-app.git
cd fe-cryptocurrency-trading-app
```

### 2. Cài dependencies
```bash
flutter pub get
```

### 3. Kiểm tra môi trường
```bash
flutter doctor
```

## Chạy ứng dụng

### Web (nhanh nhất)
```bash
flutter run -d chrome
```

### Android Emulator
1. Mở emulator (terminal riêng):
   ```bash
   emulator -avd pixel_6_api_34
   ```

2. Chạy app (terminal khác):
   ```bash
   flutter run
   ```

### Android Device (thiết bị thật)
1. Bật Developer Mode trên điện thoại
2. Bật USB Debugging
3. Kết nối USB
4. Chạy:
   ```bash
   flutter run
   ```

## Hot Reload

Khi app đang chạy:
- `r` - Hot reload (giữ state, nhanh)
- `R` - Hot restart (reset state)
- `q` - Thoát app

Cách dùng:
1. Sửa code trong VS Code
2. Save file (Ctrl+S)
3. Nhấn `r` trong terminal

## Kiến trúc dự án

Xem chi tiết trong file `ARCHITECTURE.md`

```
lib/
├── core/               # Constants, DI, Error handling, Network
├── data/              # Models, Repositories, Data sources
├── domain/            # Entities, Use cases, Repository interfaces
└── presentation/      # Screens, Widgets, Providers
```

## Tech Stack

- Flutter 3.38.6
- Dart 3.0+
- State Management: Provider
- Networking: Dio + Retrofit
- DI: GetIt
- Local DB: Hive
- Charts: FL Chart

## Troubleshooting

### Lỗi: JAVA_HOME not set
```powershell
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:Path += ";$env:JAVA_HOME\bin"
```

### Lỗi: Flutter command not found
Thêm Flutter vào PATH:
```powershell
$env:Path += ";C:\src\flutter\bin"
```

### Lỗi: Android SDK not found
```powershell
flutter config --android-sdk "C:\Android"
```

### Lỗi: Gradle build failed
Đảm bảo đang dùng JDK 17, không phải JDK 25.

## Commands hữu ích

```bash
# Xem devices khả dụng
flutter devices

# Xem emulators
flutter emulators

# Clean build cache
flutter clean

# Update dependencies
flutter pub upgrade

# Format code
dart format .

# Analyze code
flutter analyze
```

## Backend API

Base URL: `http://localhost:3000/api`

Xem chi tiết endpoints trong `lib/core/constants/api_constants.dart`