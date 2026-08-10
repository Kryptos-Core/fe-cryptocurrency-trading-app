import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:crypto_trading_app/features/auth/domain/entities/dev_user_pick.dart';
import 'package:crypto_trading_app/features/user/data/datasources/user_remote_datasource.dart';
import 'package:crypto_trading_app/features/user/domain/entities/user.dart';
import 'package:crypto_trading_app/features/auth/domain/entities/wallet_nonce_response.dart';
import 'package:crypto_trading_app/features/auth/domain/entities/wc_auth_results.dart';
import 'package:crypto_trading_app/features/auth/domain/entities/security_change_request.dart';

/// Auth Repository Interface (Domain Layer)
abstract class AuthRepository {
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  });

  /// Sandbox-only login by email (no password). Returns 404 in production.
  Future<Either<Failure, AuthResponse>> loginEmailOnly({
    required String email,
  });

  /// Sandbox-only: list ACTIVE users for the dev account picker.
  /// Returns 404 in production.
  Future<Either<Failure, List<DevUserPick>>> listSandboxUsers();

  Future<Either<Failure, User>> getCurrentUser(String token);

  /// Đăng nhập/đăng ký bằng ví (MetaMask / TronLink)
  Future<Either<Failure, AuthResponse>> loginWithWallet({
    required String chain,
    required String address,
    required String signature,
  });

  /// Khởi tạo phiên WalletConnect đăng nhập công khai (POST /auth/wallet/wc/init).
  Future<Either<Failure, WcAuthInitResult>> walletWcAuthInit({
    required String chain,
  });

  /// Poll trạng thái phiên WC đăng nhập.
  Future<Either<Failure, WcAuthStatusResult>> walletWcAuthStatus(
    String sessionId,
  );

  /// Hoàn tất đăng nhập WC (POST /auth/wallet/wc/verify).
  Future<Either<Failure, AuthResponse>> verifyWalletWcAuth({
    required String sessionId,
    required String chain,
    required String address,
    required String signature,
  });

  /// Cập nhật hồ sơ cơ bản (first/last name) — không cần duyệt
  Future<Either<Failure, User>> updateProfileBasic({
    required String token,
    String? firstName,
    String? lastName,
  });

  /// Gửi yêu cầu thay đổi bảo mật (email/password) — chờ duyệt
  Future<Either<Failure, SecurityChangeRequestResponse>> requestSecurityChange({
    required String token,
    required String changeType,
    required Map<String, dynamic> payload,
    String? otpCode,
  });

  /// OTP gửi tới email mới — chỉ tài khoản ví (email @*.wallet). Trả về thời gian còn hiệu lực (giây).
  Future<Either<Failure, int>> sendContactEmailVerificationOtp({
    required String token,
    required String email,
  });

  /// Xác minh OTP và cập nhật email đăng nhập.
  Future<Either<Failure, User>> verifyContactEmail({
    required String token,
    required String email,
    required String otpCode,
  });

  /// Upload avatar — trả về user đã cập nhật
  Future<Either<Failure, User>> uploadAvatar({
    required String token,
    required List<int> fileBytes,
    required String fileName,
    required String mimeType,
  });

  /// Danh sách yêu cầu bảo mật chờ duyệt (cho reviewer)
  Future<Either<Failure, List<SecurityChangeRequestItem>>> getPendingSecurityChangeRequests(
    String token,
  );

  /// Duyệt: chấp nhận yêu cầu bảo mật
  Future<Either<Failure, SecurityChangeRequestReviewResult>> approveSecurityChangeRequest(
    String requestId,
    String token, {
    String? reviewNote,
  });

  /// Duyệt: từ chối yêu cầu bảo mật
  Future<Either<Failure, SecurityChangeRequestReviewResult>> rejectSecurityChangeRequest(
    String requestId,
    String token, {
    String? reviewNote,
  });

  Future<Either<Failure, void>> send2faOtp(String token);

  /// Kiểm tra OTP với server (không tiêu thụ mã). Dùng trước khi mở bước tiếp theo (đổi MK, v.v.).
  Future<Either<Failure, void>> validate2faOtp({
    required String token,
    required String otpCode,
  });

  /// Cập nhật contact email không cần OTP — chỉ khi admin đã tắt email verification.
  Future<Either<Failure, User>> updateContactEmailWithoutOtp({
    required String token,
    required String email,
  });

  Future<Either<Failure, bool>> enable2fa({
    required String token,
    required String otpCode,
  });

  Future<Either<Failure, bool>> disable2fa({
    required String token,
    required String otpCode,
  });

  /// Đổi mật khẩu trực tiếp (không cần xét duyệt).
  /// `otpCode` bắt buộc khi 2FA bật VÀ email verification bật; optional khi email verification tắt.
  Future<Either<Failure, bool>> changePassword({
    required String token,
    required String newPassword,
    String? otpCode,
  });

  /// Web / extension login: get signable message (nonce) for [address] on [chain].
  Future<Either<Failure, WalletNonceResponse>> walletNonce({
    required String chain,
    required String address,
  });
}

/// Auth Response entity
class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final User user;

  const AuthResponse({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });
}

