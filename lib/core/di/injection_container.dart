import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/data/datasources/auth_remote_datasource.dart';
import 'package:crypto_trading_app/data/datasources/user_remote_datasource.dart';
import 'package:crypto_trading_app/data/repositories/auth_repository_impl.dart';
import 'package:crypto_trading_app/domain/usecases/auth_usecases.dart';

// Export for hot reload check
export 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

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

  // ===== Data Sources =====
  // Auth Remote Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  // User Remote Data Source
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(dio: sl()),
  );

  // ===== Repositories =====
  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // ===== Use Cases =====
  // Auth Use Cases
  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton(() => RegisterUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(repository: sl()));
}
