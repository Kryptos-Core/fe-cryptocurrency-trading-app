/// ApiClient — Dio wrapper that returns `Result<T>` instead of throwing.
///
/// Repositories depend on this instead of `Dio` directly. This makes:
///   - explicit error handling enforced by the type system
///   - error mapping to domain errors centralized
///   - test mocks trivial (no need to mock Dio exceptions)
library;

import 'dart:async';

import 'package:dio/dio.dart';

import '../error/app_error.dart';
import '../error/auth_errors.dart';
import '../error/network_errors.dart';
import '../error/treasury_errors.dart';
import 'result.dart';

typedef Parser<T> = T Function(dynamic data);

class ApiClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  ApiClient({required Dio dio, required TokenStorage tokenStorage})
    : _dio = dio,
      _tokenStorage = tokenStorage {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<Result<T>> get<T>(String path, {required Parser<T> parser, Map<String, dynamic>? query}) {
    return _request<T>(() => _dio.get<dynamic>(path, queryParameters: query), parser);
  }

  Future<Result<T>> post<T>(String path, {Object? data, required Parser<T> parser}) {
    return _request<T>(
      () => _dio.post<dynamic>(path, data: data),
      parser,
    );
  }

  Future<Result<T>> put<T>(String path, {Object? data, required Parser<T> parser}) {
    return _request<T>(() => _dio.put<dynamic>(path, data: data), parser);
  }

  Future<Result<T>> delete<T>(String path, {required Parser<T> parser, Object? data}) {
    return _request<T>(() => _dio.delete<dynamic>(path, data: data), parser);
  }

  Future<Result<T>> _request<T>(Future<Response<dynamic>> Function() send, Parser<T> parser) async {
    try {
      final response = await send();
      final raw = response.data;
      return Success<T>(parser(raw));
    } on DioException catch (e) {
      return Failure<T>(_mapDioError(e));
    } catch (e, st) {
      return Failure<T>(UnknownError(cause: e, metadata: {'stack': st.toString().split('\n').take(3).join(' | ')}));
    }
  }

  AppError _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    final serverCode = (body is Map && body['error'] is Map) ? body['error']['code'] as String? : null;

    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.sendTimeout) {
      return NetworkTimeoutError(cause: e);
    }
    if (e.type == DioExceptionType.connectionError) {
      return NetworkError(cause: e);
    }

    if (serverCode != null) {
      return _mapServerCode(serverCode, status, body, e);
    }

    if (status == 401) return UnauthorizedError(cause: e);
    if (status == 403) return ForbiddenError(cause: e);
    if (status == 404) return const ResourceNotFoundErrorSE(); // see below
    if (status == 422) return const ValidationError();
    if (status == 423) return WalletLockedError(cause: e);
    if (status == 429) return const RateLimitedError();
    if (status == 503) return ChainUnavailableError(cause: e);
    if (status != null && status >= 500) {
      return ServerError(statusCode: status, cause: e);
    }
    return UnknownError(cause: e);
  }

  AppError _mapServerCode(String code, int? status, dynamic body, DioException e) {
    switch (code) {
      case 'AUTH/INVALID_CREDENTIALS':
        return InvalidCredentialsError(cause: e);
      case 'AUTH/EMAIL_NOT_VERIFIED':
        return EmailNotVerifiedError(cause: e);
      case 'AUTH/OTP_EXPIRED':
        return OtpExpiredError(cause: e);
      case 'AUTH/OTP_INVALID':
        return OtpInvalidError(cause: e);
      case 'AUTH/ACCOUNT_LOCKED':
        return AccountLockedError(cause: e);
      case 'AUTH/UNAUTHORIZED':
        return UnauthorizedError(cause: e);
      case 'AUTH/FORBIDDEN':
        return ForbiddenError(cause: e);
      case 'TREASURY/INSUFFICIENT_BALANCE':
        return InsufficientBalanceError(cause: e);
      case 'TREASURY/WALLET_LOCKED':
        return WalletLockedError(cause: e);
      case 'TREASURY/CHAIN_UNAVAILABLE':
        return ChainUnavailableError(cause: e);
      case 'TREASURY/AMOUNT_BELOW_MIN':
        return AmountBelowMinError(cause: e);
      case 'TREASURY/AMOUNT_ABOVE_MAX':
        return AmountAboveMaxError(cause: e);
      case 'TREASURY/WALLET_NOT_FOUND':
        return WalletNotFoundError(cause: e);
      case 'TREASURY/INVALID_ADDRESS':
        return InvalidAddressError(cause: e);
      default:
        if (status != null && status >= 500) {
          return ServerError(statusCode: status, cause: e);
        }
        return UnknownError(
          metadata: <String, Object>{
            'code': code,
            if (status != null) 'status': status,
          },
          cause: e,
        );
    }
  }
}

abstract class TokenStorage {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> writeAccessToken(String token);
  Future<void> writeRefreshToken(String token);
  Future<void> clear();
}

/// Sentinel placeholders to avoid fan-out import in the mapping branch.
/// Kept here so `_mapDioError` can compile without a circular import.
class ResourceNotFoundErrorSE extends AppError {
  const ResourceNotFoundErrorSE({super.metadata, super.cause})
    : super(code: 'RESOURCE/NOT_FOUND', userMessageKey: 'error.resource.notFound');
}

class ValidationError extends AppError {
  const ValidationError({super.metadata, super.cause})
    : super(code: 'VALIDATION/SCHEMA_INVALID', userMessageKey: 'error.validation.schema');
}

class RateLimitedError extends AppError {
  const RateLimitedError({super.metadata, super.cause})
    : super(code: 'RESOURCE/RATE_LIMITED', userMessageKey: 'error.resource.rateLimited');
}
