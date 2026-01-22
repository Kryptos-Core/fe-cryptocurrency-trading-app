import 'dart:async';

/// Mock Service
/// Following Strategy Pattern - can switch between mock and real API
/// Singleton Pattern for global configuration
class MockService {
  // Private constructor
  MockService._();

  /// Global flag to enable/disable mock mode
  /// Set to true to use mock data, false to use real API
  /// 
  /// NOTE: Currently only Currencies API is fully implemented
  /// Markets and Wallets APIs may not be available on backend yet
  static bool useMock = false; // Changed to false to use real API from database

  /// Per-module mock flags (for granular control)
  /// Use these if you want to use real API for some modules and mock for others
  /// 
  /// Strategy: Use real API if available, fallback to mock if not
  static bool useMockForCurrencies = false; // API ready - using real API
  static bool useMockForMarkets = true; // API not ready - using mock data
  static bool useMockForWallets = true; // API not ready - using mock data
  static bool useMockForUsers = true; // API not ready - using mock data (if needed)

  /// Simulate network delay
  static Future<void> simulateDelay({Duration delay = const Duration(milliseconds: 500)}) async {
    await Future.delayed(delay);
  }

  /// Handle mock response with delay simulation
  static Future<T> mockResponse<T>(T Function() dataProvider) async {
    await simulateDelay();
    return dataProvider();
  }

  /// Handle mock error
  static Future<T> mockError<T>(Exception exception) async {
    await simulateDelay();
    throw exception;
  }

  /// Check if mock mode is enabled (global)
  static bool get isMockMode => useMock;

  /// Check if mock mode is enabled for specific module
  static bool isMockModeFor(String module) {
    switch (module.toLowerCase()) {
      case 'currencies':
        return useMock || useMockForCurrencies;
      case 'markets':
        return useMock || useMockForMarkets;
      case 'wallets':
        return useMock || useMockForWallets;
      case 'users':
      case 'user':
        return useMock || useMockForUsers;
      default:
        return useMock;
    }
  }

  /// Enable mock mode
  static void enableMock() {
    useMock = true;
  }

  /// Disable mock mode (use real API)
  static void disableMock() {
    useMock = false;
  }
}
