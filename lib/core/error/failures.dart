/// Base class for all failures in the application
/// Following Open/Closed Principle (OCP) - open for extension, closed for modification
abstract class Failure {
  final String message;
  
  const Failure({required this.message});
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server Error'});
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Network Error'});
}

/// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({super.message = 'Authentication Failed'});
}

/// Authorization failures
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({super.message = 'Unauthorized'});
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({super.message = 'Validation Error'});
}

/// Cache failures
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache Error'});
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Resource not found'});
}

/// Conflict failure (409) - resource already exists
class ConflictFailure extends Failure {
  const ConflictFailure({super.message = 'Resource already exists'});
}