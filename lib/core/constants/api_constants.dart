import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Configuration Constants
/// Following Single Responsibility Principle (SRP)
/// Base URL is loaded from .env file and includes /api/v1 prefix
class ApiConstants {
  // Private constructor để ngăn khởi tạo (Singleton Pattern)
  ApiConstants._();

  /// Base URL from .env file
  /// Should include /api/v1 prefix, e.g., http://localhost:3000/api/v1
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api/v1';
    // Ensure no trailing slash
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Environment (development/production)
  static String get env => dotenv.env['ENV'] ?? 'development';

  // Các API Endpoints
  // NOTE: Base URL đã chứa /api/v1 prefix, nên endpoints không cần prefix nữa
  
  // Auth Endpoints (Xác thực) - Không có prefix /api/v1
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  // Note: getCurrentUser should use /users/me instead of /auth/me
  // Backend's /auth/me is not exposed - use users service instead
  
  // User Endpoints (Quản lý người dùng)
  static const String users = '/users';
  static const String usersMe = '/users/me';
  static const String usersStatistics = '/users/statistics';
  
  // Currencies Endpoints (Tiền ảo)
  static const String currencies = '/currencies';
  static String currencyById(int id) => '$currencies/$id';
  static String currencyBySymbol(String symbol) => '$currencies/symbol/$symbol';
  static const String currenciesActive = '$currencies/active';
  static const String currenciesTradable = '$currencies/tradable';
  
  // Markets Endpoints (Thị trường)
  static const String markets = '/markets';
  static const String marketsActive = '$markets/active';
  static String marketById(int id) => '$markets/$id';
  static String marketBySymbol(String symbol) {
    // URL encode symbol to handle "/" in symbols like "BTC/USDT"
    final encodedSymbol = Uri.encodeComponent(symbol);
    return '$markets/symbol/$encodedSymbol';
  }
  static String marketTicker(int id) => '$markets/$id/ticker';
  static String marketTickerBySymbol(String symbol) {
    final encodedSymbol = Uri.encodeComponent(symbol);
    return '$markets/symbol/$encodedSymbol/ticker';
  }
  /// Tab Thị trường – danh sách pair + giá, % đổi: GET /markets/tickers/all
  static const String marketsTickersAll = '$markets/tickers/all';

  /// Sổ lệnh – theo tài liệu: /markets/:id/order-book (dấu gạch ngang)
  static String marketOrderBook(int id) => '$markets/$id/order-book';
  static String marketOrderBookBySymbol(String symbol) {
    final encodedSymbol = Uri.encodeComponent(symbol);
    return '$markets/symbol/$encodedSymbol/order-book';
  }
  static String marketTrades(int id) => '$markets/$id/trades';
  static String marketTradesBySymbol(String symbol) {
    final encodedSymbol = Uri.encodeComponent(symbol);
    return '$markets/symbol/$encodedSymbol/trades';
  }
  static String marketOHLCV(int id) => '$markets/$id/ohlcv';

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

  // Wallets Endpoints (Ví tiền)
  static const String wallets = '/wallets';
  static String walletByCurrency(int currencyId) => '$wallets/currency/$currencyId';
  static String walletBalance(int walletId) => '$wallets/$walletId/balance';
  static String walletLedger(int walletId) => '$wallets/$walletId/ledger';
  
  // Thời gian timeout cho các request
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
