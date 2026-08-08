import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
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

  const fakeToken = 'fake.jwt.token';
  const fakeAdminToken = 'fake.admin.jwt.token';

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

  group('AuthProvider.emailVerificationRequired', () {
    test('defaults to true (secure by default)', () {
      expect(provider.emailVerificationRequired, true);
    });

    test('refreshEmailVerificationRequired sets false when BE returns false', () async {
      when(() => mockTokenService.getAccessToken()).thenReturn(fakeAdminToken);
      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {'key': 'EMAIL_VERIFICATION_REQUIRED', 'value': 'false'}
              ]
            }),
            200,
          ));

      await provider.refreshEmailVerificationRequired();

      expect(provider.emailVerificationRequired, false);
    });

    test('refreshEmailVerificationRequired sets true when BE returns true', () async {
      when(() => mockTokenService.getAccessToken()).thenReturn(fakeAdminToken);
      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {'key': 'EMAIL_VERIFICATION_REQUIRED', 'value': 'true'}
              ]
            }),
            200,
          ));

      await provider.refreshEmailVerificationRequired();

      expect(provider.emailVerificationRequired, true);
    });

    test('refreshEmailVerificationRequired does nothing when token is null', () async {
      when(() => mockTokenService.getAccessToken()).thenReturn(null);

      await provider.refreshEmailVerificationRequired();

      // Default remains true
      expect(provider.emailVerificationRequired, true);
    });

    test('refreshEmailVerificationRequired handles non-admin (non-200) gracefully', () async {
      when(() => mockTokenService.getAccessToken()).thenReturn(fakeToken);
      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response('Forbidden', 403));

      await provider.refreshEmailVerificationRequired();

      // Default remains true (no crash)
      expect(provider.emailVerificationRequired, true);
    });
  });

  group('AuthProvider.canEditSystemConfigAuthSecurity', () {
    test('returns true when user has system_config:edit_auth_security permission', () {
      when(() => mockTokenService.getAccessToken()).thenReturn(fakeToken);
      // Simulate JWT with permission
      final tokenWithPerm = _fakeJwt(permissions: ['system_config:edit_auth_security']);
      when(() => mockTokenService.getAccessToken()).thenReturn(tokenWithPerm);
      provider.restoreSession();
      expect(provider.canEditSystemConfigAuthSecurity, true);
    });

    test('returns true for admin role', () {
      when(() => mockTokenService.getAccessToken()).thenReturn(fakeToken);
      final adminToken = _fakeJwt(role: 'ADMIN', permissions: []);
      when(() => mockTokenService.getAccessToken()).thenReturn(adminToken);
      provider.restoreSession();
      expect(provider.canEditSystemConfigAuthSecurity, true);
    });

    test('returns false for trader without permission', () {
      when(() => mockTokenService.getAccessToken()).thenReturn(fakeToken);
      final traderToken = _fakeJwt(role: 'TRADER', permissions: []);
      when(() => mockTokenService.getAccessToken()).thenReturn(traderToken);
      provider.restoreSession();
      expect(provider.canEditSystemConfigAuthSecurity, false);
    });
  });
}

/// Builds a minimal fake JWT with role and permissions claims.
String _fakeJwt({String role = 'TRADER', List<String> permissions = const []}) {
  final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
  final payload = base64Url.encode(utf8.encode(
    jsonEncode({'role': role, 'permissions': permissions}),
  ));
  // Valid JWT needs 3 parts: header.payload.signature
  final sig = base64Url.encode(utf8.encode('fake-signature'));
  return '$header.$payload.$sig';
}
