import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import '../constants/api_constants.dart';

/// Dio Client Factory
/// Following Dependency Inversion Principle (DIP)
/// High-level modules should not depend on low-level modules
/// Singleton Pattern: Ensures only one instance of the HTTP client exists.
class DioClient {
  // --- Singleton Pattern Implementation ---
  static DioClient? _instance;

  static DioClient get instance {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  factory DioClient({Dio? dio, TokenService? tokenService}) {
    if (_instance == null) {
      _instance = DioClient._internal(dio: dio, tokenService: tokenService);
    } else {
      // Update tokenService if provided later
      if (tokenService != null) {
        _instance!.tokenService = tokenService;
      }
    }
    return _instance!;
  }
  // ----------------------------------------

  /// Global 403-Forbidden callback.
  /// Set by [AuthProvider] after it is created so the interceptor can
  /// notify the UI without a hard dependency on the Provider tree.
  static void Function()? onForbidden;
  final Dio _dio;
  final Logger _logger = Logger();
  TokenService? tokenService;

  DioClient._internal({Dio? dio, this.tokenService})
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

  /// Auth interceptor to add JWT token to requests (skip for login/register)
  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final path = options.path;
        if (path.contains('/auth/login') ||
            path.contains('/auth/register') ||
            path.contains('/auth/wallet-nonce') ||
            path.contains('/auth/wallet-verify') ||
            path.contains('/auth/wallet/wc/')) {
          return handler.next(options);
        }
        if (tokenService != null) {
          final token = tokenService!.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            _logger.d('Added Authorization header to request');
          }
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 Unauthorized - token expired
        if (error.response?.statusCode == 401) {
          _logger.w('Unauthorized - Token expired or invalid');
          if (tokenService != null) {
            await tokenService!.clearTokens();
          }
        }
        // Handle 403 Forbidden - insufficient role/permission.
        // Skip global notification for endpoints that legitimately return 403
        // for non-finance roles (e.g. TRADER calling GET /treasury/wallets is
        // normal — the UI handles it as an empty state, not a permission error).
        if (error.response?.statusCode == 403) {
          final path = error.requestOptions.path;
          final treasuryWallets403 =
              path.endsWith('/treasury/wallets') ||
              RegExp(r'^treasury/wallets(\?|$)').hasMatch(path);
          if (!treasuryWallets403) {
            _logger.w('Forbidden - Insufficient permissions for $path');
            DioClient.onForbidden?.call();
          }
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
          final uri = error.requestOptions.uri;
          if (statusCode != null) {
            if (statusCode >= 500) {
              _logger.e('Server Error: $statusCode => $uri');
            } else if (statusCode >= 400) {
              _logger.e('Client Error: $statusCode => ${uri.toString()}');
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
