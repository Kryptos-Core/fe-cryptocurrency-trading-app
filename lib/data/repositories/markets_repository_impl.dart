import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/data/datasources/markets_remote_datasource.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/domain/repositories/markets_repository.dart';
import 'package:crypto_trading_app/data/models/create_market_pair_dto.dart';
import 'package:crypto_trading_app/data/models/update_market_pair_dto.dart';

/// Markets Repository Implementation
/// Following Repository Pattern - converts exceptions to failures
/// Following Single Responsibility Principle (SRP) - only handles data conversion
class MarketsRepositoryImpl implements MarketsRepository {
  final MarketsRemoteDataSource remoteDataSource;

  MarketsRepositoryImpl({required this.remoteDataSource});

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
  Future<Either<Failure, PaginatedMarketsResult>> getMarkets({
    int page = 1,
    int limit = 10,
    bool includeInactive = false,
    bool includeTickers = false,
    String? search,
    String? baseSymbol,
    String? quoteSymbol,
    List<String>? quoteSymbols,
    String? sortBy,
    String? sortOrder,
    bool fuzzySearch = false,
  }) async {
    try {
      final result = await remoteDataSource.getMarkets(
        page: page,
        limit: limit,
        includeInactive: includeInactive,
        includeTickers: includeTickers,
        search: search,
        baseSymbol: baseSymbol,
        quoteSymbol: quoteSymbol,
        quoteSymbols: quoteSymbols,
        sortBy: sortBy,
        sortOrder: sortOrder,
        fuzzySearch: fuzzySearch,
      );

      final markets = result.data.map((model) => model.toEntity()).toList();
      final tickers = result.tickers?.map((model) => model.toEntity()).toList();
      final totalPages =
          result.totalPages ?? (result.total / result.limit).ceil();
      return Right(
        PaginatedMarketsResult(
          markets: markets,
          total: result.total,
          page: result.page,
          limit: result.limit,
          totalPages: totalPages,
          tickers: tickers,
        ),
      );
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, List<MarketPair>>> getActiveMarkets() async {
    try {
      final marketModels = await remoteDataSource.getActiveMarkets();
      final markets = marketModels.map((model) => model.toEntity()).toList();
      return Right(markets);
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, MarketPair>> getMarketById(String pairId) async {
    try {
      final marketModel = await remoteDataSource.getMarketById(pairId);
      return Right(marketModel.toEntity());
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, MarketPair>> getMarketBySymbol(String symbol) async {
    try {
      final marketModel = await remoteDataSource.getMarketBySymbol(symbol);
      return Right(marketModel.toEntity());
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, MarketTicker>> getMarketTicker(String pairId) async {
    try {
      final tickerModel = await remoteDataSource.getMarketTicker(pairId);
      return Right(tickerModel.toEntity());
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, MarketTicker>> getMarketTickerBySymbol(
      String symbol) async {
    try {
      final tickerModel =
          await remoteDataSource.getMarketTickerBySymbol(symbol);
      return Right(tickerModel.toEntity());
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, List<MarketTicker>>> getAllTickers() async {
    try {
      final tickerModels = await remoteDataSource.getAllTickers();
      final tickers = tickerModels.map((model) => model.toEntity()).toList();
      return Right(tickers);
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, OrderBook>> getOrderBook({
    required String pairId,
    int limit = 20,
  }) async {
    try {
      final orderBookModel = await remoteDataSource.getOrderBook(
        pairId: pairId,
        limit: limit,
      );
      return Right(orderBookModel.toEntity());
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, OrderBook>> getOrderBookBySymbol({
    required String symbol,
    int limit = 20,
  }) async {
    try {
      final orderBookModel = await remoteDataSource.getOrderBookBySymbol(
        symbol: symbol,
        limit: limit,
      );
      return Right(orderBookModel.toEntity());
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, List<Trade>>> getTrades({
    required String pairId,
    int limit = 50,
  }) async {
    try {
      final tradeModels = await remoteDataSource.getTrades(
        pairId: pairId,
        limit: limit,
      );
      final trades = tradeModels.map((model) => model.toEntity()).toList();
      return Right(trades);
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, List<Trade>>> getTradesBySymbol({
    required String symbol,
    int limit = 50,
  }) async {
    try {
      final tradeModels = await remoteDataSource.getTradesBySymbol(
        symbol: symbol,
        limit: limit,
      );
      final trades = tradeModels.map((model) => model.toEntity()).toList();
      return Right(trades);
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, List<OHLCV>>> getOHLCV({
    required String pairId,
    String? range,
    String? startTime,
    String? endTime,
    int limit = 100,
  }) async {
    try {
      final ohlcvModels = await remoteDataSource.getOHLCV(
        pairId: pairId,
        range: range,
        startTime: startTime,
        endTime: endTime,
        limit: limit,
      );

      final ohlcv = ohlcvModels.map((model) => model.toEntity()).toList();
      return Right(ohlcv);
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, MarketPair>> createMarketPair(
      CreateMarketPairDto dto) async {
    try {
      final marketModel = await remoteDataSource.createMarketPair(dto);
      return Right(marketModel.toEntity());
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, MarketPair>> updateMarketPair(
    String pairId,
    UpdateMarketPairDto dto,
  ) async {
    try {
      final marketModel = await remoteDataSource.updateMarketPair(pairId, dto);
      return Right(marketModel.toEntity());
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteMarketPair(String pairId) async {
    try {
      await remoteDataSource.deleteMarketPair(pairId);
      return const Right(null);
    } catch (e) {
      return _handleException(e);
    }
  }
}
