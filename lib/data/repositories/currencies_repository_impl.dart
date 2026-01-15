import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/data/datasources/currencies_remote_datasource.dart';
import 'package:crypto_trading_app/domain/entities/currency.dart';
import 'package:crypto_trading_app/domain/repositories/currencies_repository.dart';

/// Currencies Repository Implementation
/// Following Repository Pattern - converts exceptions to failures
class CurrenciesRepositoryImpl implements CurrenciesRepository {
  final CurrenciesRemoteDataSource remoteDataSource;

  CurrenciesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Currency>>> getCurrencies({
    bool? isActive,
    bool? isTradable,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final currencyModels = await remoteDataSource.getCurrencies(
        isActive: isActive,
        isTradable: isTradable,
        page: page,
        limit: limit,
      );
      
      final currencies = currencyModels.map((model) => model.toEntity()).toList();
      return Right(currencies);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Currency>> getCurrencyById(int currencyId) async {
    try {
      final currencyModel = await remoteDataSource.getCurrencyById(currencyId);
      return Right(currencyModel.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Currency>> getCurrencyBySymbol(String symbol) async {
    try {
      final currencyModel = await remoteDataSource.getCurrencyBySymbol(symbol);
      return Right(currencyModel.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
