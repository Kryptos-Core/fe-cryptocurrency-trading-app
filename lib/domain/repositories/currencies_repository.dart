import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/currency.dart';

/// Currencies Repository Interface
/// Following Dependency Inversion Principle (DIP)
/// Domain layer defines the contract, data layer implements it
abstract class CurrenciesRepository {
  /// Get all currencies with optional filters
  Future<Either<Failure, List<Currency>>> getCurrencies({
    bool? isActive,
    bool? isTradable,
    int page = 1,
    int limit = 10,
  });

  /// Get currency by ID
  Future<Either<Failure, Currency>> getCurrencyById(int currencyId);

  /// Get currency by symbol
  Future<Either<Failure, Currency>> getCurrencyBySymbol(String symbol);
}
