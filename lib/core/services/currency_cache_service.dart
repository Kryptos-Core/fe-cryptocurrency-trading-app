import 'package:crypto_trading_app/features/markets/domain/entities/currency.dart';

/// Currency Cache Service
/// Following Strategy Pattern - different caching strategies can be implemented
/// Following Single Responsibility Principle (SRP) - only handles caching
abstract class CurrencyCacheService {
  /// Get cached active currencies
  Future<List<Currency>?> getCachedActiveCurrencies();

  /// Cache active currencies
  Future<void> cacheActiveCurrencies(List<Currency> currencies);

  /// Get cached tradable currencies
  Future<List<Currency>?> getCachedTradableCurrencies();

  /// Cache tradable currencies
  Future<void> cacheTradableCurrencies(List<Currency> currencies);

  /// Clear all cached currencies
  Future<void> clearCache();

  /// Check if cache is valid (not expired)
  bool isCacheValid(DateTime cacheTime, {Duration ttl = const Duration(minutes: 5)});
}

/// In-Memory Currency Cache Service Implementation
/// Following Singleton Pattern for single cache instance
class InMemoryCurrencyCacheService implements CurrencyCacheService {
  static InMemoryCurrencyCacheService? _instance;
  
  InMemoryCurrencyCacheService._internal();
  
  factory InMemoryCurrencyCacheService() {
    _instance ??= InMemoryCurrencyCacheService._internal();
    return _instance!;
  }

  List<Currency>? _cachedActiveCurrencies;
  DateTime? _activeCurrenciesCacheTime;
  
  List<Currency>? _cachedTradableCurrencies;
  DateTime? _tradableCurrenciesCacheTime;

  static const Duration defaultTtl = Duration(minutes: 5);

  @override
  Future<List<Currency>?> getCachedActiveCurrencies() async {
    if (_cachedActiveCurrencies == null || _activeCurrenciesCacheTime == null) {
      return null;
    }
    
    if (!isCacheValid(_activeCurrenciesCacheTime!)) {
      _cachedActiveCurrencies = null;
      _activeCurrenciesCacheTime = null;
      return null;
    }
    
    return _cachedActiveCurrencies;
  }

  @override
  Future<void> cacheActiveCurrencies(List<Currency> currencies) async {
    _cachedActiveCurrencies = currencies;
    _activeCurrenciesCacheTime = DateTime.now();
  }

  @override
  Future<List<Currency>?> getCachedTradableCurrencies() async {
    if (_cachedTradableCurrencies == null || _tradableCurrenciesCacheTime == null) {
      return null;
    }
    
    if (!isCacheValid(_tradableCurrenciesCacheTime!)) {
      _cachedTradableCurrencies = null;
      _tradableCurrenciesCacheTime = null;
      return null;
    }
    
    return _cachedTradableCurrencies;
  }

  @override
  Future<void> cacheTradableCurrencies(List<Currency> currencies) async {
    _cachedTradableCurrencies = currencies;
    _tradableCurrenciesCacheTime = DateTime.now();
  }

  @override
  Future<void> clearCache() async {
    _cachedActiveCurrencies = null;
    _activeCurrenciesCacheTime = null;
    _cachedTradableCurrencies = null;
    _tradableCurrenciesCacheTime = null;
  }

  @override
  bool isCacheValid(DateTime cacheTime, {Duration ttl = defaultTtl}) {
    final now = DateTime.now();
    return now.difference(cacheTime) < ttl;
  }
}
