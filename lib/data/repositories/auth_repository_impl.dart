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
  }) async {
    try {
      final res = await userRemoteDataSource.requestSecurityChange(
        token: token,
        changeType: changeType,
        payload: payload,
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
}
