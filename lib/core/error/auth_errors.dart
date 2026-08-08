/// Auth-related errors.
library;

import 'app_error.dart';

sealed class AuthError extends AppError {
  const AuthError({
    required super.code,
    required super.userMessageKey,
    super.metadata,
    super.cause,
  });
}

class InvalidCredentialsError extends AuthError {
  const InvalidCredentialsError({super.metadata, super.cause})
    : super(
        code: 'AUTH/INVALID_CREDENTIALS',
        userMessageKey: 'error.auth.invalidCredentials',
      );
}

class EmailNotVerifiedError extends AuthError {
  const EmailNotVerifiedError({super.metadata, super.cause})
    : super(
        code: 'AUTH/EMAIL_NOT_VERIFIED',
        userMessageKey: 'error.auth.emailNotVerified',
      );
}

class OtpExpiredError extends AuthError {
  const OtpExpiredError({super.metadata, super.cause})
    : super(code: 'AUTH/OTP_EXPIRED', userMessageKey: 'error.auth.otpExpired');
}

class OtpInvalidError extends AuthError {
  const OtpInvalidError({super.metadata, super.cause})
    : super(code: 'AUTH/OTP_INVALID', userMessageKey: 'error.auth.otpInvalid');
}

class AccountLockedError extends AuthError {
  const AccountLockedError({super.metadata, super.cause})
    : super(code: 'AUTH/ACCOUNT_LOCKED', userMessageKey: 'error.auth.accountLocked');
}

class UnauthorizedError extends AuthError {
  const UnauthorizedError({super.metadata, super.cause})
    : super(code: 'AUTH/UNAUTHORIZED', userMessageKey: 'error.auth.unauthorized');
}

class ForbiddenError extends AuthError {
  const ForbiddenError({super.metadata, super.cause})
    : super(code: 'AUTH/FORBIDDEN', userMessageKey: 'error.auth.forbidden');
}
