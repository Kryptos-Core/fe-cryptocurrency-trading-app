import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';

/// Service Locator for Dependency Injection
/// Following Dependency Inversion Principle (DIP)
/// Using GetIt as a service locator pattern
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
/// This should be called in main() before runApp()
Future<void> initializeDependencies() async {
  // ===== External Dependencies =====
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // ===== Core =====
  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);

  // ===== Data Sources =====
  // Will be registered here as we create them

  // ===== Repositories =====
  // Will be registered here as we create them

  // ===== Use Cases =====
  // Will be registered here as we create them

  // ===== Providers / BLoCs =====
  // Will be registered here as we create them
}
