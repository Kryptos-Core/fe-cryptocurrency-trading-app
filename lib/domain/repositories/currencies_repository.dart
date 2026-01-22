import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/currency.dart';
import 'package:crypto_trading_app/data/models/create_currency_dto.dart';
import 'package:crypto_trading_app/data/models/update_currency_dto.dart';

/// Currencies Repository Interface
/// Following Dependency Inversion Principle (DIP)
/// Domain layer defines the contract, data layer implements it
/// Following Interface Segregation Principle (ISP) - clean, focused interface
abstract class CurrenciesRepository {
  /// Get all currencies with pagination and filtering
  /// Returns paginated result with total, page, limit
  Future<Either<Failure, PaginatedCurrenciesResult>> getCurrencies({
    int page = 1,
    int limit = 10,
    bool includeInactive = false,
  });

  /// Get all active currencies (cached endpoint - faster)
  Future<Either<Failure, List<Currency>>> getActiveCurrencies();

  /// Get all tradable currencies (cached endpoint - faster)
  Future<Either<Failure, List<Currency>>> getTradableCurrencies();

  /// Get currency by ID
  Future<Either<Failure, Currency>> getCurrencyById(int currencyId);

  /// Get currency by symbol
  Future<Either<Failure, Currency>> getCurrencyBySymbol(String symbol);

  /// Create new currency (Admin only)
  Future<Either<Failure, Currency>> createCurrency(CreateCurrencyDto dto);

  /// Update currency (Admin only)
  Future<Either<Failure, Currency>> updateCurrency(
    int currencyId,
    UpdateCurrencyDto dto,
  );

  /// Delete currency (soft delete - Admin only)
  Future<Either<Failure, void>> deleteCurrency(int currencyId);
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
