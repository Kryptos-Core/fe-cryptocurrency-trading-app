import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/core/services/currency_cache_service.dart';
import 'package:crypto_trading_app/data/datasources/auth_remote_datasource.dart';
import 'package:crypto_trading_app/data/datasources/user_remote_datasource.dart';
import 'package:crypto_trading_app/data/datasources/currencies_remote_datasource.dart';
import 'package:crypto_trading_app/data/datasources/markets_remote_datasource.dart';
import 'package:crypto_trading_app/data/datasources/wallets_remote_datasource.dart';
import 'package:crypto_trading_app/data/datasources/wallet_remote_datasource.dart';
import 'package:crypto_trading_app/data/datasources/wallet_local_datasource.dart';
import 'package:crypto_trading_app/data/datasources/orders_remote_datasource.dart';
import 'package:crypto_trading_app/data/datasources/deposit_remote_datasource.dart';

import 'package:crypto_trading_app/data/datasources/exchange_remote_datasource.dart';
import 'package:crypto_trading_app/data/datasources/dashboard_remote_datasource.dart';
import 'package:crypto_trading_app/data/repositories/auth_repository_impl.dart';
import 'package:crypto_trading_app/data/repositories/currencies_repository_impl.dart';
import 'package:crypto_trading_app/data/repositories/markets_repository_impl.dart';
import 'package:crypto_trading_app/data/repositories/wallets_repository_impl.dart';
import 'package:crypto_trading_app/domain/repositories/currencies_repository.dart';
import 'package:crypto_trading_app/domain/repositories/markets_repository.dart';
import 'package:crypto_trading_app/domain/repositories/wallets_repository.dart';
import 'package:crypto_trading_app/domain/repositories/wallet_repository.dart';
import 'package:crypto_trading_app/domain/repositories/orders_repository.dart';
import 'package:crypto_trading_app/domain/repositories/deposit_repository.dart';
import 'package:crypto_trading_app/domain/repositories/blockchain_repository.dart';
import 'package:crypto_trading_app/data/repositories/wallet_repository_impl.dart';
import 'package:crypto_trading_app/data/repositories/deposit_repository_impl.dart';
import 'package:crypto_trading_app/data/repositories/orders_repository_impl.dart';
import 'package:crypto_trading_app/data/repositories/blockchain_repository_impl.dart';
import 'package:crypto_trading_app/data/repositories/managed_wallets_repository_impl.dart';
import 'package:crypto_trading_app/domain/repositories/managed_wallets_repository.dart';
import 'package:crypto_trading_app/presentation/providers/managed_wallets_provider.dart';
import 'package:crypto_trading_app/core/services/websocket_service.dart';
import 'package:crypto_trading_app/core/services/fcm_service.dart';
import 'package:crypto_trading_app/core/services/notifications_socket_service.dart';
import 'package:crypto_trading_app/data/datasources/notification_remote_datasource.dart';
import 'package:crypto_trading_app/data/repositories/notification_repository_impl.dart';
import 'package:crypto_trading_app/domain/repositories/notification_repository.dart';
import 'package:crypto_trading_app/presentation/providers/notification_provider.dart';
import 'package:crypto_trading_app/core/services/indicator_service.dart';
import 'package:crypto_trading_app/core/services/chart_cache_service.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/wallet_service.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/wallet_extension_precheck_service.dart';
import 'package:crypto_trading_app/presentation/providers/chart_provider.dart';
import 'package:crypto_trading_app/core/providers/locale_provider.dart';
import 'package:crypto_trading_app/core/providers/theme_provider.dart';
import 'package:crypto_trading_app/presentation/providers/admin_users_provider.dart';
import 'package:crypto_trading_app/presentation/providers/admin_transactions_provider.dart';

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


  // Exchange Remote Data Source (sync Binance → DB)
  sl.registerLazySingleton<ExchangeRemoteDataSource>(
    () => ExchangeRemoteDataSourceImpl(dio: sl()),
  );

  // Dashboard Remote Data Source
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(dio: sl()),
  );

  // ===== Repositories =====
  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      userRemoteDataSource: sl(),
    ),
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
      remoteDataSource: sl<NotificationRemoteDataSource>(),
    ),
  );
}
