import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// Following Open/Closed Principle (OCP) - open for extension, closed for modification
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server Error']);
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network Error']);
}

/// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message = 'Authentication Failed']);
}

/// Authorization failures
class AuthorizationFailure extends Failure {
  const AuthorizationFailure([super.message = 'Unauthorized']);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation Error']);
}

/// Cache failures
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache Error']);
}

/// Insufficient balance failure
class InsufficientBalanceFailure extends Failure {
  const InsufficientBalanceFailure([super.message = 'Insufficient Balance']);
}

/// Order not found failure
class OrderNotFoundFailure extends Failure {
  const OrderNotFoundFailure([super.message = 'Order Not Found']);
}

/// Invalid trading pair failure
class InvalidTradingPairFailure extends Failure {
  const InvalidTradingPairFailure([super.message = 'Invalid Trading Pair']);
}

/// Market closed failure
class MarketClosedFailure extends Failure {
  const MarketClosedFailure([super.message = 'Market is Closed']);
}

/// Generic failure for unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Unexpected Error']);
}
