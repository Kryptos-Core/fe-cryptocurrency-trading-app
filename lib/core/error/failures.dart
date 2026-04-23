/// Base class for all failures in the application
/// Following Open/Closed Principle (OCP) - open for extension, closed for modification
abstract class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server Error', super.code});
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Network Error', super.code});
}

/// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(
      {super.message = 'Authentication Failed', super.code});
}

/// Authorization failures
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({super.message = 'Unauthorized', super.code});
}

/// Validation failures
class ValidationFailure extends Failure {
  /// Optional API `code` from Nest `AppException` (e.g. `DEPOSIT_DEFAULT_NOT_CONFIGURED`).
  const ValidationFailure({super.message = 'Validation Error', super.code});
}

/// Cache failures
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache Error', super.code});
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Resource not found', super.code});
}

/// Conflict failure (409) - resource already exists
class ConflictFailure extends Failure {
  const ConflictFailure(
      {super.message = 'Resource already exists', super.code});
}
