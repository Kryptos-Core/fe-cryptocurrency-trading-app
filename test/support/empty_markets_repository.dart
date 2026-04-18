import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/features/markets/data/models/create_market_pair_dto.dart';
import 'package:crypto_trading_app/features/markets/data/models/update_market_pair_dto.dart';
import 'package:crypto_trading_app/features/markets/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/features/markets/domain/repositories/markets_repository.dart';

/// [MarketsRepository] that returns an empty catalog (post–db:clean style).
class EmptyMarketsRepository implements MarketsRepository {
  static const _f = ServerFailure(message: 'empty test catalog');

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
    return const Right(
      PaginatedMarketsResult(
        markets: [],
        total: 0,
        page: 1,
        limit: 10,
        totalPages: 0,
      ),
    );
  }

  @override
  Future<Either<Failure, List<MarketPair>>> getActiveMarkets() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, MarketPair>> getMarketById(String pairId) async {
    return const Left(_f);
  }

  @override
  Future<Either<Failure, MarketPair>> getMarketBySymbol(String symbol) async {
    return const Left(_f);
  }

  @override
  Future<Either<Failure, MarketTicker>> getMarketTicker(String pairId) async {
    return const Left(_f);
  }

  @override
  Future<Either<Failure, MarketTicker>> getMarketTickerBySymbol(
      String symbol) async {
    return const Left(_f);
  }

  @override
  Future<Either<Failure, List<MarketTicker>>> getAllTickers() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, OrderBook>> getOrderBook({
    required String pairId,
    int limit = 20,
  }) async {
    return const Left(_f);
  }

  @override
  Future<Either<Failure, OrderBook>> getOrderBookBySymbol({
    required String symbol,
    int limit = 20,
  }) async {
    return const Left(_f);
  }

  @override
  Future<Either<Failure, List<Trade>>> getTrades({
    required String pairId,
    int limit = 50,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Trade>>> getTradesBySymbol({
    required String symbol,
    int limit = 50,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<OHLCV>>> getOHLCV({
    required String pairId,
    String? interval,
    String? range,
    String? startTime,
    String? endTime,
    int limit = 100,
    String? locale,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, MarketPair>> createMarketPair(
      CreateMarketPairDto dto) async {
    return const Left(_f);
  }

  @override
  Future<Either<Failure, MarketPair>> updateMarketPair(
    String pairId,
    UpdateMarketPairDto dto,
  ) async {
    return const Left(_f);
  }

  @override
  Future<Either<Failure, void>> deleteMarketPair(String pairId) async {
    return const Left(_f);
  }
}
