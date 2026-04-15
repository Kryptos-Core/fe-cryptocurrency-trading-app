# Cài Flutter trên Windows & set biến môi trường

## Cách 1: Script tự động (khi mạng kết nối GitHub được)

Mở **PowerShell** (hoặc Terminal trong Cursor) và chạy từ thư mục `scripts` của repo FE:

```powershell
cd path\to\fe-cryptocurrency-trading-app\scripts
.\install-flutter-windows.ps1
```

Script sẽ:
- Clone Flutter (nhánh stable) vào `C:\src\flutter`
- Set biến môi trường **User**: `FLUTTER_ROOT` và thêm `flutter\bin` vào **PATH**
- Chạy `flutter --version` lần đầu (có thể tải thêm Dart SDK)

**Lưu ý:** Nếu báo lỗi kết nối GitHub (proxy/127.0.0.1), tắt VPN/proxy tạm hoặc dùng Cách 2.

---

## Cách 2: Tải ZIP rồi set biến môi trường

1. Vào [Flutter SDK archive – Windows](https://docs.flutter.dev/install/archive) → chọn bản **Stable** → tải file **Windows (zip)**.
2. Giải nén vào thư mục, ví dụ: `C:\src\flutter` (sao cho có đường dẫn `C:\src\flutter\bin\flutter.bat`).
3. Chạy script chỉ set biến môi trường:

```powershell
cd path\to\fe-cryptocurrency-trading-app\scripts
.\set-flutter-env.ps1 -FlutterPath "C:\src\flutter"
```

(Đổi `C:\src\flutter` nếu bạn giải nén ở chỗ khác.)

---

## Biến môi trường được set (User)

| Tên           | Ví dụ giá trị   |
|---------------|------------------|
| `FLUTTER_ROOT`| `C:\src\flutter` |
| `Path`        | Thêm `%FLUTTER_ROOT%\bin` (hoặc `C:\src\flutter\bin`) |

---

## Sau khi cài

1. **Để terminal hiện tại nhận lệnh `flutter` ngay** (không cần restart), chạy:
   ```powershell
   $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
   ```
2. Hoặc **đóng hết terminal rồi mở terminal mới** (hoặc restart Cursor).
3. Kiểm tra:

```powershell
flutter --version
flutter doctor
```

3. Nếu `flutter doctor` báo thiếu (Android Studio, VS Code, v.v.), cài thêm theo hướng dẫn trên màn hình.

---

## Windows desktop build: dùng Visual Studio auto-detect

Với Flutter trên Windows, nên để Flutter/CMake **tự nhận diện** Visual Studio Build Tools hoặc Visual Studio Community đã cài trong máy. Không nên mặc định set sẵn các biến như `CMAKE_GENERATOR`, `CMAKE_GENERATOR_INSTANCE`, `CMAKE_GENERATOR_PLATFORM`, vì nếu giá trị cũ trỏ nhầm sang một instance không còn tồn tại thì `flutter run -d windows` sẽ fail dù toolchain thực tế vẫn hợp lệ.

Khuyến nghị:

1. Cài **Visual Studio Build Tools** hoặc **Visual Studio Community** có workload **Desktop development with C++**.
2. Kiểm tra toolchain:

```powershell
flutter doctor -v
```

3. Nếu `flutter doctor -v` đã nhận Windows toolchain, chạy build bình thường:

```powershell
flutter clean
flutter pub get
flutter run -d windows
```

## Nếu từng set nhầm biến CMake trước đó

Một lỗi dễ gặp là terminal hoặc User Environment vẫn còn giữ cấu hình cũ, ví dụ trỏ sang một bản Visual Studio Insiders/Community không còn đúng nữa. Khi đó CMake có thể báo lỗi kiểu:

```text
could not find specified instance of Visual Studio
```

### Reset trong terminal hiện tại

Chạy các lệnh sau trong PowerShell để xoá override khỏi phiên terminal đang mở:

```powershell
Remove-Item Env:CMAKE_GENERATOR -ErrorAction SilentlyContinue
Remove-Item Env:CMAKE_GENERATOR_INSTANCE -ErrorAction SilentlyContinue
Remove-Item Env:CMAKE_GENERATOR_PLATFORM -ErrorAction SilentlyContinue
flutter clean
flutter run -d windows
```

### Xoá luôn ở User Environment

Nếu trước đây bạn đã lưu các biến đó ở mức **User**, xoá luôn để tránh lặp lại lỗi ở các terminal mới:

```powershell
[Environment]::SetEnvironmentVariable("CMAKE_GENERATOR", $null, "User")
[Environment]::SetEnvironmentVariable("CMAKE_GENERATOR_INSTANCE", $null, "User")
[Environment]::SetEnvironmentVariable("CMAKE_GENERATOR_PLATFORM", $null, "User")
```

Sau đó đóng toàn bộ terminal/VS Code rồi mở lại.

## Pin CMake version cho local (khớp CI)

Repo FE có file version nguồn duy nhất tại `tools/toolchain-versions.json` (Flutter + CMake).

Để tải đúng bản CMake đã pin và inject vào terminal hiện tại:

```powershell
cd path\to\fe-cryptocurrency-trading-app\scripts
.\pin-cmake-windows.ps1
```

Nếu muốn ghi vào User PATH (persist qua terminal mới):

```powershell
.\pin-cmake-windows.ps1 -PathScope User
```

Nếu cần tải lại sạch bản đã pin:

```powershell
.\pin-cmake-windows.ps1 -ForceDownload
```

Script sẽ tải CMake portable vào thư mục `.toolchains/` trong repo FE, nên không cần quyền admin.

## Khi nào mới nên override CMake generator?

Chỉ nên tự set `CMAKE_GENERATOR*` khi bạn có lý do rõ ràng và đã xác minh chính xác generator + instance path đang dùng. Đây là trường hợp ngoại lệ để debug môi trường build, không phải cấu hình mặc định nên lưu lâu dài trong máy.
