# Security zones — Flutter app

Code xử lý ví / token / giao dịch — ưu tiên review và test ở các khu sau.

| Khu | Rủi ro | Ghi chú |
|-----|--------|---------|
| `lib/core/wallet_auth/`, blockchain wallet UI | Cao | Session WC, không log ví + balance cùng lúc; không lưu seed/private key trong `SharedPreferences`. |
| `lib/features/auth/` | Cao | Login/register; ô nhập seed/cụm từ `obscureText`, không log credential. |
| `lib/features/orders/`, trading | Cao | Submit lệnh: confirm, validate amount/price. |
| `lib/core/network/`, datasources | Cao | JWT qua interceptor; không forward raw API error ra UI nhạy cảm. |
| `lib/features/binance_trading/` | Cao | API keys của user được mã hóa AES-256-GCM trên server; FE chỉ lưu credentialId tham chiếu qua `flutter_secure_storage`; `obscureText` cho API Key/Secret input; không log credentials. |
| `lib/features/*/domain/` | Trung bình | Không import Flutter/Dio. |

Trước PR: không `print` dữ liệu nhạy cảm; token/khóa không trong prefs thường; domain không import Flutter/Dio. Chi tiết rule: [dart-crypto-app-security.md](../.cursor/rules/dart-crypto-app-security.md).

