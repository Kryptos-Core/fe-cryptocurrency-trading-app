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
import 'package:crypto_trading_app/core/providers/locale_provider.dart';
import 'package:crypto_trading_app/core/providers/theme_provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/presentation/providers/currencies_provider.dart';
import 'package:crypto_trading_app/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/presentation/providers/wallets_provider.dart';
import 'package:crypto_trading_app/presentation/providers/orders_provider.dart';
import 'package:crypto_trading_app/presentation/providers/deposits_provider.dart';
import 'package:crypto_trading_app/presentation/providers/blockchain_provider.dart';
import 'package:crypto_trading_app/presentation/providers/managed_wallets_provider.dart';
import 'package:crypto_trading_app/presentation/providers/dashboard_provider.dart';
import 'package:crypto_trading_app/presentation/providers/notification_provider.dart';
import 'package:crypto_trading_app/presentation/providers/admin_users_provider.dart';
import 'package:crypto_trading_app/presentation/providers/admin_transactions_provider.dart';
import 'package:crypto_trading_app/presentation/providers/payment_config_provider.dart';
import 'package:crypto_trading_app/presentation/providers/runtime_settings_provider.dart';
import 'package:crypto_trading_app/data/repositories/system_config_repository.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_provider.dart';
import 'package:crypto_trading_app/presentation/providers/onchain_chain_picker_provider.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_main_wallet_provider.dart';
import 'package:crypto_trading_app/presentation/providers/market_maker_provider.dart';
import 'package:crypto_trading_app/presentation/providers/withdrawal_management_provider.dart';
import 'package:crypto_trading_app/core/services/fcm_service.dart';
import 'package:crypto_trading_app/data/datasources/notification_remote_datasource.dart';
import 'package:crypto_trading_app/data/datasources/payment_config_remote_datasource.dart';
import 'package:crypto_trading_app/data/datasources/treasury_remote_datasource.dart';
import 'package:crypto_trading_app/data/datasources/market_maker_remote_datasource.dart';
import 'package:crypto_trading_app/data/datasources/withdrawal_admin_remote_datasource.dart';

import 'package:crypto_trading_app/core/ui/app_scroll_behavior.dart';
import 'package:crypto_trading_app/screens/main_screen.dart';

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

  // Initialize Firebase + FCM (silently skipped on unsupported platforms like Windows)
  final fcmToken = await di.sl<FcmService>().initialize();
  if (fcmToken != null) {
    // Register token with BE after user logs in — done in NotificationProvider.initialize()
    di.sl<di.SharedPreferences>().setString('pending_fcm_token', fcmToken);
  }

  runApp(const CryptoTradingApp());
}

class CryptoTradingApp extends StatelessWidget {
  const CryptoTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Re-initialize on hot reload if needed
    di.initializeDependencies();


    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>.value(
          value: di.sl<LocaleProvider>(),
        ),
        ChangeNotifierProvider<ThemeProvider>.value(
          value: di.sl<ThemeProvider>(),
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
            notificationsSocketService: di.sl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => OrdersProvider(
            ordersRepository: di.sl(),
            walletRepository: di.sl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DepositsProvider(
            repository: di.sl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BlockchainProvider(
            blockchainRepository: di.sl(),
          ),
        ),
        ChangeNotifierProvider<ManagedWalletsProvider>.value(
          value: di.sl<ManagedWalletsProvider>(),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => DashboardProvider(
            datasource: di.sl(),
            wsService: di.sl(),
            tokenService: di.sl(),
          ),
        ),
        ChangeNotifierProvider<NotificationProvider>.value(
          value: di.sl<NotificationProvider>(),
        ),
        Provider<NotificationRemoteDataSource>.value(
          value: di.sl<NotificationRemoteDataSource>(),
        ),
        ChangeNotifierProvider<AdminUsersProvider>.value(
          value: di.sl<AdminUsersProvider>(),
        ),
        ChangeNotifierProvider<AdminTransactionsProvider>.value(
          value: di.sl<AdminTransactionsProvider>(),
        ),
        ChangeNotifierProvider<PaymentConfigProvider>(
          create: (_) => PaymentConfigProvider(
            dataSource: PaymentConfigRemoteDataSourceImpl(dioClient: di.sl()),
          ),
        ),
        ChangeNotifierProvider<RuntimeSettingsProvider>(
          create: (_) => RuntimeSettingsProvider(
            repository: di.sl<SystemConfigRepository>(),
          ),
        ),
        ChangeNotifierProvider<OnchainChainPickerProvider>(
          create: (_) => OnchainChainPickerProvider(
            dataSource: TreasuryRemoteDataSourceImpl(dioClient: di.sl()),
            prefs: di.sl<di.SharedPreferences>(),
          ),
        ),
        ChangeNotifierProvider<TreasuryProvider>(
          create: (_) => TreasuryProvider(
            dataSource: TreasuryRemoteDataSourceImpl(dioClient: di.sl()),
          ),
        ),
        ChangeNotifierProvider<TreasuryMainWalletProvider>(
          create: (context) => TreasuryMainWalletProvider(
            dataSource: TreasuryRemoteDataSourceImpl(dioClient: di.sl()),
            authRepo: di.sl(),
            tokenService: di.sl(),
            chainPicker: context.read<OnchainChainPickerProvider>(),
            roleResolver: () => context.read<AuthProvider>().role,
          ),
        ),
        ChangeNotifierProvider<MarketMakerProvider>(
          create: (_) => MarketMakerProvider(
            dataSource: MarketMakerRemoteDataSourceImpl(dioClient: di.sl()),
          ),
        ),
        ChangeNotifierProvider<WithdrawalManagementProvider>(
          create: (_) => WithdrawalManagementProvider(
            dataSource: WithdrawalAdminRemoteDataSourceImpl(dioClient: di.sl<DioClient>()),
          ),
        ),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, _) => MaterialApp(
          title: localeProvider.locale.languageCode == 'vi'
              ? 'Ứng dụng Giao dịch Crypto'
              : 'Crypto Trading App',
          debugShowCheckedModeBanner: false,
          scrollBehavior: const AppScrollBehavior(),
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LocaleProvider.supportedLocales,
          home: const MainScreen(),
        ),
      ),
    );
  }
}
