/// API Configuration Constants
/// Following Single Responsibility Principle (SRP)
class ApiConstants {
  // Private constructor to prevent instantiation (Singleton Pattern)
  ApiConstants._();

  // Base URL - should be moved to environment config in production
  static const String baseUrl = 'http://localhost:3000/api';

  // API Endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  
  // Market Endpoints
  static const String marketPairs = '/market/pairs';
  static const String marketTicker = '/market/ticker';
  static const String marketOrderBook = '/market/orderbook';
  static const String marketTrades = '/market/trades';
  static const String marketOHLCV = '/market/ohlcv';
  
  // Trading Endpoints
  static const String orders = '/orders';
  static const String ordersCreate = '/orders/create';
  static const String ordersCancel = '/orders/cancel';
  static const String ordersHistory = '/orders/history';
  
  // Wallet Endpoints
  static const String wallets = '/wallets';
  static const String walletsBalance = '/wallets/balance';
  static const String walletsDeposit = '/wallets/deposit';
  static const String walletsWithdraw = '/wallets/withdraw';
  static const String walletsLedger = '/wallets/ledger';
  
  // Price Alert Endpoints
  static const String priceAlerts = '/alerts';
  static const String priceAlertsCreate = '/alerts/create';
  static const String priceAlertsDelete = '/alerts/delete';
  
  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
