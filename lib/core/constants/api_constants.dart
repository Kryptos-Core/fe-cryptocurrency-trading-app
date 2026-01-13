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
  
  // Thời gian timeout cho các request
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
