/// API Configuration Constants
/// Following Single Responsibility Principle (SRP)
class ApiConstants {
  // Private constructor để ngăn khởi tạo (Singleton Pattern)
  ApiConstants._();

  // Base URL
  // Use 10.0.2.2 for Android emulator to access host machine's localhost
  // Use localhost:3000 for web/desktop development
  static const String baseUrl = 'http://localhost:3000';

  // Các API Endpoints
  // Auth Endpoints (Xác thực)
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  // Note: getCurrentUser should use /users/me instead of /auth/me
  // Backend's /auth/me is not exposed - use users service instead
  
  // User Endpoints (Quản lý người dùng)
  static const String users = '/users';
  static const String usersMe = '/users/me';
  static const String usersStatistics = '/users/statistics';
  
  // Currencies Endpoints (Tiền ảo)
  static const String currencies = '/api/v1/currencies';
  static String currencyById(int id) => '$currencies/$id';
  static String currencyBySymbol(String symbol) => '$currencies/symbol/$symbol';
  
  // Markets Endpoints (Thị trường)
  static const String markets = '/api/v1/markets';
  static String marketById(int id) => '$markets/$id';
  static String marketBySymbol(String symbol) => '$markets/symbol/$symbol';
  static String marketTicker(int id) => '$markets/$id/ticker';
  static String marketOrderBook(int id) => '$markets/$id/orderbook';
  static String marketOHLCV(int id) => '$markets/$id/ohlcv';
  
  // Wallets Endpoints (Ví tiền)
  static const String wallets = '/api/v1/wallets';
  static String walletByCurrency(int currencyId) => '$wallets/currency/$currencyId';
  static String walletBalance(int walletId) => '$wallets/$walletId/balance';
  static String walletLedger(int walletId) => '$wallets/$walletId/ledger';
  
  // Thời gian timeout cho các request
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
