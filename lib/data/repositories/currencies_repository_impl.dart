import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/data/datasources/currencies_remote_datasource.dart';
import 'package:crypto_trading_app/domain/entities/currency.dart';
import 'package:crypto_trading_app/domain/repositories/currencies_repository.dart';
import 'package:crypto_trading_app/data/models/create_currency_dto.dart';
import 'package:crypto_trading_app/data/models/update_currency_dto.dart';

/// Currencies Repository Implementation
/// Following Repository Pattern - converts exceptions to failures
/// Following Single Responsibility Principle (SRP) - only handles data conversion
class CurrenciesRepositoryImpl implements CurrenciesRepository {
  final CurrenciesRemoteDataSource remoteDataSource;

  CurrenciesRepositoryImpl({required this.remoteDataSource});

  /// Convert exception to failure
  /// Following DRY principle - single conversion method
  Either<Failure, T> _handleException<T>(Object e) {
    if (e is NetworkException) {
      return Left(NetworkFailure(message: e.message));
    } else if (e is NotFoundException) {
      return Left(NotFoundFailure(message: e.message));
    } else if (e is ValidationException) {
      return Left(ValidationFailure(message: e.message));
    } else if (e is AuthenticationException) {
      return Left(AuthenticationFailure(message: e.message));
    } else if (e is ServerException) {
      return Left(ServerFailure(message: e.message));
    } else {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedCurrenciesResult>> getCurrencies({
    int page = 1,
    int limit = 10,
    bool includeInactive = false,
    String? search,
    bool? isTradable,
    bool? isActive,
  }) async {
    try {
      final result = await remoteDataSource.getCurrencies(
        page: page,
        limit: limit,
        includeInactive: includeInactive,
        search: search,
        isTradable: isTradable,
        isActive: isActive,
      );

      final currencies = result.currencies.map((model) => model.toEntity()).toList();
      return Right(
        PaginatedCurrenciesResult(
          currencies: currencies,
          total: result.total,
          page: result.page,
          limit: result.limit,
        ),
      );
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, List<Currency>>> getActiveCurrencies() async {
    try {
      final currencyModels = await remoteDataSource.getActiveCurrencies();
      final currencies = currencyModels.map((model) => model.toEntity()).toList();
      return Right(currencies);
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, List<Currency>>> getTradableCurrencies() async {
    try {
      final currencyModels = await remoteDataSource.getTradableCurrencies();
      final currencies = currencyModels.map((model) => model.toEntity()).toList();
      return Right(currencies);
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, Currency>> getCurrencyById(String currencyId) async {
    try {
      final currencyModel = await remoteDataSource.getCurrencyById(currencyId);
      return Right(currencyModel.toEntity());
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, Currency>> getCurrencyBySymbol(String symbol) async {
    try {
      final currencyModel = await remoteDataSource.getCurrencyBySymbol(symbol);
      return Right(currencyModel.toEntity());
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, Currency>> createCurrency(CreateCurrencyDto dto) async {
    try {
      final currencyModel = await remoteDataSource.createCurrency(dto);
      return Right(currencyModel.toEntity());
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, Currency>> updateCurrency(
    String currencyId,
    UpdateCurrencyDto dto,
  ) async {
    try {
      final currencyModel = await remoteDataSource.updateCurrency(currencyId, dto);
      return Right(currencyModel.toEntity());
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteCurrency(String currencyId) async {
    try {
      await remoteDataSource.deleteCurrency(currencyId);
      return const Right(null);
    } catch (e) {
      return _handleException(e);
    }
  }
}
