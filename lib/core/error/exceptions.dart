/// Custom exceptions for the application
/// Following Single Responsibility Principle (SRP)
library;

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  /// API error code when the server returns JSON `{ code: ... }` (e.g. INVALID_MFA_CODE).
  final String? code;

  ServerException({
    this.message = 'Server Error',
    this.statusCode,
    this.code,
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

  ValidationException({
    this.message = 'Validation Error',
    this.errors,
  });

  @override
  String toString() => 'ValidationException: $message ${errors ?? ""}';
}

class NotFoundException implements Exception {
  final String message;

  NotFoundException({this.message = 'Resource not found'});

  @override
  String toString() => 'NotFoundException: $message';
}
