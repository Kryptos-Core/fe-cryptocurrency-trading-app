# Security zones — Flutter app

> Last reviewed: 2026-07-28 — verified against `lib/features/` + `lib/core/wallet_auth/`.

Code xử lý ví / token / giao dịch — ưu tiên review và test ở các khu sau.

| Khu | Rủi ro | Ghi chú |
|-----|--------|---------|
| `lib/core/wallet_auth/` | Cao | Multi-platform wallet connector (desktop/mobile/web). Session WC, không log ví + balance cùng lúc; không lưu seed/private key trong `SharedPreferences`. |
| `lib/features/auth/` | Cao | Login/register; ô nhập seed/cụm từ `obscureText`, không log credential. |
| `lib/features/orders/`, `lib/features/trading/` | Cao | Submit lệnh: confirm, validate amount/price. |
| `lib/features/withdrawals/`, `lib/features/deposits/` | Cao | Confirm trước khi rút/nạp; kiểm tra amount/address/symbol. |
| `lib/features/binance_trading/` | Cao | API keys của user được mã hóa AES-256-GCM trên server; FE chỉ lưu credentialId tham chiếu qua `flutter_secure_storage`; `obscureText` cho API Key/Secret input; không log credentials. |
| `lib/features/treasury/`, `lib/features/managed_wallets/` | Cao | Thao tác ví vận hành / hot wallet; confirm + double-check role. |
| `lib/features/notifications/` | Trung bình-Cao | FCM token / socket; không log payload nhạy cảm (balance, address). |
| `lib/core/network/`, `lib/features/*/data/datasources/` | Cao | JWT qua interceptor; không forward raw API error ra UI nhạy cảm. |
| `lib/features/*/domain/` | Trung bình | Không import Flutter/Dio/Hive/secure_storage/local storage package. |

Trước PR: không `print` dữ liệu nhạy cảm; token/khóa không trong prefs thường; domain không import Flutter/Dio. Chi tiết rule: [dart-crypto-app-security.md](../.cursor/rules/dart-crypto-app-security.md).

