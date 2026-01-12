import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/data/models/auth_response_model.dart';
import 'package:crypto_trading_app/data/models/user_model.dart';

/// Auth Remote Datasource
/// Handles authentication API calls
/// Throws custom exceptions on errors
abstract class AuthRemoteDataSource {
  /// Register new user
  /// Returns user info (không có token, cần login sau)
  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  /// Login user
  /// Returns AuthResponse with accessToken, refreshToken, and user info
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  /// Get current user profile
  /// Requires access token in header
  Future<UserModel> getCurrentUser(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      // Backend only requires email + password, firstName/lastName are optional
      final response = await dio.post(
        ApiConstants.authRegister,
        data: {
          'email': email,
          'password': password,
        },
      );

      // Backend response format: { statusCode, message, data: {...user}, timestamp, path }
      if (response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }

      throw ServerException(
        message: response.data['message'] ?? 'Registration failed',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data['message'] ?? 'Registration failed';

        if (statusCode == 400 || statusCode == 409) {
          // Email already exists or validation error
          throw ValidationException(message: message);
        }
        
        throw ServerException(message: message);
      }
      
      throw NetworkException(
        message: 'Network error. Please check your connection.',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.authLogin,
        data: {
          'email': email,
          'password': password,
        },
      );

      // Backend response format: { statusCode, message, data: {accessToken, refreshToken, user}, timestamp, path }
      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return AuthResponseModel.fromJson(data);
      }

      throw AuthenticationException(
        message: response.data['message'] ?? 'Login failed',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data['message'] ?? 'Login failed';

        if (statusCode == 401) {
          // Invalid credentials
          throw AuthenticationException(message: message);
        }
        
        throw ServerException(message: message);
      }
      
      throw NetworkException(
        message: 'Network error. Please check your connection.',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> getCurrentUser(String token) async {
    try {
      // Use /users/me endpoint instead of /auth/me
      // Backend doesn't expose /auth/me - that should be called from users service
      final response = await dio.get(
        ApiConstants.usersMe,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      // Backend response format: { statusCode, message, data: {...user}, timestamp, path }
      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to get user',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data['message'] ?? 'Failed to get user';

        if (statusCode == 401) {
          // Unauthorized - token expired or invalid
          throw AuthenticationException(message: message);
        }
        
        throw ServerException(message: message);
      }
      
      throw NetworkException(
        message: 'Network error. Please check your connection.',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
