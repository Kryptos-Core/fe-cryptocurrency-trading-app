import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart' as di;
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/core/providers/locale_provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/currencies_provider.dart';
import 'package:crypto_trading_app/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/presentation/providers/wallets_provider.dart';
import 'package:crypto_trading_app/screens/main_screen.dart';
import 'package:crypto_trading_app/screens/login_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage with proper path
  final appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // If .env file doesn't exist, use default values
    debugPrint('Warning: .env file not found, using default values');
  }

  // Initialize dependency injection
  await di.initializeDependencies();

  runApp(const CryptoTradingApp());
}

class CryptoTradingApp extends StatelessWidget {
  const CryptoTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Re-initialize on hot reload if needed
    di.initializeDependencies();

    // Check if user is authenticated
    final tokenService = di.sl<TokenService>();
    final isAuthenticated = tokenService.isAuthenticated();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>.value(
          value: di.sl<LocaleProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => CurrenciesProvider(
            getCurrenciesUseCase: di.sl(),
            getCurrencyByIdUseCase: di.sl(),
            getCurrencyBySymbolUseCase: di.sl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MarketsProvider(
            getMarketsUseCase: di.sl(),
            getActiveMarketsUseCase: di.sl(),
            getMarketByIdUseCase: di.sl(),
            getMarketBySymbolUseCase: di.sl(),
            getMarketTickerUseCase: di.sl(),
            getMarketTickerBySymbolUseCase: di.sl(),
            getAllTickersUseCase: di.sl(),
            getOrderBookUseCase: di.sl(),
            getOrderBookBySymbolUseCase: di.sl(),
            getTradesUseCase: di.sl(),
            getTradesBySymbolUseCase: di.sl(),
            getOHLCVUseCase: di.sl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => WalletsProvider(
            getWalletsUseCase: di.sl(),
            getWalletByCurrencyUseCase: di.sl(),
            getWalletBalanceUseCase: di.sl(),
            getWalletLedgerUseCase: di.sl(),
            getWalletBalanceApiUseCase: di.sl(),
            executeWalletTransactionApiUseCase: di.sl(),
            getTransactionHistoryApiUseCase: di.sl(),
          ),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) => MaterialApp(
          title: 'Crypto Trading App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.indigo,
          ),
          locale: localeProvider.locale,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LocaleProvider.supportedLocales,
          home: isAuthenticated ? const MainScreen() : const LoginScreen(),
        ),
      ),
    );
  }
}
