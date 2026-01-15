import 'dart:async';
import 'package:crypto_trading_app/core/error/exceptions.dart';

/// Mock Service
/// Following Strategy Pattern - can switch between mock and real API
/// Singleton Pattern for global configuration
class MockService {
  // Private constructor
  MockService._();

  /// Global flag to enable/disable mock mode
  /// Set to true to use mock data, false to use real API
  static bool useMock = true;

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

  /// Check if mock mode is enabled
  static bool get isMockMode => useMock;

  /// Enable mock mode
  static void enableMock() {
    useMock = true;
  }

  /// Disable mock mode (use real API)
  static void disableMock() {
    useMock = false;
  }
}
