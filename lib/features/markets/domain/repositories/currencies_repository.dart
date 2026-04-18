import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/features/markets/domain/entities/currency.dart';
import 'package:crypto_trading_app/features/markets/domain/dtos/create_currency_dto.dart';
import 'package:crypto_trading_app/features/markets/domain/dtos/update_currency_dto.dart';

/// Currencies Repository Interface
/// Following Dependency Inversion Principle (DIP)
/// Domain layer defines the contract, data layer implements it
/// Following Interface Segregation Principle (ISP) - clean, focused interface
abstract class CurrenciesRepository {
  /// Get all currencies with pagination, optional text search and filters.
  ///
  /// [search]          — partial match on symbol or name (case-insensitive).
  /// [isTradable]      — filter by tradable status; omit = no filter.
  /// [isActive]        — filter by active status; omit = governed by [includeInactive].
  /// [includeInactive] — when true, inactive currencies are included unless [isActive] overrides.
  Future<Either<Failure, PaginatedCurrenciesResult>> getCurrencies({
    int page = 1,
    int limit = 10,
    bool includeInactive = false,
    String? search,
    bool? isTradable,
    bool? isActive,
  });

  /// Get all active currencies (cached endpoint - faster)
  Future<Either<Failure, List<Currency>>> getActiveCurrencies();

  /// Get all tradable currencies (cached endpoint - faster)
  Future<Either<Failure, List<Currency>>> getTradableCurrencies();

  /// Get currency by ID
  Future<Either<Failure, Currency>> getCurrencyById(String currencyId);

  /// Get currency by symbol
  Future<Either<Failure, Currency>> getCurrencyBySymbol(String symbol);

  /// Create new currency (Admin only)
  Future<Either<Failure, Currency>> createCurrency(CreateCurrencyDto dto);

  /// Update currency (Admin only)
  Future<Either<Failure, Currency>> updateCurrency(
    String currencyId,
    UpdateCurrencyDto dto,
  );

  /// Delete currency (soft delete - Admin only)
  Future<Either<Failure, void>> deleteCurrency(String currencyId);
}

/// Paginated Currencies Result
/// Following Value Object Pattern
class PaginatedCurrenciesResult {
  final List<Currency> currencies;
  final int total;
  final int page;
  final int limit;

  const PaginatedCurrenciesResult({
    required this.currencies,
    required this.total,
    required this.page,
    required this.limit,
  });
}
