import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// Following Open/Closed Principle (OCP) - open for extension, closed for modification
abstract class Failure {
  final String message;
  
  const Failure({required this.message});
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({String message = 'Server Error'}) : super(message: message);
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'Network Error'}) : super(message: message);
}

/// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({String message = 'Authentication Failed'}) : super(message: message);
}

/// Authorization failures
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({String message = 'Unauthorized'}) : super(message: message);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({String message = 'Validation Error'}) : super(message: message);
}

/// Cache failures
class CacheFailure extends Failure {
  const CacheFailure({String message = 'Cache Error'}) : super(message: message);
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure({String message = 'Resource not found'}) : super(message: message);
}

/// Conflict failure (409) - resource already exists
class ConflictFailure extends Failure {
  const ConflictFailure({String message = 'Resource already exists'}) : super(message: message);
}