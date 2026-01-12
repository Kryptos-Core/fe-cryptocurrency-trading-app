import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/data/repositories/auth_repository_impl.dart';
import 'package:crypto_trading_app/domain/entities/user.dart';

/// Login Use Case
/// Authenticates user and returns access token with user info
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<Either<Failure, AuthResponse>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(
      email: email,
      password: password,
    );
  }
}

/// Register Use Case
/// Creates new user account (email + password only)
/// Profile details can be updated later via UpdateUserUseCase
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase({required this.repository});

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    String firstName = '',
    String lastName = '',
  }) async {
    return await repository.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
  }
}

/// Get Current User Use Case
/// Fetches current authenticated user profile
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase({required this.repository});

  Future<Either<Failure, User>> call(String token) async {
    return await repository.getCurrentUser(token);
  }
}
