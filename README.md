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

### Web (Nhanh nhất - Recommended)
Không cần setup Android emulator, test ngay lập tức:
```bash
flutter run -d chrome
```
Perfect cho frontend development & testing  
Hot reload cực nhanh  
Không cần emulator setup phức tạp

### Android Emulator
1. **Chạy emulator** (terminal riêng):
   ```powershell
   # Nếu emulator không trong PATH, dùng full path:
   C:\Android\emulator\emulator.exe -avd pixel_6_api_34
   
   # Hoặc nếu đã add vào PATH:
   emulator -avd pixel_6_api_34
   ```
   Chờ emulator boot xong (1-2 phút)

2. **Chạy app** (terminal khác):
   ```bash
   flutter run
   ```
   Sau đó chọn Android emulator từ danh sách

### Web (nhanh nhất - Legacy command)
```bash
flutter run -d chrome
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

- **Flutter**: 3.38.6
- **Dart**: 3.0+
- **State Management**: GetIt (Service Locator pattern - no Provider needed)
- **Networking**: Dio 5.4.0 với custom interceptors
- **Local Storage**: SharedPreferences 2.2.2 (JWT tokens)
- **Error Handling**: dartz (Either<Failure, Success> pattern)
- **Architecture**: Clean Architecture (5 layers)

### Key Dependencies
```yaml
dependencies:
  dio: ^5.4.0                    # HTTP client
  get_it: ^7.6.0                # Dependency injection
  shared_preferences: ^2.2.2     # Token storage
  dartz: ^0.10.1                # Functional programming (Either)
  equatable: ^2.0.5             # Value equality
```

## Troubleshooting

### Lỗi: emulator không được recognize
**Triệu chứng:** `emulator: The term 'emulator' is not recognized...`

**Nguyên nhân:** Android emulator không trong PATH

**Giải pháp:**
```powershell
# Option 1: Thêm emulator vào PATH (lâu dài)
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Android\emulator", "User")
# Sau đó restart terminal mới

# Option 2: Dùng full path (nhanh)
C:\Android\emulator\emulator.exe -avd pixel_6_api_34

# Option 3: Dùng Android Studio GUI
# Mở Android Studio → Tools → Device Manager → Create device
```

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

### Lỗi: "Connected devices" không có Android emulator
**Triệu chứng:** Chỉ thấy Windows/Chrome/Edge, không thấy Android emulator
```
Connected devices:
Windows (desktop) • windows • windows-x64
Chrome (web)      • chrome  • web-javascript
Edge (web)        • edge    • web-javascript
```

**Nguyên nhân:** 
- Emulator chưa được tạo
- Emulator không được chạy
- PATH chưa setup đúng

**Giải pháp:**
```powershell
# Bước 1: Kiểm tra emulator đã tạo chưa
C:\Android\emulator\emulator.exe -list-avds

# Bước 2: Nếu không có, tạo emulator
C:\Android\cmdline-tools\latest\bin\avdmanager.bat create avd -n "pixel_6_api_34" -k "system-images;android-34;google_apis;x86_64" --device "pixel_6"

# Bước 3: Chạy emulator
C:\Android\emulator\emulator.exe -avd pixel_6_api_34
# Chờ emulator boot xong (1-2 phút)

# Bước 4: Mở terminal khác, chạy app
flutter run
# Lúc này sẽ thấy emulator trong danh sách
```

**Quick Fix: Dùng Web để test**
```powershell
# Nếu emulator setup phức tạp, test bằng web (nhanh & simple)
flutter run -d chrome
```
Web không cần emulator, chạy ngay  
Hot reload cực nhanh  
Perfect cho frontend testing

### Lỗi: Connection refused khi call API
**Triệu chứng:** DioException [connection error]: The connection errored...

**Nguyên nhân:** Android emulator không thể truy cập `localhost` của máy host

**Giải pháp:** 
- Kiểm tra backend đang chạy: `curl http://localhost:3000/api/v1/health`
- Trong code dùng `http://10.0.2.2:3000/api/v1` cho Android emulator
- Nếu dùng web hoặc thiết bị thật, dùng IP thật của máy (ví dụ: `http://192.168.1.100:3000/api/v1`)

