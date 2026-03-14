import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart' as di;
import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/core/providers/locale_provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/presentation/providers/currencies_provider.dart';
import 'package:crypto_trading_app/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/presentation/providers/wallets_provider.dart';
import 'package:crypto_trading_app/presentation/providers/orders_provider.dart';
import 'package:crypto_trading_app/presentation/providers/blockchain_provider.dart';
import 'package:crypto_trading_app/screens/main_screen.dart';
import 'package:crypto_trading_app/screens/login_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Web does not support getApplicationDocumentsDirectory().
  // Hive.initFlutter() without a path uses the web-compatible backend.
  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final appDocDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocDir.path);
  }

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // If .env file doesn't exist, use default values
    debugPrint('Warning: .env file not found, using default values');
  }
  debugPrint('API BASE_URL: ${ApiConstants.baseUrl}');

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
        ChangeNotifierProvider<AuthProvider>(
          create: (_) {
            final provider = AuthProvider(
              authRepository: di.sl(),
              tokenService: di.sl(),
            );
            provider.restoreSession();
            // Wire 403 responses from DioClient through to AuthProvider.
            DioClient.onForbidden = provider.handleForbidden;
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => CurrenciesProvider(
            currenciesRepository: di.sl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MarketsProvider(
            marketsRepository: di.sl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => WalletsProvider(
            walletsRepository: di.sl(),
            walletRepository: di.sl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => OrdersProvider(
            ordersRepository: di.sl(),
            walletRepository: di.sl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BlockchainProvider(
            blockchainRepository: di.sl(),
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
          localizationsDelegates: const [
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
