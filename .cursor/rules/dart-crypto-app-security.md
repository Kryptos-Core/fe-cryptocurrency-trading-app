---
paths:
  - "**/*.dart"
  - "**/lib/core/wallet_auth/**"
  - "**/lib/data/datasources/**"
---
# Dart/Flutter Crypto App Security

> Quy tắc bảo mật đặc thù cho ứng dụng giao dịch crypto.
> Extends: [dart-security.md](./dart-security.md) và [common-security.md](./common-security.md)

## Private Keys và Seed Phrases — KHÔNG BAO GIỜ

```dart
// BAD: Lưu private key vào SharedPreferences (plaintext)
await prefs.setString('private_key', walletPrivateKey);

// BAD: Log wallet address kèm balance
debugPrint('User wallet: $address, balance: $balance');

// BAD: Truyền private key qua state/provider
walletProvider.setKey(privateKey);

// GOOD: Dùng flutter_secure_storage cho dữ liệu nhạy cảm
const storage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);
await storage.write(key: 'auth_token', value: token);
```

**Quy tắc cứng:**
- Private keys, seed phrases **không được lưu trên thiết bị** dưới bất kỳ hình thức nào (kể cả encrypted nếu không phải Secure Enclave)
- Sử dụng `flutter_secure_storage` cho JWT, refresh token, session data
- Không bao giờ truyền private key qua Navigator arguments, Provider state, hoặc URL

## Auth Token Management

```dart
// GOOD: Token storage an toàn
class SecureTokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> saveTokens({required String access, required String refresh}) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: access),
      _storage.write(key: _refreshTokenKey, value: refresh),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }
}
```

## Logging — Không Leak Data Nhạy Cảm

```dart
// BAD: Log thông tin nhạy cảm
log('Login success: user=$email, token=$jwtToken');
log('Order created: userId=$userId, wallet=$walletAddress, amount=$amount');

// GOOD: Log chỉ metadata
log('Login success: userId=${user.id}');
log('Order created: orderId=${order.id}, market=${order.marketId}');
```

**Quy tắc:**
- Không log: JWT token, wallet address, balance, private key, seed phrase, email+password kết hợp
- Chỉ log: ID, trạng thái, metadata không nhạy cảm
- Production builds: disable verbose logging (`kDebugMode` guard)

## API Endpoints — Không Hardcode

```dart
// BAD
const baseUrl = 'https://api.cryptoapp.vn/v1';
const wsUrl = 'wss://ws.cryptoapp.vn';

// GOOD: Đọc từ dart-define hoặc .env
class ApiConfig {
  static const baseUrl = String.fromEnvironment('API_BASE_URL');
  static const wsUrl = String.fromEnvironment('WS_URL');

  static void validate() {
    if (baseUrl.isEmpty) throw StateError('API_BASE_URL not configured');
    if (wsUrl.isEmpty) throw StateError('WS_URL not configured');
  }
}
```

## WalletConnect / Blockchain

```dart
// BAD: Lưu session key của WalletConnect vào SharedPreferences
await prefs.setString('wc_session', wcSession.toJson());

// GOOD: Dùng secure storage
await storage.write(key: 'wc_session_v2', value: jsonEncode(wcSession.toJson()));

// BAD: Log transaction data đầy đủ
debugPrint('Tx broadcast: $rawTransaction');

// GOOD: Log chỉ tx hash sau khi broadcast
log('Tx broadcast success: txHash=${result.hash}');
```

## Xác nhận Giao dịch Quan trọng

Các thao tác tài chính (đặt lệnh, rút tiền) PHẢI yêu cầu xác nhận:

```dart
// GOOD: Confirmation dialog trước khi submit order
Future<bool> confirmOrderSubmission(BuildContext context, Order order) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false, // Không dismiss bằng cách tap ngoài
    builder: (_) => OrderConfirmationDialog(order: order),
  ) ?? false;
}
```

## Network Security

- Tất cả API calls phải qua HTTPS (enforce trong Dio interceptor)
- Certificate pinning cho production builds (optional nhưng recommended)
- Timeout hợp lý: connect 10s, receive 30s
- Không tắt SSL verification kể cả trong dev

```dart
// BAD
(dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
  client.badCertificateCallback = (_, __, ___) => true; // NGUY HIỂM
  return client;
};

// GOOD: chỉ dùng proxy trong dev, không tắt SSL
```
