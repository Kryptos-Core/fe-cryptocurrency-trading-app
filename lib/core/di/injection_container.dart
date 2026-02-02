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
import 'package:crypto_trading_app/data/repositories/auth_repository_impl.dart';
import 'package:crypto_trading_app/data/repositories/currencies_repository_impl.dart';
import 'package:crypto_trading_app/data/repositories/markets_repository_impl.dart';
import 'package:crypto_trading_app/data/repositories/wallets_repository_impl.dart';
import 'package:crypto_trading_app/domain/repositories/currencies_repository.dart';
import 'package:crypto_trading_app/domain/repositories/markets_repository.dart';
import 'package:crypto_trading_app/domain/repositories/wallets_repository.dart';
import 'package:crypto_trading_app/domain/repositories/wallet_repository.dart';
import 'package:crypto_trading_app/domain/usecases/auth_usecases.dart';
import 'package:crypto_trading_app/data/repositories/wallet_repository_impl.dart';
import 'package:crypto_trading_app/domain/usecases/get_wallet_balance_usecase.dart';
import 'package:crypto_trading_app/domain/usecases/execute_wallet_transaction_usecase.dart';
import 'package:crypto_trading_app/domain/usecases/currencies_usecases.dart';
import 'package:crypto_trading_app/domain/usecases/markets_usecases.dart';
import 'package:crypto_trading_app/domain/usecases/wallets_usecases.dart';
import 'package:crypto_trading_app/domain/usecases/get_wallet_balance_usecase.dart'
    as wallet_api_usecases;
import 'package:crypto_trading_app/domain/usecases/execute_wallet_transaction_usecase.dart'
    as wallet_api_usecases;

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
    return;
  }

  // ===== External Dependencies =====
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

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

  // ===== Repositories =====
  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
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

  // ===== Use Cases =====
  // Auth Use Cases
  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton(() => RegisterUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(repository: sl()));

  // Currencies Use Cases
  sl.registerLazySingleton(() => GetCurrenciesUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetActiveCurrenciesUseCase(repository: sl()));
  sl.registerLazySingleton(
      () => GetTradableCurrenciesUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetCurrencyByIdUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetCurrencyBySymbolUseCase(repository: sl()));
  sl.registerLazySingleton(() => CreateCurrencyUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateCurrencyUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteCurrencyUseCase(repository: sl()));

  // Markets Use Cases
  sl.registerLazySingleton(() => GetMarketsUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetActiveMarketsUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetMarketByIdUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetMarketBySymbolUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetMarketTickerUseCase(repository: sl()));
  sl.registerLazySingleton(
      () => GetMarketTickerBySymbolUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetAllTickersUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetOrderBookUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetOrderBookBySymbolUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetTradesUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetTradesBySymbolUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetOHLCVUseCase(repository: sl()));
  sl.registerLazySingleton(() => CreateMarketPairUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateMarketPairUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteMarketPairUseCase(repository: sl()));

  // Wallets Use Cases
  sl.registerLazySingleton(() => GetWalletsUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetWalletByCurrencyUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetWalletBalanceUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetWalletLedgerUseCase(repository: sl()));

  // New Wallet API Use Cases
  sl.registerLazySingleton(
    () => wallet_api_usecases.GetWalletBalanceApiUseCase(
      walletRepository: sl<WalletRepository>(),
    ),
  );
  sl.registerLazySingleton(
    () => wallet_api_usecases.ExecuteWalletTransactionApiUseCase(
      walletRepository: sl<WalletRepository>(),
    ),
  );
}
