import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/core/services/currency_cache_service.dart';
import 'package:crypto_trading_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:crypto_trading_app/features/user/data/datasources/user_remote_datasource.dart';
import 'package:crypto_trading_app/features/markets/data/datasources/currencies_remote_datasource.dart';
import 'package:crypto_trading_app/features/markets/data/datasources/markets_remote_datasource.dart';
import 'package:crypto_trading_app/features/wallets/data/datasources/wallets_remote_datasource.dart';
import 'package:crypto_trading_app/features/wallets/data/datasources/wallet_remote_datasource.dart';
import 'package:crypto_trading_app/features/wallets/data/datasources/wallet_local_datasource.dart';
import 'package:crypto_trading_app/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:crypto_trading_app/features/deposits/data/datasources/deposit_remote_datasource.dart';

import 'package:crypto_trading_app/features/markets/data/datasources/exchange_remote_datasource.dart';
import 'package:crypto_trading_app/features/markets/domain/repositories/exchange_repository.dart';
import 'package:crypto_trading_app/features/treasury/data/datasources/treasury_remote_datasource.dart';
import 'package:crypto_trading_app/features/treasury/domain/repositories/treasury_repository.dart';
import 'package:crypto_trading_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:crypto_trading_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:crypto_trading_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:crypto_trading_app/features/auth/application/services/auth_wallet_flow_service.dart';
import 'package:crypto_trading_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:crypto_trading_app/features/markets/data/repositories/currencies_repository_impl.dart';
import 'package:crypto_trading_app/features/markets/data/repositories/markets_repository_impl.dart';
import 'package:crypto_trading_app/features/wallets/data/repositories/wallets_repository_impl.dart';
import 'package:crypto_trading_app/features/markets/domain/repositories/currencies_repository.dart';
import 'package:crypto_trading_app/features/markets/domain/repositories/markets_repository.dart';
import 'package:crypto_trading_app/features/wallets/domain/repositories/wallets_repository.dart';
import 'package:crypto_trading_app/features/wallets/domain/repositories/wallet_repository.dart';
import 'package:crypto_trading_app/features/deposits/domain/repositories/deposit_repository.dart';
import 'package:crypto_trading_app/features/markets/domain/repositories/exchange_rate_repository.dart';
import 'package:crypto_trading_app/features/blockchain/domain/repositories/blockchain_repository.dart';
import 'package:crypto_trading_app/features/orders/domain/repositories/orders_repository.dart';
import 'package:crypto_trading_app/features/wallets/data/repositories/wallet_repository_impl.dart';
import 'package:crypto_trading_app/features/deposits/data/repositories/deposit_repository_impl.dart';
import 'package:crypto_trading_app/features/markets/data/repositories/exchange_rate_repository_impl.dart';
import 'package:crypto_trading_app/features/blockchain/data/repositories/blockchain_repository_impl.dart';
import 'package:crypto_trading_app/features/managed_wallets/data/repositories/managed_wallets_repository_impl.dart';
import 'package:crypto_trading_app/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:crypto_trading_app/features/managed_wallets/domain/repositories/managed_wallets_repository.dart';
import 'package:crypto_trading_app/features/managed_wallets/presentation/providers/managed_wallets_provider.dart';
import 'package:crypto_trading_app/core/services/websocket_service.dart';
import 'package:crypto_trading_app/features/notifications/application/services/fcm_service.dart';
import 'package:crypto_trading_app/features/notifications/application/services/notifications_socket_service.dart';
import 'package:crypto_trading_app/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:crypto_trading_app/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:crypto_trading_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:crypto_trading_app/features/notifications/presentation/providers/notification_provider.dart';
import 'package:crypto_trading_app/core/services/indicator_service.dart';
import 'package:crypto_trading_app/core/services/chart_cache_service.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/wallet_service.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/wallet_extension_precheck_service.dart';
import 'package:crypto_trading_app/features/trading/presentation/providers/chart_provider.dart';
import 'package:crypto_trading_app/core/localization/locale_provider.dart';
import 'package:crypto_trading_app/core/theme/theme_provider.dart';
import 'package:crypto_trading_app/features/admin/users/presentation/providers/admin_users_provider.dart';
import 'package:crypto_trading_app/features/admin/transactions/presentation/providers/admin_transactions_provider.dart';
import 'package:crypto_trading_app/features/admin/shared/presentation/providers/admin_enums_provider.dart';
import 'package:crypto_trading_app/features/settings/data/repositories/system_config_repository.dart'
    as settings_data;
