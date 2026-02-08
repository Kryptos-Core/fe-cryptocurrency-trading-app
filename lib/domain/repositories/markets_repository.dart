import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/data/models/create_market_pair_dto.dart';
import 'package:crypto_trading_app/data/models/update_market_pair_dto.dart';

/// Markets Repository Interface
/// Following Dependency Inversion Principle (DIP)
/// Domain layer defines the contract, data layer implements it
/// Following Interface Segregation Principle (ISP) - clean, focused interface
abstract class MarketsRepository {
  /// Get all market pairs with pagination and filtering
  /// Returns paginated result with total, page, limit
  Future<Either<Failure, PaginatedMarketsResult>> getMarkets({
    int page = 1,
    int limit = 10,
    bool includeInactive = false,
  });

  /// Get all active market pairs (cached endpoint - faster)
  Future<Either<Failure, List<MarketPair>>> getActiveMarkets();

  /// Get market pair by ID
  Future<Either<Failure, MarketPair>> getMarketById(int pairId);

  /// Get market pair by symbol
  Future<Either<Failure, MarketPair>> getMarketBySymbol(String symbol);

  /// Get market ticker by ID
  Future<Either<Failure, MarketTicker>> getMarketTicker(int pairId);

  /// Get market ticker by symbol
  Future<Either<Failure, MarketTicker>> getMarketTickerBySymbol(String symbol);

  /// Get all tickers for active markets
  Future<Either<Failure, List<MarketTicker>>> getAllTickers();

  /// Get order book by ID
  Future<Either<Failure, OrderBook>> getOrderBook({
    required int pairId,
    int limit = 20,
  });

  /// Get order book by symbol
  Future<Either<Failure, OrderBook>> getOrderBookBySymbol({
    required String symbol,
    int limit = 20,
  });

  /// Get recent trades by ID
  Future<Either<Failure, List<Trade>>> getTrades({
    required int pairId,
    int limit = 50,
  });

  /// Get recent trades by symbol
  Future<Either<Failure, List<Trade>>> getTradesBySymbol({
    required String symbol,
    int limit = 50,
  });

  /// Get OHLCV data for candlestick chart
  /// [range] optional: 1d, 1M, 3M, 1y, 5y – bộ lọc theo khoảng thời gian (now − range) đến now
  Future<Either<Failure, List<OHLCV>>> getOHLCV({
    required int pairId,
    String interval = '1h',
    String? range,
    String? startTime,
    String? endTime,
    int limit = 100,
  });

  /// Create market pair (Admin only)
  Future<Either<Failure, MarketPair>> createMarketPair(CreateMarketPairDto dto);

  /// Update market pair (Admin only)
  Future<Either<Failure, MarketPair>> updateMarketPair(
    int pairId,
    UpdateMarketPairDto dto,
  );

  /// Delete market pair (soft delete - Admin only)
  Future<Either<Failure, void>> deleteMarketPair(int pairId);
}

/// Paginated Markets Result
/// Following Value Object Pattern
class PaginatedMarketsResult {
  final List<MarketPair> markets;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginatedMarketsResult({
    required this.markets,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });
}
