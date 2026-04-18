import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/features/auth/domain/entities/security_change_request.dart';
import 'package:crypto_trading_app/features/auth/domain/entities/wallet_nonce_response.dart';
import 'package:crypto_trading_app/features/auth/domain/entities/wc_auth_results.dart';
import 'package:crypto_trading_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:crypto_trading_app/features/user/domain/entities/user.dart';

/// Minimal [AuthRepository] for widget tests — only [getCurrentUser] may be customized.
class StubAuthRepository implements AuthRepository {
  StubAuthRepository({this.getCurrentUserResult});

  final Future<Either<Failure, User>> Function(String token)? getCurrentUserResult;

  static const _f = ServerFailure(message: 'stub');

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async =>
      const Left(_f);

  @override
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  }) async =>
      const Left(_f);

  @override
  Future<Either<Failure, User>> getCurrentUser(String token) async {
    if (getCurrentUserResult != null) return getCurrentUserResult!(token);
    return const Left(_f);
  }

  @override
  Future<Either<Failure, AuthResponse>> loginWithWallet({
    required String chain,
    required String address,
    required String signature,
  }) async =>
      const Left(_f);

  @override
  Future<Either<Failure, WcAuthInitResult>> walletWcAuthInit({
    required String chain,
  }) async =>
      const Left(_f);

  @override
  Future<Either<Failure, WcAuthStatusResult>> walletWcAuthStatus(
    String sessionId,
  ) async =>
      const Left(_f);

  @override
  Future<Either<Failure, AuthResponse>> verifyWalletWcAuth({
    required String sessionId,
    required String chain,
    required String address,
    required String signature,
  }) async =>
      const Left(_f);

  @override
  Future<Either<Failure, User>> updateProfileBasic({
    required String token,
    String? firstName,
    String? lastName,
  }) async =>
      const Left(_f);

  @override
  Future<Either<Failure, SecurityChangeRequestResponse>> requestSecurityChange({
    required String token,
    required String changeType,
    required Map<String, dynamic> payload,
    String? otpCode,
  }) async =>
      const Left(_f);

  @override
  Future<Either<Failure, int>> sendContactEmailVerificationOtp({
    required String token,
    required String email,
  }) async =>
      const Left(_f);

  @override
  Future<Either<Failure, User>> verifyContactEmail({
    required String token,
    required String email,
    required String otpCode,
  }) async =>
      const Left(_f);

  @override
  Future<Either<Failure, User>> uploadAvatar({
    required String token,
    required List<int> fileBytes,
    required String fileName,
    required String mimeType,
  }) async =>
      const Left(_f);

  @override
  Future<Either<Failure, List<SecurityChangeRequestItem>>>
      getPendingSecurityChangeRequests(String token) async =>
          const Left(_f);

  @override
  Future<Either<Failure, SecurityChangeRequestReviewResult>>
      approveSecurityChangeRequest(
    String requestId,
    String token, {
    String? reviewNote,
  }) async =>
      const Left(_f);

  @override
  Future<Either<Failure, SecurityChangeRequestReviewResult>>
      rejectSecurityChangeRequest(
    String requestId,
    String token, {
    String? reviewNote,
  }) async =>
      const Left(_f);

  @override
  Future<Either<Failure, void>> send2faOtp(String token) async =>
      const Left(_f);

  @override
  Future<Either<Failure, void>> validate2faOtp({
    required String token,
    required String otpCode,
  }) async =>
      const Left(_f);

  @override
  Future<Either<Failure, bool>> enable2fa({
    required String token,
    required String otpCode,
  }) async =>
      const Left(_f);

  @override
  Future<Either<Failure, bool>> disable2fa({
    required String token,
    required String otpCode,
  }) async =>
      const Left(_f);

  @override
  Future<Either<Failure, bool>> changePassword({
    required String token,
    required String newPassword,
    required String otpCode,
  }) async =>
      const Left(_f);

  @override
  Future<Either<Failure, WalletNonceResponse>> walletNonce({
    required String chain,
    required String address,
  }) async =>
      const Left(_f);
}