import 'package:crypto_trading_app/features/settings/domain/repositories/system_config_repository.dart';
import 'package:crypto_trading_app/core/services/secure_storage_service.dart';
import 'package:crypto_trading_app/features/binance_trading/data/datasources/binance_trading_remote_datasource.dart';
import 'package:crypto_trading_app/features/binance_trading/data/repositories/binance_trading_repository_impl.dart';
import 'package:crypto_trading_app/features/binance_trading/application/providers/binance_credentials_provider.dart';
import 'package:crypto_trading_app/features/binance_trading/application/providers/binance_trading_provider.dart';
import 'package:crypto_trading_app/features/ai_assistant/application/services/ai_assistant_socket_service.dart';
import 'package:crypto_trading_app/features/ai_assistant/data/datasources/ai_assistant_remote_datasource.dart';
import 'package:crypto_trading_app/features/ai_assistant/data/repositories/ai_assistant_repository_impl.dart';
import 'package:crypto_trading_app/features/ai_assistant/domain/repositories/ai_assistant_repository.dart';

// Export for hot reload check
export 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

/// Service Locator for Dependency Injection
/// Following Dependency Inversion Principle (DIP)
/// Using GetIt as a service locator pattern
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
/// This should be called in main() before runApp()
Future<void> initializeDependencies() async {
  // Skip if already initialized (for hot reload support)
  if (sl.isRegistered<SharedPreferences>()) {
    // Ensure ChartProvider is a factory even after hot reload
    if (sl.isRegistered<ChartProvider>()) {
      sl.unregister<ChartProvider>();
    }
    sl.registerFactory<ChartProvider>(
      () => ChartProvider(
        webSocketService: sl<IWebSocketService>(),
        indicatorService: sl<IndicatorService>(),
        chartCacheService: sl<ChartCacheService>(),
      ),
    );
    if (!sl.isRegistered<AdminEnumsProvider>()) {
      sl.registerLazySingleton<AdminEnumsProvider>(
        () => AdminEnumsProvider(dioClient: sl<DioClient>()),
      );
    }
    if (!sl.isRegistered<AuthWalletFlowService>()) {
      sl.registerLazySingleton<AuthWalletFlowService>(
        () => const AuthWalletFlowService(),
      );
    }
    return; // All other singletons remain registered
  }

  // ===== External Dependencies =====
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  sl.registerLazySingleton<LocaleProvider>(
    () => LocaleProvider(sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<ThemeProvider>(
    () => ThemeProvider(sl<SharedPreferences>()),
  );

  // ===== Core Services =====
  // TokenService - quản lý JWT tokens
  sl.registerLazySingleton<TokenService>(
    () => TokenService(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<SystemConfigRepository>(
    () => settings_data.SystemConfigRepositoryImpl(tokenService: sl()),
  );

  // DioClient - HTTP client với interceptors
  sl.registerLazySingleton<DioClient>(
    () => DioClient(tokenService: sl()),
  );

  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);

  // Currency Cache Service
  sl.registerLazySingleton<CurrencyCacheService>(
    () => InMemoryCurrencyCacheService(),
  );

  // ===== Data Sources =====
  // Auth Remote Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  // User Remote Data Source
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(dio: sl()),
  );

  // Currencies Remote Data Source
  sl.registerLazySingleton<CurrenciesRemoteDataSource>(
    () => CurrenciesRemoteDataSourceImpl(dio: sl()),
  );

  // Markets Remote Data Source
  sl.registerLazySingleton<MarketsRemoteDataSource>(
    () => MarketsRemoteDataSourceImpl(dio: sl()),
  );

  // Wallets Remote Data Source
  sl.registerLazySingleton<WalletsRemoteDataSource>(
    () => WalletsRemoteDataSourceImpl(dio: sl()),
  );

  // New Wallet API Data Sources
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<WalletLocalDataSource>(
    () => WalletLocalDataSourceImpl(),
  );

  // Orders Remote Data Source
  sl.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(dioClient: sl()),
  );

  // Deposits Remote Data Source
  sl.registerLazySingleton<DepositRemoteDataSource>(
    () => DepositRemoteDataSourceImpl(dioClient: sl()),
  );

  // Exchange repository (sync Binance → DB)
  sl.registerLazySingleton<ExchangeRepository>(
    () => ExchangeRemoteDataSourceImpl(dio: sl()),
  );

  // Dashboard Remote Data Source
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: sl<DashboardRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<TreasuryRepository>(
    () => TreasuryRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );

  // ===== Repositories =====
  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      userRemoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<AuthWalletFlowService>(
    () => const AuthWalletFlowService(),
  );

  // Currencies Repository
  sl.registerLazySingleton<CurrenciesRepository>(
    () => CurrenciesRepositoryImpl(remoteDataSource: sl()),
  );

  // Markets Repository
  sl.registerLazySingleton<MarketsRepository>(
    () => MarketsRepositoryImpl(remoteDataSource: sl()),
  );

  // Wallets Repository
  sl.registerLazySingleton<WalletsRepository>(
    () => WalletsRepositoryImpl(remoteDataSource: sl()),
  );

  // New Wallet API Repository
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(
      remoteDataSource: sl<WalletRemoteDataSource>(),
      localDataSource: sl<WalletLocalDataSource>(),
    ),
  );

  // Orders Repository
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(remoteDataSource: sl<OrdersRemoteDataSource>()),
  );

  // Deposits Repository
  sl.registerLazySingleton<DepositRepository>(
    () => DepositRepositoryImpl(remoteDataSource: sl()),
  );

  // Exchange Rate Repository
  sl.registerLazySingleton<ExchangeRateRepository>(
    () => ExchangeRateRepositoryImpl(dioClient: sl()),
  );

  // Blockchain Repository
  sl.registerLazySingleton<BlockchainRepository>(
    () => BlockchainRepositoryImpl(dio: sl<Dio>()),
  );

  // Managed Wallets Repository (Treasury / Finance Manager)
  sl.registerLazySingleton<ManagedWalletsRepository>(
    () => ManagedWalletsRepositoryImpl(dio: sl<Dio>()),
  );

  // Managed Wallets Provider
  sl.registerLazySingleton<ManagedWalletsProvider>(
    () => ManagedWalletsProvider(repository: sl<ManagedWalletsRepository>()),
  );

  // ===== Trading Chart Services =====
  // WebSocket Service - Realtime data
  sl.registerLazySingleton<IWebSocketService>(
    () => WebSocketService(),
  );

  // Indicator Service - Technical analysis
  sl.registerLazySingleton<IndicatorService>(
    () => IndicatorService(),
  );

  // Chart Cache - persist chart data per pair/interval (~1 month)
  sl.registerLazySingleton<ChartCacheService>(() => ChartCacheService());

  // Wallet signing strategy services (MetaMask/Phantom/TronLink + test fallback)
  sl.registerLazySingleton<WalletExtensionPrecheckService>(
    () => WalletExtensionPrecheckService(),
  );
  sl.registerLazySingleton<MetaMaskWalletService>(
    () => MetaMaskWalletService(),
  );
  sl.registerLazySingleton<PhantomWalletService>(
    () => PhantomWalletService(),
  );
  sl.registerLazySingleton<TronLinkWalletService>(
    () => TronLinkWalletService(),
  );
  sl.registerLazySingleton<ManualTestWalletService>(
    () => ManualTestWalletService(),
  );
  sl.registerLazySingleton<WalletServiceFactory>(
    () => WalletServiceFactory(
      metamaskWalletService: sl<MetaMaskWalletService>(),
      phantomWalletService: sl<PhantomWalletService>(),
      tronLinkWalletService: sl<TronLinkWalletService>(),
      manualTestWalletService: sl<ManualTestWalletService>(),
    ),
  );

  // Chart Provider - State management (factory per screen)
  sl.registerFactory<ChartProvider>(
    () => ChartProvider(
      webSocketService: sl<IWebSocketService>(),
      indicatorService: sl<IndicatorService>(),
      chartCacheService: sl<ChartCacheService>(),
    ),
  );

  // ===== Admin Users =====
  sl.registerLazySingleton<AdminUsersProvider>(
    () => AdminUsersProvider(dioClient: sl<DioClient>()),
  );

  sl.registerLazySingleton<AdminEnumsProvider>(
    () => AdminEnumsProvider(dioClient: sl<DioClient>()),
  );

  // ===== Admin Transactions =====
  sl.registerLazySingleton<AdminTransactionsProvider>(
    () => AdminTransactionsProvider(dioClient: sl<DioClient>()),
  );

  // ===== Notifications =====
  sl.registerLazySingleton<FcmService>(() => FcmService());
  sl.registerLazySingleton<NotificationsSocketService>(
    () => NotificationsSocketService(),
  );

  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<NotificationProvider>(
    () => NotificationProvider(
      repository: sl<NotificationRepository>(),
    ),
  );

  // ===== Binance Non-Custodial Trading =====
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );

  sl.registerLazySingleton<BinanceTradingRemoteDataSource>(
    () => BinanceTradingRemoteDataSource(dioClient: sl()),
  );

  sl.registerLazySingleton<BinanceTradingRepositoryImpl>(
    () => BinanceTradingRepositoryImpl(remoteDataSource: sl<BinanceTradingRemoteDataSource>()),
  );

  sl.registerLazySingleton<BinanceCredentialsProvider>(
    () => BinanceCredentialsProvider(
      dioClient: sl<DioClient>(),
      secureStorage: sl<SecureStorageService>(),
    ),
  );

  sl.registerFactory<BinanceTradingProvider>(
    () => BinanceTradingProvider(
      repository: sl<BinanceTradingRepositoryImpl>(),
    ),
  );

  // ===== AI Assistant (Vilao LLM) =====
  sl.registerLazySingleton<AiAssistantRemoteDataSource>(
    () => AiAssistantRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );
  sl.registerLazySingleton<AiAssistantRepository>(
    () => AiAssistantRepositoryImpl(remote: sl<AiAssistantRemoteDataSource>()),
  );
  sl.registerLazySingleton<AiAssistantSocketService>(
    () => AiAssistantSocketService(),
  );
}
