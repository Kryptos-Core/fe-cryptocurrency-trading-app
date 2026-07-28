/// Custom exceptions for the application
/// Following Single Responsibility Principle (SRP)
library;

/// Marker codes for [ServerException] so the UI layer can map them to
/// localized messages instead of relying on the raw English fallback.
enum ServerErrorCode {
  unknown,
  loadMarketMakerDefaults,
  loadMarketMakerConfigs,
  saveMarketMakerConfig,
  deleteMarketMakerConfig,
  placeMakerOrders,
  loadActivePairs,
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  /// API error code when the server returns JSON `{ code: ... }` (e.g. INVALID_MFA_CODE).
  final String? code;

  /// Optional structured classification used by the UI to localize the message.
  final ServerErrorCode errorCode;

  /// Additional structured context from the API response (e.g. `{ min_order_amount: '0.01' }`).
  final Map<String, dynamic>? context;

  ServerException({
    this.message = 'Server Error',
    this.statusCode,
    this.code,
    this.errorCode = ServerErrorCode.unknown,
    this.context,
  });

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;

  NetworkException({this.message = 'Network Error'});

  @override
  String toString() => 'NetworkException: $message';
}

class AuthenticationException implements Exception {
  final String message;

  AuthenticationException({this.message = 'Authentication Failed'});

  @override
  String toString() => 'AuthenticationException: $message';
}

class CacheException implements Exception {
  final String message;

  CacheException({this.message = 'Cache Error'});

  @override
  String toString() => 'CacheException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;
  final String? code;

  ValidationException({
    this.message = 'Validation Error',
    this.errors,
    this.code,
  });

  @override
  String toString() => 'ValidationException: $message ${errors ?? ""}';
}

class NotFoundException implements Exception {
  final String message;
  final String? code;

  NotFoundException({this.message = 'Resource not found', this.code});

  @override
  String toString() => 'NotFoundException: $message';
}
