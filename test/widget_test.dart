import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crypto_trading_app/app/di/injection_container.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:crypto_trading_app/features/home/presentation/screens/home_screen.dart';
import 'package:crypto_trading_app/features/user/domain/entities/user.dart';

import 'support/stub_auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late User testUser;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'access_token': 'test-access-token'});
    final prefs = await SharedPreferences.getInstance();

    testUser = User(
      id: 'user-1',
      email: 'user@example.com',
      firstName: 'Test',
      lastName: 'User',
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
    );

    if (sl.isRegistered<AuthRepository>()) sl.unregister<AuthRepository>();
    if (sl.isRegistered<TokenService>()) sl.unregister<TokenService>();
    if (sl.isRegistered<SharedPreferences>()) sl.unregister<SharedPreferences>();

    sl.registerSingleton<SharedPreferences>(prefs);
    sl.registerSingleton<TokenService>(TokenService(sharedPreferences: prefs));
    sl.registerSingleton<AuthRepository>(
      StubAuthRepository(
        getCurrentUserResult: (_) async => Right(testUser),
      ),
    );
  });

  tearDown(() {
    if (sl.isRegistered<AuthRepository>()) sl.unregister<AuthRepository>();
    if (sl.isRegistered<TokenService>()) sl.unregister<TokenService>();
    if (sl.isRegistered<SharedPreferences>()) sl.unregister<SharedPreferences>();
  });

  testWidgets('HomeScreen shows localized title and welcome after user loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: HomeScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);
  });
}
