import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/features/auth/domain/entities/dev_user_pick.dart';
import 'package:crypto_trading_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/features/user/domain/entities/user.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenService extends Mock implements TokenService {}

void main() {
  late MockHttpClient mockHttpClient;
  late MockAuthRepository mockAuthRepo;
  late MockTokenService mockTokenService;
  late AuthProvider provider;

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockAuthRepo = MockAuthRepository();
    mockTokenService = MockTokenService();
    provider = AuthProvider(
      authRepository: mockAuthRepo,
      tokenService: mockTokenService,
      httpClient: mockHttpClient,
    );
  });

  group('AuthProvider.loadSandboxUsers', () {
    test('populates sandboxUsers on success and clears loading flag', () async {
      final picks = [
        DevUserPick(
          userId: 'u1',
          email: 'admin@example.com',
          firstName: 'Admin',
          lastName: 'User',
          role: 'ADMIN',
          status: 'ACTIVE',
          avatarUrl: null,
          createdAt: DateTime(2024, 1, 1),
        ),
        DevUserPick(
          userId: 'u2',
          email: 'trader@example.com',
          firstName: 'Trader',
          lastName: 'One',
          role: 'TRADER',
          status: 'ACTIVE',
          avatarUrl: null,
          createdAt: DateTime(2024, 1, 2),
        ),
      ];

      when(() => mockAuthRepo.listSandboxUsers())
          .thenAnswer((_) async => Right(picks));

      final future = provider.loadSandboxUsers();
      // Loading flips synchronously.
      expect(provider.isLoadingSandboxUsers, true);
      await future;

      expect(provider.isLoadingSandboxUsers, false);
      expect(provider.sandboxUsers, picks);
      expect(provider.sandboxUsersError, isNull);
    });

    test('stores error message on failure and clears loading flag', () async {
      when(() => mockAuthRepo.listSandboxUsers())
          .thenAnswer((_) async => const Left(ServerFailure(message: 'boom')));

      await provider.loadSandboxUsers();

      expect(provider.isLoadingSandboxUsers, false);
      expect(provider.sandboxUsers, isEmpty);
      expect(provider.sandboxUsersError, 'boom');
    });

    test('does not start a second concurrent load while one is in flight',
        () async {
      var calls = 0;
      when(() => mockAuthRepo.listSandboxUsers()).thenAnswer((_) async {
        calls += 1;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return const Right(<DevUserPick>[]);
      });

      // Kick off two calls back-to-back; the second should be a no-op
      // because the first is still in flight.
      final f1 = provider.loadSandboxUsers();
      final f2 = provider.loadSandboxUsers();
      await Future.wait([f1, f2]);

      expect(calls, 1);
    });
  });

  group('AuthProvider.loginEmailOnly', () {
    test('applies auth response on success — sets isAuthenticated', () async {
      final user = User(
        id: 'uid-1',
        email: 'admin@example.com',
        firstName: 'Admin',
        lastName: 'User',
        isActive: true,
        status: 'ACTIVE',
        role: 'ADMIN',
        avatarUrl: null,
        twoFaEnabled: false,
        identityVerified: false,
        emailVerified: false,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      when(() => mockAuthRepo.loginEmailOnly(email: 'admin@example.com'))
          .thenAnswer((_) async => Right(
                AuthResponse(
                  accessToken: 'fake.jwt.token',
                  refreshToken: null,
                  user: user,
                ),
              ));
      when(() => mockTokenService.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).thenAnswer((_) async => true);

      final result = await provider.loginEmailOnly(email: 'admin@example.com');

      expect(result.isRight(), true);
      expect(provider.isAuthenticated, true);
      verify(() => mockTokenService.saveTokens(
            accessToken: 'fake.jwt.token',
            refreshToken: null,
          )).called(1);
    });

    test('returns Failure on auth failure and does not authenticate',
        () async {
      when(() => mockAuthRepo.loginEmailOnly(email: 'missing@example.com'))
          .thenAnswer((_) async =>
              const Left(AuthenticationFailure(message: 'Invalid')));

      final result = await provider.loginEmailOnly(email: 'missing@example.com');

      expect(result.isLeft(), true);
      expect(provider.isAuthenticated, false);
    });
  });
}
