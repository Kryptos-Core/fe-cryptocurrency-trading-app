# Cài Flutter trên Windows & set biến môi trường

## Cách 1: Script tự động (khi mạng kết nối GitHub được)

Mở **PowerShell** (hoặc Terminal trong Cursor) và chạy:

```powershell
cd D:\Sources\cryptocurrency-trading-app\fe-cryptocurrency-trading-app\scripts
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
cd D:\Sources\cryptocurrency-trading-app\fe-cryptocurrency-trading-app\scripts
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
