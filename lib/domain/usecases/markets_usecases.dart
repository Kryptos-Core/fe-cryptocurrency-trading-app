import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/core/usecases/usecase.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/domain/repositories/markets_repository.dart';
import 'package:crypto_trading_app/data/models/create_market_pair_dto.dart';
import 'package:crypto_trading_app/data/models/update_market_pair_dto.dart';
import 'package:equatable/equatable.dart';

/// Get All Markets Use Case
/// Following Single Responsibility Principle (SRP)
class GetMarketsUseCase
    implements UseCase<PaginatedMarketsResult, GetMarketsParams> {
  final MarketsRepository repository;

  GetMarketsUseCase({required this.repository});

  @override
  Future<Either<Failure, PaginatedMarketsResult>> call(
    GetMarketsParams params,
  ) async {
    return await repository.getMarkets(
      page: params.page,
      limit: params.limit,
      includeInactive: params.includeInactive,
    );
  }
}

class GetMarketsParams extends Equatable {
  final int page;
  final int limit;
  final bool includeInactive;

  const GetMarketsParams({
    this.page = 1,
    this.limit = 10,
    this.includeInactive = false,
  });

  @override
  List<Object?> get props => [page, limit, includeInactive];
}

/// Get Active Markets Use Case
/// Following Single Responsibility Principle (SRP)
class GetActiveMarketsUseCase
    implements UseCase<List<MarketPair>, NoParams> {
  final MarketsRepository repository;

  GetActiveMarketsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<MarketPair>>> call(NoParams params) async {
    return await repository.getActiveMarkets();
  }
}

/// Get Market By ID Use Case
/// Following Single Responsibility Principle (SRP)
class GetMarketByIdUseCase implements UseCase<MarketPair, int> {
  final MarketsRepository repository;

  GetMarketByIdUseCase({required this.repository});

  @override
  Future<Either<Failure, MarketPair>> call(int pairId) async {
    return await repository.getMarketById(pairId);
  }
}

/// Get Market By Symbol Use Case
/// Following Single Responsibility Principle (SRP)
class GetMarketBySymbolUseCase implements UseCase<MarketPair, String> {
  final MarketsRepository repository;

  GetMarketBySymbolUseCase({required this.repository});

  @override
  Future<Either<Failure, MarketPair>> call(String symbol) async {
    return await repository.getMarketBySymbol(symbol);
  }
}

/// Get Market Ticker By ID Use Case
/// Following Single Responsibility Principle (SRP)
class GetMarketTickerUseCase implements UseCase<MarketTicker, int> {
  final MarketsRepository repository;

  GetMarketTickerUseCase({required this.repository});

  @override
  Future<Either<Failure, MarketTicker>> call(int pairId) async {
    return await repository.getMarketTicker(pairId);
  }
}

/// Get Market Ticker By Symbol Use Case
/// Following Single Responsibility Principle (SRP)
class GetMarketTickerBySymbolUseCase
    implements UseCase<MarketTicker, String> {
  final MarketsRepository repository;

  GetMarketTickerBySymbolUseCase({required this.repository});

  @override
  Future<Either<Failure, MarketTicker>> call(String symbol) async {
    return await repository.getMarketTickerBySymbol(symbol);
  }
}

/// Get All Tickers Use Case
/// Following Single Responsibility Principle (SRP)
class GetAllTickersUseCase
    implements UseCase<List<MarketTicker>, NoParams> {
  final MarketsRepository repository;

  GetAllTickersUseCase({required this.repository});

  @override
  Future<Either<Failure, List<MarketTicker>>> call(NoParams params) async {
    return await repository.getAllTickers();
  }
}

/// Get Order Book Use Case
/// Following Single Responsibility Principle (SRP)
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

/// Get Order Book By Symbol Use Case
/// Following Single Responsibility Principle (SRP)
class GetOrderBookBySymbolUseCase
    implements UseCase<OrderBook, GetOrderBookBySymbolParams> {
  final MarketsRepository repository;

  GetOrderBookBySymbolUseCase({required this.repository});

  @override
  Future<Either<Failure, OrderBook>> call(
    GetOrderBookBySymbolParams params,
  ) async {
    return await repository.getOrderBookBySymbol(
      symbol: params.symbol,
      limit: params.limit,
    );
  }
}

class GetOrderBookBySymbolParams extends Equatable {
  final String symbol;
  final int limit;

  const GetOrderBookBySymbolParams({
    required this.symbol,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [symbol, limit];
}

/// Get Trades Use Case
/// Following Single Responsibility Principle (SRP)
class GetTradesUseCase implements UseCase<List<Trade>, GetTradesParams> {
  final MarketsRepository repository;

  GetTradesUseCase({required this.repository});

  @override
  Future<Either<Failure, List<Trade>>> call(GetTradesParams params) async {
    return await repository.getTrades(
      pairId: params.pairId,
      limit: params.limit,
    );
  }
}

class GetTradesParams extends Equatable {
  final int pairId;
  final int limit;

  const GetTradesParams({
    required this.pairId,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [pairId, limit];
}

/// Get Trades By Symbol Use Case
/// Following Single Responsibility Principle (SRP)
class GetTradesBySymbolUseCase
    implements UseCase<List<Trade>, GetTradesBySymbolParams> {
  final MarketsRepository repository;

  GetTradesBySymbolUseCase({required this.repository});

  @override
  Future<Either<Failure, List<Trade>>> call(
    GetTradesBySymbolParams params,
  ) async {
    return await repository.getTradesBySymbol(
      symbol: params.symbol,
      limit: params.limit,
    );
  }
}

class GetTradesBySymbolParams extends Equatable {
  final String symbol;
  final int limit;

  const GetTradesBySymbolParams({
    required this.symbol,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [symbol, limit];
}

/// Get OHLCV Use Case
/// Following Single Responsibility Principle (SRP)
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

/// Create Market Pair Use Case
/// Following Single Responsibility Principle (SRP)
class CreateMarketPairUseCase
    implements UseCase<MarketPair, CreateMarketPairParams> {
  final MarketsRepository repository;

  CreateMarketPairUseCase({required this.repository});

  @override
  Future<Either<Failure, MarketPair>> call(
    CreateMarketPairParams params,
  ) async {
    return await repository.createMarketPair(params.dto);
  }
}

class CreateMarketPairParams extends Equatable {
  final CreateMarketPairDto dto;

  const CreateMarketPairParams({required this.dto});

  @override
  List<Object?> get props => [dto];
}

/// Update Market Pair Use Case
/// Following Single Responsibility Principle (SRP)
class UpdateMarketPairUseCase
    implements UseCase<MarketPair, UpdateMarketPairParams> {
  final MarketsRepository repository;

  UpdateMarketPairUseCase({required this.repository});

  @override
  Future<Either<Failure, MarketPair>> call(
    UpdateMarketPairParams params,
  ) async {
    return await repository.updateMarketPair(params.pairId, params.dto);
  }
}

class UpdateMarketPairParams extends Equatable {
  final int pairId;
  final UpdateMarketPairDto dto;

  const UpdateMarketPairParams({
    required this.pairId,
    required this.dto,
  });

  @override
  List<Object?> get props => [pairId, dto];
}

/// Delete Market Pair Use Case
/// Following Single Responsibility Principle (SRP)
class DeleteMarketPairUseCase implements UseCase<void, int> {
  final MarketsRepository repository;

  DeleteMarketPairUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(int pairId) async {
    return await repository.deleteMarketPair(pairId);
  }
}