/// Auth Repository Implementation (Data Layer)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final UserRemoteDataSource userRemoteDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.userRemoteDataSource,
  });

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      
      return Right(userModel.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final authResponseModel = await remoteDataSource.login(
        email: email,
        password: password,
      );
      
      // Convert model to entity
      final authResponse = AuthResponse(
        accessToken: authResponseModel.accessToken,
        refreshToken: authResponseModel.refreshToken,
        user: authResponseModel.user.toEntity(),
      );
      
      return Right(authResponse);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> loginEmailOnly({
    required String email,
  }) async {
    try {
      final authResponseModel = await remoteDataSource.loginEmailOnly(email: email);
      return Right(AuthResponse(
        accessToken: authResponseModel.accessToken,
        refreshToken: authResponseModel.refreshToken,
        user: authResponseModel.user.toEntity(),
      ));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DevUserPick>>> listSandboxUsers() async {
    try {
      final list = await remoteDataSource.listSandboxUsers();
      return Right(list.map((m) => m.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser(String token) async {
    try {
      final userModel = await remoteDataSource.getCurrentUser(token);
      return Right(userModel.toEntity());
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> loginWithWallet({
    required String chain,
    required String address,
    required String signature,
  }) async {
    try {
      final authResponseModel = await remoteDataSource.walletVerify(
        chain: chain,
        address: address,
        signature: signature,
      );
      return Right(AuthResponse(
        accessToken: authResponseModel.accessToken,
        refreshToken: authResponseModel.refreshToken,
        user: authResponseModel.user.toEntity(),
      ));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WcAuthInitResult>> walletWcAuthInit({
    required String chain,
  }) async {
    try {
      final r = await remoteDataSource.walletWcAuthInit(chain: chain);
      return Right(r);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WcAuthStatusResult>> walletWcAuthStatus(
    String sessionId,
  ) async {
    try {
      final r = await remoteDataSource.walletWcAuthStatus(sessionId);
      return Right(r);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> verifyWalletWcAuth({
    required String sessionId,
    required String chain,
    required String address,
    required String signature,
  }) async {
    try {
      final authResponseModel = await remoteDataSource.walletWcAuthVerify(
        sessionId: sessionId,
        chain: chain,
        address: address,
        signature: signature,
      );
      return Right(AuthResponse(
        accessToken: authResponseModel.accessToken,
        refreshToken: authResponseModel.refreshToken,
        user: authResponseModel.user.toEntity(),
      ));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfileBasic({
    required String token,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final userModel = await userRemoteDataSource.updateProfileBasic(
        token: token,
        firstName: firstName,
        lastName: lastName,
      );
      return Right(userModel.toEntity());
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SecurityChangeRequestResponse>> requestSecurityChange({
    required String token,
    required String changeType,
    required Map<String, dynamic> payload,
    String? otpCode,
  }) async {
    try {
      final res = await userRemoteDataSource.requestSecurityChange(
        token: token,
        changeType: changeType,
        payload: payload,
        otpCode: otpCode,
      );
      return Right(res);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> sendContactEmailVerificationOtp({
    required String token,
    required String email,
  }) async {
    try {
      final expiresIn = await userRemoteDataSource.sendContactEmailVerificationOtp(
        token: token,
        email: email,
      );
      return Right(expiresIn);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> verifyContactEmail({
    required String token,
    required String email,
    required String otpCode,
  }) async {
    try {
      final model = await userRemoteDataSource.verifyContactEmail(
        token: token,
        email: email,
        otpCode: otpCode,
      );
      return Right(model.toEntity());
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateContactEmailWithoutOtp({
    required String token,
    required String email,
  }) async {
    try {
      final model = await userRemoteDataSource.updateContactEmailWithoutOtp(
        token: token,
        email: email,
      );
      return Right(model.toEntity());
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> uploadAvatar({
    required String token,
    required List<int> fileBytes,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      final userModel = await userRemoteDataSource.uploadAvatar(
        token: token,
        fileBytes: fileBytes,
        fileName: fileName,
        mimeType: mimeType,
      );
      return Right(userModel.toEntity());
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SecurityChangeRequestItem>>> getPendingSecurityChangeRequests(
    String token,
  ) async {
    try {
      final list = await userRemoteDataSource.getPendingSecurityChangeRequests(token);
      return Right(list);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SecurityChangeRequestReviewResult>> approveSecurityChangeRequest(
    String requestId,
    String token, {
    String? reviewNote,
  }) async {
    try {
      final res = await userRemoteDataSource.approveSecurityChangeRequest(
        requestId,
        token,
        reviewNote: reviewNote,
      );
      return Right(res);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SecurityChangeRequestReviewResult>> rejectSecurityChangeRequest(
    String requestId,
    String token, {
    String? reviewNote,
  }) async {
    try {
      final res = await userRemoteDataSource.rejectSecurityChangeRequest(
        requestId,
        token,
        reviewNote: reviewNote,
      );
      return Right(res);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> send2faOtp(String token) async {
    try {
      await remoteDataSource.send2faOtp(token);
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> validate2faOtp({
    required String token,
    required String otpCode,
  }) async {
    try {
      await remoteDataSource.validate2faOtp(token: token, otpCode: otpCode);
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> enable2fa({
    required String token,
    required String otpCode,
  }) async {
    try {
      final enabled = await remoteDataSource.enable2fa(
        token: token,
        otpCode: otpCode,
      );
      return Right(enabled);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> disable2fa({
    required String token,
    required String otpCode,
  }) async {
    try {
      final enabled = await remoteDataSource.disable2fa(
        token: token,
        otpCode: otpCode,
      );
      return Right(enabled);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> changePassword({
    required String token,
    required String newPassword,
    String? otpCode,
  }) async {
    try {
      final ok = await remoteDataSource.changePassword(
        token: token,
        newPassword: newPassword,
        otpCode: otpCode,
      );
      return Right(ok);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WalletNonceResponse>> walletNonce({
    required String chain,
    required String address,
  }) async {
    try {
      final r = await remoteDataSource.walletNonce(
        chain: chain,
        address: address,
      );
      return Right(r);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
