# Security Zones — Flutter Frontend

## Tổng Quan

App Flutter xử lý dữ liệu tài chính nhạy cảm. Mọi thành viên team cần hiểu rõ các vùng rủi ro cao.

## Zones và Mức Độ Rủi Ro

| Module/Path | Risk Level | Mô tả |
|-------------|-----------|-------|
| `lib/core/wallet_auth/` | CRITICAL | WalletConnect session, auth token lifecycle |
| `lib/data/datasources/` | HIGH | API calls, token injection vào requests |
| `lib/core/services/` | HIGH | Local storage, secure storage |
| `lib/screens/trading/` | HIGH | Order submission UI — user-facing financial action |
| `lib/domain/` | MEDIUM | Business logic, use case orchestration |
| `lib/presentation/providers/` | MEDIUM | State management, reactive data |
| `lib/screens/auth/` | HIGH | Login, register, seed phrase entry |

## Quy Tắc Theo Zone

### CRITICAL: `wallet_auth/`

- Private keys và seed phrases **không được lưu trên thiết bị**
- WalletConnect session data lưu bằng `flutter_secure_storage` (không phải `SharedPreferences`)
- Không log wallet address kèm balance
- Test coverage: **100%** cho auth flow

### HIGH: `data/datasources/`

- JWT token phải được inject qua interceptor, không hardcode trong request
- Token refresh logic phải có lock (không gọi refresh đồng thời nhiều lần)
- Error responses không được forwarded raw tới UI (wrap với domain exceptions)

### HIGH: `screens/auth/`

- Seed phrase input field phải dùng `obscureText: true`, tắt autocorrect và autofill
- Không chụp màn hình được khi nhập seed phrase (dùng `FLAG_SECURE` trên Android)
- Biometric auth cần fallback PIN

### HIGH: `screens/trading/`

- Mọi order submission phải có confirmation dialog
- Amount/price input phải validate range (không âm, không quá max)
- Lỗi từ API order phải hiển thị message rõ ràng, không expose internal error

## Dependency Direction

```
screens/ → presentation/providers/ → domain/usecases/
                                    ↓
                              domain/repositories/ (abstract)
                                    ↓
                    data/repositories/ → data/datasources/
```

**Domain layer KHÔNG được import:**
- `package:flutter` (ngoại trừ `Equatable` từ equatable)
- `package:dio` hoặc bất kỳ HTTP client nào
- `package:hive` hoặc local storage packages

## Checklist Trước Khi Submit PR

- [ ] Không có sensitive data trong logs (`debugPrint`, `log`)
- [ ] Token/key không lưu trong `SharedPreferences`
- [ ] Confirmation dialog có trên financial actions
- [ ] Seed phrase input có `obscureText: true`
- [ ] Domain layer không import Flutter/Dio
- [ ] `flutter_secure_storage` được dùng cho data nhạy cảm
