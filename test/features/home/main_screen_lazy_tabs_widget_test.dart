import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:crypto_trading_app/app/di/injection_container.dart';
import 'package:crypto_trading_app/features/notifications/application/services/notifications_socket_service.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:crypto_trading_app/features/markets/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/currencies_provider.dart';
import 'package:crypto_trading_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/features/home/presentation/screens/main_screen.dart';
import 'package:crypto_trading_app/features/markets/presentation/screens/markets_list_screen.dart';

import '../../support/empty_markets_repository.dart';
import '../../support/stub_auth_repository.dart';
import '../../support/stub_currencies_repository.dart';

class _StubDashboardProvider extends ChangeNotifier
    implements DashboardProvider {
  @override
  DashboardSummary get summary => DashboardSummary.empty;

  @override
  double get portfolioTotal => 0;

  @override
  bool get isLoading => false;

  @override
  bool get hasData => false;

  @override
  int get walletCount => 0;

  @override
  int get activeWalletCount => 0;

  @override
  List<MarketPair> get topMarkets => const [];

  @override
  Future<void> init() async {}

  @override
  Future<void> refresh({bool force = false}) async {}

  @override
  MarketTicker? tickerFor(String symbol) => null;

  @override
  double usdValueFor(String currencySymbol) => 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<TokenService> _setupTokenService() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return TokenService(sharedPreferences: prefs);
}

void _registerMainScreenDependencies() {
  if (sl.isRegistered<NotificationsSocketService>()) {
    sl.unregister<NotificationsSocketService>();
  }
  sl.registerSingleton<NotificationsSocketService>(
      NotificationsSocketService());
}

Widget _buildHarness({required TokenService tokenService}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AuthProvider(
          authRepository: StubAuthRepository(),
          tokenService: tokenService,
        ),
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
      ChangeNotifierProvider<DashboardProvider>(
        create: (_) => _StubDashboardProvider(),
      ),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('en'),
      home: MainScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    if (sl.isRegistered<NotificationsSocketService>()) {
      sl.unregister<NotificationsSocketService>();
    }
  });

  testWidgets('markets tab materializes only after first selection',
      (tester) async {
    final tokenService = await _setupTokenService();
    _registerMainScreenDependencies();

    await tester.pumpWidget(_buildHarness(tokenService: tokenService));
    await tester.pumpAndSettle();

    expect(find.byType(MarketsListScreen, skipOffstage: false), findsNothing);

    await tester.tap(find.byIcon(Icons.trending_up_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(MarketsListScreen, skipOffstage: false), findsOneWidget);
  });
}
