# Đa ngôn ngữ (i18n)

## Cách làm: FE làm chính, BE chỉ trả mã lỗi

- **Frontend (Flutter):** Toàn bộ chuỗi hiển thị cho user (màn hình, nút, lỗi hiển thị) nằm trong app, dịch theo file ARB (en, vi). Dùng **Flutter official**: `flutter gen-l10n` + file `.arb`, không dùng gói bên thứ ba (easy_local, GetX i18n, v.v.).
- **Backend (NestJS):** API trả **mã lỗi ổn định** (ví dụ `AUTH_FAILED`, `INVALID_EMAIL`). App nhận mã rồi map sang chuỗi đã dịch trong ARB. Không lưu/trả chuỗi đa ngôn ngữ từ BE để tránh trùng nội dung và dễ bảo trì.

## Cấu trúc

- `lib/l10n/`: file nguồn `.arb` (app_en.arb, app_vi.arb).
- `lib/gen_l10n/`: code sinh bởi `flutter gen-l10n` (AppLocalizations).
- Locale được lưu trong `LocaleProvider` (SharedPreferences), đổi ngôn ngữ ở màn Profile (chỉ text, không dùng icon cờ).

## Thêm chuỗi mới

1. Thêm key vào `app_en.arb` và `app_vi.arb`.
2. Chạy `flutter gen-l10n` (hoặc `flutter pub get` nếu đã bật `generate: true`).
3. Dùng `AppLocalizations.of(context)!.yourKey` trong widget.
