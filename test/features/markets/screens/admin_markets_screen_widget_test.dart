import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/features/markets/domain/entities/exchange_sync_result.dart';
import 'package:crypto_trading_app/features/markets/domain/repositories/exchange_repository.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/currencies_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/features/admin/markets/presentation/screens/admin_markets_screen.dart';

import '../../../support/empty_markets_repository.dart';
import '../../../support/stub_auth_repository.dart';
import '../../../support/stub_currencies_repository.dart';

class _FakeExchangeRepository implements ExchangeRepository {
  _FakeExchangeRepository(this.result);

  final ExchangeSyncResult result;
  int syncCalls = 0;
  bool? lastForceRefresh;

  @override
  Future<ExchangeSyncResult> syncInfo({bool forceRefresh = false}) async {
    syncCalls++;
    lastForceRefresh = forceRefresh;
    return result;
  }
}

String _adminJwt() {
  final payload = jsonEncode({
    'role': 'ADMIN',
    'permissions': ['exchange:sync'],
  });
  final enc = base64Url.encode(utf8.encode(payload));
  return 't.$enc.s';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tap sync shows result summary from ExchangeSyncResult',
      (tester) async {
    SharedPreferences.setMockInitialValues({'access_token': _adminJwt()});
    final prefs = await SharedPreferences.getInstance();
    final tokenService = TokenService(sharedPreferences: prefs);
    final fakeExchange = _FakeExchangeRepository(
      const ExchangeSyncResult(
        currenciesCreated: 1,
        currenciesSkipped: 2,
        pairsCreated: 3,
        pairsSkipped: 4,
        errors: [],
      ),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) {
              final a = AuthProvider(
                authRepository: StubAuthRepository(),
                tokenService: tokenService,
              );
              a.restoreSession();
              return a;
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
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: AdminMarketsScreen(exchangeRepository: fakeExchange),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Manual re-sync from Binance'));
    await tester.pumpAndSettle();
    // Drain showAppSnackBar auto-dismiss timer (5s).
    await tester.pump(const Duration(seconds: 6));

    expect(fakeExchange.syncCalls, 1);
    expect(fakeExchange.lastForceRefresh, false);
    // On-screen card + success toast may both show the same summary string.
    expect(
      find.text(
        '+3 pairs created, 4 unchanged; +1 currencies, 2 unchanged.',
      ),
      findsWidgets,
    );
  });
}
