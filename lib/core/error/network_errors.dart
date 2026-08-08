/// Network / transport-level errors. Wraps Dio and connection failures.
library;

import 'app_error.dart';

class NetworkError extends AppError {
  const NetworkError({super.metadata, super.cause})
    : super(code: 'NETWORK/UNAVAILABLE', userMessageKey: 'error.network.unavailable');
}

class NetworkTimeoutError extends AppError {
  const NetworkTimeoutError({super.metadata, super.cause})
    : super(code: 'NETWORK/TIMEOUT', userMessageKey: 'error.network.timeout');
}

class ServerError extends AppError {
  final int statusCode;
  const ServerError({required this.statusCode, super.metadata, super.cause})
    : super(
        code: 'NETWORK/SERVER_ERROR',
        userMessageKey: 'error.network.serverError',
      );

  @override
  List<Object?> get props => [code, userMessageKey, statusCode, metadata, cause];
}

class UnknownError extends AppError {
  const UnknownError({super.metadata, super.cause})
    : super(code: 'NETWORK/UNKNOWN', userMessageKey: 'error.unknown');
}
