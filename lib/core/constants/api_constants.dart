import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'api_base_url_stub.dart' if (dart.library.io) 'api_base_url_io.dart' as api_base_url;

/// API Configuration Constants
/// Following Single Responsibility Principle (SRP)
///
/// Base URL rules (override with .env BASE_URL):
/// - Android Emulator: http://10.0.2.2:3000/api/v1 (10.0.2.2 = host from emulator)
/// - iOS Simulator / Windows / Chrome: http://localhost:3000/api/v1
/// - Physical device (same WiFi): http://<your-PC-IP>:3000/api/v1 (set in .env)
class ApiConstants {
  ApiConstants._();

  static String _serverOrigin() {
    final fromEnv = dotenv.env['BASE_URL'];
    if (fromEnv != null && fromEnv.isNotEmpty) {
      final u = fromEnv.trim();
      final withoutTrailing = u.endsWith('/') ? u.substring(0, u.length - 1) : u;
      final idx = withoutTrailing.indexOf('/api/v1');
      if (idx > 0) return withoutTrailing.substring(0, idx);
      if (idx == 0) return 'http://localhost:3000';
      return withoutTrailing.replaceFirst(RegExp(r'/api/v1.*'), '');
    }
    return api_base_url.getDefaultApiServerOrigin();
  }

  /// Base URL for Dio (includes /api/v1). From .env BASE_URL or platform default.
  static String get baseUrl {
    final fromEnv = dotenv.env['BASE_URL'];
    if (fromEnv != null && fromEnv.isNotEmpty) {
      final url = fromEnv.endsWith('/') ? fromEnv.substring(0, fromEnv.length - 1) : fromEnv;
      return url;
    }
    return '${_serverOrigin()}/api/v1';
  }

  /// Server origin (host:port, no path) for WebSocket/Socket.IO. Derived from baseUrl.
  static String get serverOrigin => _serverOrigin();

  /// WebSocket/Socket.IO URL (server origin + /trading namespace). Use for chart realtime.
  static String get webSocketUrl => '$serverOrigin/trading';

  /// Environment (development/production)
  static String get env => dotenv.env['ENV'] ?? 'development';

  // Các API Endpoints
  // NOTE: Base URL đã chứa /api/v1 prefix, nên endpoints không cần prefix nữa
  
  /// Health check: GET returns { "ok": true, "timestamp": "..." }. Use to verify backend is running.
  static const String health = '/health';

  // Auth Endpoints (Xác thực) - Không có prefix /api/v1
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authWalletNonce = '/auth/wallet-nonce';
  static const String authWalletVerify = '/auth/wallet-verify';
  // Note: getCurrentUser should use /users/me instead of /auth/me
  // Backend's /auth/me is not exposed - use users service instead
  
  // User Endpoints (Quản lý người dùng)
  static const String users = '/users';
  static const String usersMe = '/users/me';
  static const String usersStatistics = '/users/statistics';
  
  // Currencies Endpoints (Tiền ảo)
  static const String currencies = '/currencies';
  static String currencyById(String id) => '$currencies/$id';
  static String currencyBySymbol(String symbol) => '$currencies/symbol/$symbol';
  static const String currenciesActive = '$currencies/active';
  static const String currenciesTradable = '$currencies/tradable';
  
  // Markets Endpoints (Thị trường)
  static const String markets = '/markets';
  static const String marketsActive = '$markets/active';
  static String marketById(String id) => '$markets/$id';
  static String marketBySymbol(String symbol) {
    // URL encode symbol to handle "/" in symbols like "BTC/USDT"
    final encodedSymbol = Uri.encodeComponent(symbol);
    return '$markets/symbol/$encodedSymbol';
  }
  static String marketTicker(String id) => '$markets/$id/ticker';
  static String marketTickerBySymbol(String symbol) {
    final encodedSymbol = Uri.encodeComponent(symbol);
    return '$markets/symbol/$encodedSymbol/ticker';
  }
  /// Tab Thị trường – danh sách pair + giá, % đổi: GET /markets/tickers/all
  static const String marketsTickersAll = '$markets/tickers/all';

  /// Sổ lệnh – BE route: GET /markets/:id/orderbook (không gạch)
  static String marketOrderBook(String id) => '$markets/$id/orderbook';
  static String marketOrderBookBySymbol(String symbol) {
    final encodedSymbol = Uri.encodeComponent(symbol);
    return '$markets/symbol/$encodedSymbol/orderbook';
  }
  static String marketTrades(String id) => '$markets/$id/trades';
  static String marketTradesBySymbol(String symbol) {
    final encodedSymbol = Uri.encodeComponent(symbol);
    return '$markets/symbol/$encodedSymbol/trades';
  }
  static String marketOHLCV(String id) => '$markets/$id/ohlcv';

  /// OHLCV range filter: 1d, 1M, 3M, 1y, 5y (backend only accepts these)
  static const List<String> ohlcvRanges = ['1d', '1M', '3M', '1y', '5y'];

  /// Suggested interval per range for chart (FE gợi ý theo tài liệu API)
  static String intervalForRange(String range) {
    switch (range) {
      case '1d':
        return '1m';
      case '1M':
        return '1h';
      case '3M':
        return '4h';
      case '1y':
      case '5y':
        return '1d';
      default:
        return '1h';
    }
  }

  // Orders Endpoints (Lệnh mua/bán – Orders Module + Matching)
  static const String orders = '/orders';
  static String ordersBook(int pairId) => '$orders/book/$pairId';
  static const String ordersMy = '$orders/my';
  static String orderById(int orderId) => '$orders/$orderId';
  static String orderCancel(int orderId) => '$orders/$orderId/cancel';

  /// Exchange sync: POST to pull Binance data into DB (currencies + market_pairs).
  /// After sync, backend price feed starts; if you see "No pairs configured; price feed not started", run this once then restart backend.
  static const String exchangeSyncInfo = '/exchange/sync-info';

  // Wallets Endpoints (Ví tiền)
  static const String wallets = '/wallets';
  static String walletByCurrency(String currencyId) => '$wallets/currency/$currencyId';
  static String walletBalance(String walletId) => '$wallets/$walletId/balance';
  static String walletLedger(String walletId) => '$wallets/$walletId/ledger';

  // Blockchain Endpoints (Liên kết ví + Nạp/Rút on-chain)
  static const String blockchain = '/blockchain';
  static const String blockchainWallets = '$blockchain/wallets';
  static const String blockchainRequestLink = '$blockchain/wallets/request-link';
  static const String blockchainVerifyLink = '$blockchain/wallets/verify-link';
  static const String blockchainDepositAddress = '$blockchain/deposit/address';
  static const String blockchainPreviewDeposit = '$blockchain/deposit/preview';
  static String blockchainWalletBalance(String linkId) =>
      '$blockchain/wallets/$linkId/balance';
  static String blockchainUnlinkWallet(String linkId) => '$blockchain/wallets/$linkId';
  static const String blockchainSubmitDeposit = '$blockchain/deposit/submit';
  static const String blockchainRequestWithdrawal = '$blockchain/withdraw/request';
  static const String blockchainTransactions = '$blockchain/transactions';
  
  // Thời gian timeout cho các request
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