### Lỗi: 401 Unauthorized
**Nguyên nhân:** Token hết hạn hoặc không hợp lệ

**Giải pháp:**
- App sẽ tự động clear tokens và redirect về login screen
- Đăng nhập lại để lấy token mới

### Lỗi: RangeError (index): Invalid value: Valid value range is empty
**Nguyên nhân:** Backend trả về user với firstName/lastName empty

**Giải pháp:** Đã fix - Code có fallback logic:
- Avatar initials: firstName[0] + lastName[0] → email[0] → "?"
- Display name: firstName + lastName → email

### Lỗi: type 'Null' is not a subtype of type 'String'
**Nguyên nhân:** Backend không trả về refreshToken

**Giải pháp:** Đã fix - refreshToken đã được mark nullable trong models

## Common Issues

### Backend không chạy
```bash
# Check backend status
curl http://localhost:3000/api/v1/health

# Nếu lỗi, restart backend
cd be-cryptocurrency-trading-app
npm run start:dev
```

### App không connect được backend trên Android emulator
Đảm bảo:
1. Backend đang chạy: `http://localhost:3000/api/v1`
2. Code dùng URL: `http://10.0.2.2:3000/api/v1`
3. File config: [lib/core/network/dio_client.dart](lib/core/network/dio_client.dart)

### Hot reload không work sau khi sửa model
```bash
# Stop app (q trong terminal)
# Clean build
flutter clean
flutter pub get
# Run lại
flutter run
```

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

### Yêu cầu Backend
Dự án yêu cầu backend NestJS đang chạy ở `http://localhost:3000/api/v1`

### Clone và setup backend
```bash
# Clone backend repository
git clone https://gitlab.duthu.net/cryptocurrency-trading-app/be-cryptocurrency-trading-app.git
cd be-cryptocurrency-trading-app

# Cài dependencies
npm install

# Chạy database (PostgreSQL/Docker)
docker-compose up -d

# Chạy migration
npm run migration:run

# Start backend
npm run start:dev
```

### Android Emulator Network Config
- Backend URL trong code: `http://10.0.2.2:3000/api/v1` (Android emulator routing)
- `10.0.2.2` = localhost của máy host từ góc nhìn emulator
- Web/Real device: Dùng `http://localhost:3000` hoặc IP thật

### API Endpoints đã implement

#### Authentication
- `POST /auth/register` - Đăng ký (email + password + optional firstName/lastName)
  - **NEW (2025-01-13):** firstName và lastName are now supported
  - Example: `{ email, password, firstName?: "John", lastName?: "Doe" }`
- `POST /auth/login` - Đăng nhập (email + password)

#### User Management
- `GET /users/me` - Lấy thông tin user hiện tại
- `PATCH /users/me` - Cập nhật profile (firstName, lastName)

## Dependency Injection

App sử dụng GetIt cho DI. Tất cả services được register trong [lib/core/di/injection_container.dart](lib/core/di/injection_container.dart):

```dart
// Sử dụng trong code
final tokenService = sl<TokenService>();
final loginUseCase = sl<LoginUseCase>();
```

**Registered Services:**
- TokenService
- AuthRemoteDataSource
- AuthRepositoryImpl
- LoginUseCase, RegisterUseCase, GetCurrentUserUseCase
- DioClient (với custom interceptors)

## Testing

### Test flows
1. **Register Flow**: Tạo tài khoản mới → Verify toast success → Auto-login → Navigate to home
2. **Login Flow**: Login với credentials → Verify token saved → Load profile → Display user info
3. **Logout Flow**: Logout → Confirm dialog → Clear tokens → Navigate to login
4. **Token Expiry**: Đóng app → Mở lại → Verify auto-redirect if token expired