import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/core/usecases/usecase.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/domain/repositories/markets_repository.dart';
import 'package:equatable/equatable.dart';

/// Get All Markets Use Case
class GetMarketsUseCase implements UseCase<List<MarketPair>, GetMarketsParams> {
  final MarketsRepository repository;

  GetMarketsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<MarketPair>>> call(GetMarketsParams params) async {
    return await repository.getMarkets(
      isActive: params.isActive,
      baseCurrency: params.baseCurrency,
      quoteCurrency: params.quoteCurrency,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetMarketsParams extends Equatable {
  final bool? isActive;
  final String? baseCurrency;
  final String? quoteCurrency;
  final int page;
  final int limit;

  const GetMarketsParams({
    this.isActive,
    this.baseCurrency,
    this.quoteCurrency,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [isActive, baseCurrency, quoteCurrency, page, limit];
}

/// Get Market By ID Use Case
class GetMarketByIdUseCase implements UseCase<MarketPair, int> {
  final MarketsRepository repository;

  GetMarketByIdUseCase({required this.repository});

  @override
  Future<Either<Failure, MarketPair>> call(int pairId) async {
    return await repository.getMarketById(pairId);
  }
}

/// Get Market By Symbol Use Case
class GetMarketBySymbolUseCase implements UseCase<MarketPair, String> {
  final MarketsRepository repository;

  GetMarketBySymbolUseCase({required this.repository});

  @override
  Future<Either<Failure, MarketPair>> call(String symbol) async {
    return await repository.getMarketBySymbol(symbol);
  }
}

/// Get Market Ticker Use Case
class GetMarketTickerUseCase implements UseCase<MarketTicker, int> {
  final MarketsRepository repository;

  GetMarketTickerUseCase({required this.repository});

  @override
  Future<Either<Failure, MarketTicker>> call(int pairId) async {
    return await repository.getMarketTicker(pairId);
  }
}

/// Get Order Book Use Case
class GetOrderBookUseCase implements UseCase<OrderBook, GetOrderBookParams> {
  final MarketsRepository repository;

  GetOrderBookUseCase({required this.repository});

  @override
  Future<Either<Failure, OrderBook>> call(GetOrderBookParams params) async {
    return await repository.getOrderBook(
      pairId: params.pairId,
      limit: params.limit,
    );
  }
}

class GetOrderBookParams extends Equatable {
  final int pairId;
  final int limit;

  const GetOrderBookParams({
    required this.pairId,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [pairId, limit];
}

/// Get OHLCV Use Case
class GetOHLCVUseCase implements UseCase<List<OHLCV>, GetOHLCVParams> {
  final MarketsRepository repository;

  GetOHLCVUseCase({required this.repository});

  @override
  Future<Either<Failure, List<OHLCV>>> call(GetOHLCVParams params) async {
    return await repository.getOHLCV(
      pairId: params.pairId,
      interval: params.interval,
      startTime: params.startTime,
      endTime: params.endTime,
      limit: params.limit,
    );
  }
}

class GetOHLCVParams extends Equatable {
  final int pairId;
  final String interval;
  final String? startTime;
  final String? endTime;
  final int limit;

  const GetOHLCVParams({
    required this.pairId,
    this.interval = '1h',
    this.startTime,
    this.endTime,
    this.limit = 100,
  });

  @override
  List<Object?> get props => [pairId, interval, startTime, endTime, limit];
}
