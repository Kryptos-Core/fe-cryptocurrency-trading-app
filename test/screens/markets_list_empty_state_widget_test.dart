import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/currencies_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/screens/markets_list_screen.dart';

import '../support/empty_markets_repository.dart';
import '../support/stub_auth_repository.dart';
import '../support/stub_currencies_repository.dart';

/// Unsigned JWT-shaped string; [AuthProvider] only base64-decodes the payload.
String _testAccessToken({
  required String role,
  List<String> permissions = const [],
}) {
  final payload = jsonEncode({
    'role': role,
    'permissions': permissions,
  });
  final enc = base64Url.encode(utf8.encode(payload));
  return 'test.$enc.sig';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpMarketsList(
    WidgetTester tester, {
    required String accessToken,
  }) async {
    SharedPreferences.setMockInitialValues({'access_token': accessToken});
    final prefs = await SharedPreferences.getInstance();
    final tokenService = TokenService(sharedPreferences: prefs);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) {
              final auth = AuthProvider(
                authRepository: StubAuthRepository(),
                tokenService: tokenService,
              );
              auth.restoreSession();
              return auth;
            },
          ),
          ChangeNotifierProvider(
            create: (_) =>
                MarketsProvider(marketsRepository: EmptyMarketsRepository()),
          ),
          ChangeNotifierProvider(
            create: (_) => CurrenciesProvider(
              currenciesRepository: StubCurrenciesRepository(),
            ),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: MarketsListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'empty markets shows Binance sync CTA when admin has exchange:sync',
    (tester) async {
      await pumpMarketsList(
        tester,
        accessToken: _testAccessToken(
          role: 'ADMIN',
          permissions: const ['exchange:sync'],
        ),
      );

      expect(find.text('No markets'), findsOneWidget);
      expect(find.text('Đồng bộ thị trường từ Binance'), findsOneWidget);
    },
  );

  testWidgets(
    'empty markets hides sync CTA for trader without exchange:sync',
    (tester) async {
      await pumpMarketsList(
        tester,
        accessToken: _testAccessToken(role: 'TRADER'),
      );

      expect(find.text('No markets'), findsOneWidget);
      expect(find.text('Đồng bộ thị trường từ Binance'), findsNothing);
    },
  );

  testWidgets(
    'empty markets hides sync CTA when admin JWT omits exchange:sync',
    (tester) async {
      await pumpMarketsList(
        tester,
        accessToken: _testAccessToken(role: 'ADMIN', permissions: const []),
      );

      expect(find.text('No markets'), findsOneWidget);
      expect(find.text('Đồng bộ thị trường từ Binance'), findsNothing);
    },
  );
}
