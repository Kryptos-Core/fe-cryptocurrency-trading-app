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
  static String marketById(int id) => '$markets/$id';
  static String marketBySymbol(String symbol) => '$markets/symbol/$symbol';
  static String marketTicker(int id) => '$markets/$id/ticker';
  static String marketOrderBook(int id) => '$markets/$id/orderbook';
  static String marketOHLCV(int id) => '$markets/$id/ohlcv';
  
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
