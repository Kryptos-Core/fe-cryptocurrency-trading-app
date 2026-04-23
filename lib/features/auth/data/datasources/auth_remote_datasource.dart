import 'package:crypto_trading_app/features/auth/domain/entities/wallet_nonce_response.dart';
import 'package:crypto_trading_app/features/auth/domain/entities/wc_auth_results.dart';
import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/features/auth/data/models/auth_response_model.dart';
import 'package:crypto_trading_app/features/user/data/models/user_model.dart';

String _messageFromDioResponse(dynamic data, String fallback) {
  if (data is Map) {
    final m = data['message'];
    if (m is String && m.isNotEmpty) return m;
    if (m != null && m.toString().trim().isNotEmpty) return m.toString().trim();
  }
  return fallback;
}

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

  /// Check if backend is reachable (GET /health). Returns true if ok.
  Future<bool> checkHealth();

  /// Request nonce for wallet auth (MetaMask / TronLink). Returns message to sign and TTL.
  Future<WalletNonceResponse> walletNonce({
    required String chain,
    required String address,
  });

  /// Verify wallet signature and get JWT (login or register).
  Future<AuthResponseModel> walletVerify({
    required String chain,
    required String address,
    required String signature,
  });

  /// POST /auth/wallet/wc/init — không JWT.
  Future<WcAuthInitResult> walletWcAuthInit({required String chain});

  /// GET /auth/wallet/wc/status/:sessionId
  Future<WcAuthStatusResult> walletWcAuthStatus(String sessionId);

  /// POST /auth/wallet/wc/verify — cùng payload user/token như wallet-verify.
  Future<AuthResponseModel> walletWcAuthVerify({
    required String sessionId,
    required String chain,
    required String address,
    required String signature,
  });

  /// Send OTP to current user's verified email for 2FA action.
  Future<void> send2faOtp(String token);

  /// Server-side check that OTP matches (does not consume). Throws on invalid.
  Future<void> validate2faOtp({
    required String token,
    required String otpCode,
  });

  /// Enable 2FA with OTP code.
  Future<bool> enable2fa({
    required String token,
    required String otpCode,
  });

  /// Disable 2FA with OTP code.
  Future<bool> disable2fa({
    required String token,
    required String otpCode,
  });

  /// Change password directly (no admin approval). Requires 2FA OTP.
  Future<bool> changePassword({
    required String token,
    required String newPassword,
    required String otpCode,
  });
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
      // Backend accepts email + password (required) and firstName/lastName (optional)
      // Send firstName and lastName only if they are not empty
      final requestData = {
        'email': email,
        'password': password,
      };

      // Add optional fields if provided (not empty strings)
      if (firstName.trim().isNotEmpty) {
        requestData['firstName'] = firstName.trim();
      }
      if (lastName.trim().isNotEmpty) {
        requestData['lastName'] = lastName.trim();
      }

      final response = await dio.post(
        ApiConstants.authRegister,
        data: requestData,
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

      final healthUrl = '${ApiConstants.baseUrl}/health';
      throw NetworkException(
        message:
            'Cannot reach server. Ensure backend is running (npm run start:dev). '
            'Check in browser: $healthUrl',
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
          throw AuthenticationException(message: message);
        }
        throw ServerException(message: message);
      }
      final healthUrl = '${ApiConstants.baseUrl}/health';
      throw NetworkException(
        message:
            'Cannot reach server. Ensure backend is running (npm run start:dev). '
            'Check in browser: $healthUrl',
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

        if (statusCode == 401 || statusCode == 404) {
          // Unauthorized or user deleted/not found - clear stale session in UI
          throw AuthenticationException(message: message);
        }

        throw ServerException(message: message);
      }
      final healthUrl = '${ApiConstants.baseUrl}/health';
      throw NetworkException(
        message: 'Cannot reach server. Check in browser: $healthUrl',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> checkHealth() async {
    try {
      final response = await dio.get(ApiConstants.health);
      if (response.statusCode != 200 || response.data is! Map) return false;
      final body = response.data as Map;
      // BE trả về { success: true, data: { ok: true, ... } }
      final data = body['data'];
      if (data is Map) return data['ok'] == true;
      // Fallback: một số endpoint trả flat { ok: true }
      return body['ok'] == true || body['success'] == true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<WalletNonceResponse> walletNonce({
    required String chain,
    required String address,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.authWalletNonce,
        data: {'chain': chain, 'address': address},
      );
      if (response.statusCode == 200) {
        final raw = response.data as Map<String, dynamic>?;
        if (raw == null) throw ServerException(message: 'Invalid response');
        final data =
            raw['data'] != null ? raw['data'] as Map<String, dynamic> : raw;
        return WalletNonceResponse.fromJson(data);
      }
      throw ServerException(
        message: response.data['message'] ?? 'Failed to get nonce',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response!.data['message'] ?? 'Failed to get nonce';
        if (e.response!.statusCode == 400) {
          throw ValidationException(message: message);
        }
        throw ServerException(message: message);
      }
      throw NetworkException(
        message: 'Cannot reach server. Check connection.',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AuthResponseModel> walletVerify({
    required String chain,
    required String address,
    required String signature,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.authWalletVerify,
        data: {
          'chain': chain,
          'address': address,
          'signature': signature,
        },
      );
      if (response.statusCode == 200) {
        final raw = response.data as Map<String, dynamic>?;
        if (raw == null) throw ServerException(message: 'Invalid response');
        final data =
            raw['data'] != null ? raw['data'] as Map<String, dynamic> : raw;
        return AuthResponseModel(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String?,
          user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
        );
      }
      throw AuthenticationException(
        message: response.data['message'] ?? 'Wallet verification failed',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final message =
            e.response!.data['message'] ?? 'Wallet verification failed';
        if (e.response!.statusCode == 401 || e.response!.statusCode == 400) {
          throw AuthenticationException(message: message);
        }
        throw ServerException(message: message);
      }
      throw NetworkException(
        message: 'Cannot reach server. Check connection.',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Map<String, dynamic> _unwrapDataMap(Map<String, dynamic>? raw) {
    if (raw == null) throw ServerException(message: 'Invalid response');
    final inner = raw['data'];
    if (inner is Map<String, dynamic>) return inner;
    return raw;
  }

  @override
  Future<WcAuthInitResult> walletWcAuthInit({required String chain}) async {
    try {
      final response = await dio.post(
        ApiConstants.authWalletWcInit,
        data: {'chain': chain},
      );
      if (response.statusCode == 200) {
        final raw = response.data as Map<String, dynamic>?;
        final data = _unwrapDataMap(raw);
        return WcAuthInitResult.fromJson(data);
      }
      throw ServerException(
        message: response.data['message'] ?? 'WC auth init failed',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response!.data['message'] ?? 'WC auth init failed';
        if (e.response!.statusCode == 400) {
          throw ValidationException(message: message);
        }
        throw ServerException(message: message);
      }
      throw NetworkException(
        message: 'Cannot reach server. Check connection.',
      );
    } catch (e) {
      if (e is ServerException ||
          e is ValidationException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WcAuthStatusResult> walletWcAuthStatus(String sessionId) async {
    try {
      final response = await dio.get(
        ApiConstants.authWalletWcStatus(sessionId),
      );
      if (response.statusCode == 200) {
        final raw = response.data as Map<String, dynamic>?;
        final data = _unwrapDataMap(raw);
        return WcAuthStatusResult.fromJson(data);
      }
      throw ServerException(
        message: response.data['message'] ?? 'WC auth status failed',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response!.data['message'] ?? 'WC auth status failed',
        );
      }
      throw NetworkException(
        message: 'Cannot reach server. Check connection.',
      );
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AuthResponseModel> walletWcAuthVerify({
    required String sessionId,
    required String chain,
    required String address,
    required String signature,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.authWalletWcVerify,
        data: {
          'sessionId': sessionId,
          'chain': chain,
          'address': address,
          'signature': signature,
        },
      );
      if (response.statusCode == 200) {
        final raw = response.data as Map<String, dynamic>?;
        if (raw == null) throw ServerException(message: 'Invalid response');
        final data =
            raw['data'] != null ? raw['data'] as Map<String, dynamic> : raw;
        return AuthResponseModel(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String?,
          user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
        );
      }
      throw AuthenticationException(
        message: response.data['message'] ?? 'WC auth verify failed',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response!.data['message'] ?? 'WC auth verify failed';
        if (e.response!.statusCode == 401 || e.response!.statusCode == 400) {
          throw AuthenticationException(message: message);
        }
        throw ServerException(message: message);
      }
      throw NetworkException(
        message: 'Cannot reach server. Check connection.',
      );
    } catch (e) {
      if (e is AuthenticationException ||
          e is ValidationException ||
          e is ServerException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> validate2faOtp({
    required String token,
    required String otpCode,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.auth2faValidateOtp,
        data: {'otpCode': otpCode},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200) return;
      throw ServerException(
        message: _messageFromDioResponse(
          response.data,
          'OTP validation failed',
        ),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = _messageFromDioResponse(
          e.response!.data,
          'OTP không hợp lệ hoặc đã hết hạn',
        );
        if (statusCode == 401) throw AuthenticationException(message: message);
        if (statusCode == 400) throw ValidationException(message: message);
        throw ServerException(message: message);
      }
      throw NetworkException(message: 'Cannot reach server. Check connection.');
    } catch (e) {
      if (e is AuthenticationException ||
          e is ValidationException ||
          e is ServerException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> send2faOtp(String token) async {
    try {
      final response = await dio.post(
        ApiConstants.auth2faSendOtp,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to send OTP',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data['message'] ?? 'Failed to send OTP';
        if (statusCode == 401) throw AuthenticationException(message: message);
        throw ServerException(message: message);
      }
      throw NetworkException(message: 'Cannot reach server. Check connection.');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> enable2fa({
    required String token,
    required String otpCode,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.auth2faEnable,
        data: {'otpCode': otpCode},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = raw is Map && raw['data'] != null ? raw['data'] : raw;
        return data is Map ? data['enabled'] == true : true;
      }
      throw ServerException(
        message: response.data['message'] ?? 'Failed to enable 2FA',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data['message'] ?? 'Failed to enable 2FA';
        if (statusCode == 401) throw AuthenticationException(message: message);
        if (statusCode == 400) throw ValidationException(message: message);
        throw ServerException(message: message);
      }
      throw NetworkException(message: 'Cannot reach server. Check connection.');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> disable2fa({
    required String token,
    required String otpCode,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.auth2faDisable,
        data: {'otpCode': otpCode},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = raw is Map && raw['data'] != null ? raw['data'] : raw;
        return data is Map ? data['enabled'] == false : false;
      }
      throw ServerException(
        message: response.data['message'] ?? 'Failed to disable 2FA',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data['message'] ?? 'Failed to disable 2FA';
        if (statusCode == 401) throw AuthenticationException(message: message);
        if (statusCode == 400) throw ValidationException(message: message);
        throw ServerException(message: message);
      }
      throw NetworkException(message: 'Cannot reach server. Check connection.');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> changePassword({
    required String token,
    required String newPassword,
    required String otpCode,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.authChangePassword,
        data: {
          'newPassword': newPassword,
          'otpCode': otpCode,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = raw is Map && raw['data'] != null ? raw['data'] : raw;
        return data is Map ? data['success'] == true : true;
      }
      throw ServerException(
        message: response.data['message'] ?? 'Failed to change password',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final msg = e.response!.data['message'] ?? 'Failed to change password';
        if (e.response!.statusCode == 401)
          throw AuthenticationException(message: msg);
        if (e.response!.statusCode == 400)
          throw ValidationException(message: msg);
        throw ServerException(message: msg);
      }
      throw NetworkException(message: 'Cannot reach server. Check connection.');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
