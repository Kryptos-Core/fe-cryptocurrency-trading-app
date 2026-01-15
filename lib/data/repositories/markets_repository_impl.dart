import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/data/datasources/markets_remote_datasource.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/domain/repositories/markets_repository.dart';

/// Markets Repository Implementation
class MarketsRepositoryImpl implements MarketsRepository {
  final MarketsRemoteDataSource remoteDataSource;

  MarketsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MarketPair>>> getMarkets({
    bool? isActive,
    String? baseCurrency,
    String? quoteCurrency,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final marketModels = await remoteDataSource.getMarkets(
        isActive: isActive,
        baseCurrency: baseCurrency,
        quoteCurrency: quoteCurrency,
        page: page,
        limit: limit,
      );
      
      final markets = marketModels.map((model) => model.toEntity()).toList();
      return Right(markets);
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
  Future<Either<Failure, MarketPair>> getMarketById(int pairId) async {
    try {
      final marketModel = await remoteDataSource.getMarketById(pairId);
      return Right(marketModel.toEntity());
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
  Future<Either<Failure, MarketPair>> getMarketBySymbol(String symbol) async {
    try {
      final marketModel = await remoteDataSource.getMarketBySymbol(symbol);
      return Right(marketModel.toEntity());
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
  Future<Either<Failure, MarketTicker>> getMarketTicker(int pairId) async {
    try {
      final tickerModel = await remoteDataSource.getMarketTicker(pairId);
      return Right(tickerModel.toEntity());
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
  Future<Either<Failure, OrderBook>> getOrderBook({
    required int pairId,
    int limit = 20,
  }) async {
    try {
      final orderBookModel = await remoteDataSource.getOrderBook(
        pairId: pairId,
        limit: limit,
      );
      return Right(orderBookModel.toEntity());
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
  Future<Either<Failure, List<OHLCV>>> getOHLCV({
    required int pairId,
    String interval = '1h',
    String? startTime,
    String? endTime,
    int limit = 100,
  }) async {
    try {
      final ohlcvModels = await remoteDataSource.getOHLCV(
        pairId: pairId,
        interval: interval,
        startTime: startTime,
        endTime: endTime,
        limit: limit,
      );
      
      final ohlcv = ohlcvModels.map((model) => model.toEntity()).toList();
      return Right(ohlcv);
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
