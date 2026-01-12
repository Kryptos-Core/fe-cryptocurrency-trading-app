import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/api_constants.dart';

/// Dio Client Factory
/// Following Dependency Inversion Principle (DIP)
/// High-level modules should not depend on low-level modules
class DioClient {
  final Dio _dio;
  final Logger _logger = Logger();

  DioClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: ApiConstants.connectTimeout,
              receiveTimeout: ApiConstants.receiveTimeout,
              sendTimeout: ApiConstants.sendTimeout,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )) {
    _dio.interceptors.addAll([
      _loggingInterceptor(),
      _authInterceptor(),
      _errorInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  /// Logging interceptor for debugging
  Interceptor _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.d('REQUEST[${options.method}] => PATH: ${options.path}');
        _logger.d('Headers: ${options.headers}');
        _logger.d('Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.i(
          'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
        );
        _logger.d('Data: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        _logger.e(
          'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
        );
        _logger.e('Message: ${error.message}');
        _logger.e('Data: ${error.response?.data}');
        return handler.next(error);
      },
    );
  }

  /// Auth interceptor to add JWT token to requests
  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // TODO: Get token from secure storage
        // For now, we'll check if token exists in options.extra
        final token = options.extra['token'] as String?;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 Unauthorized - refresh token logic
        if (error.response?.statusCode == 401) {
          // TODO: Implement token refresh logic
          _logger.w('Unauthorized - Token refresh needed');
        }
        return handler.next(error);
      },
    );
  }

  /// Error interceptor to handle common errors
  Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        // Handle network errors
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          _logger.e('Connection Timeout');
        } else if (error.type == DioExceptionType.badResponse) {
          // Handle HTTP errors
          final statusCode = error.response?.statusCode;
          if (statusCode != null) {
            if (statusCode >= 500) {
              _logger.e('Server Error: $statusCode');
            } else if (statusCode >= 400) {
              _logger.e('Client Error: $statusCode');
            }
          }
        }
        return handler.next(error);
      },
    );
  }

  /// Set authentication token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authentication token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
