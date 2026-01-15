import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';

/// Markets Repository Interface
/// Following Dependency Inversion Principle (DIP)
abstract class MarketsRepository {
  /// Get all market pairs with optional filters
  Future<Either<Failure, List<MarketPair>>> getMarkets({
    bool? isActive,
    String? baseCurrency,
    String? quoteCurrency,
    int page = 1,
    int limit = 10,
  });

  /// Get market pair by ID
  Future<Either<Failure, MarketPair>> getMarketById(int pairId);

  /// Get market pair by symbol
  Future<Either<Failure, MarketPair>> getMarketBySymbol(String symbol);

  /// Get market ticker
  Future<Either<Failure, MarketTicker>> getMarketTicker(int pairId);

  /// Get order book
  Future<Either<Failure, OrderBook>> getOrderBook({
    required int pairId,
    int limit = 20,
  });

  /// Get OHLCV data for candlestick chart
  Future<Either<Failure, List<OHLCV>>> getOHLCV({
    required int pairId,
    String interval = '1h',
    String? startTime,
    String? endTime,
    int limit = 100,
  });
}
