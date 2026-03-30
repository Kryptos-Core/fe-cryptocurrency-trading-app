import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/data/datasources/auth_remote_datasource.dart';
import 'package:crypto_trading_app/data/datasources/user_remote_datasource.dart';
import 'package:crypto_trading_app/domain/entities/user.dart';

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

  Future<Either<Failure, bool>> enable2fa({
    required String token,
    required String otpCode,
  });

  Future<Either<Failure, bool>> disable2fa({
    required String token,
    required String otpCode,
  });

  /// Đổi mật khẩu trực tiếp (không cần xét duyệt). Yêu cầu 2FA OTP.
  Future<Either<Failure, bool>> changePassword({
    required String token,
    required String newPassword,
    required String otpCode,
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
    required String otpCode,
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
}
