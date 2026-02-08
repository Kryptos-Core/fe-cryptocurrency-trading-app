import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/services/mock_service.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/data/models/market_pair_model.dart';
import 'package:crypto_trading_app/data/models/paginated_markets_response.dart';
import 'package:crypto_trading_app/data/models/create_market_pair_dto.dart';
import 'package:crypto_trading_app/data/models/update_market_pair_dto.dart';
import 'package:crypto_trading_app/data/models/trade_model.dart';
import 'package:crypto_trading_app/data/models/ohlcv_response.dart';
import 'package:crypto_trading_app/data/mocks/markets_mock.dart';
import 'package:crypto_trading_app/core/models/api_response.dart';
import 'package:crypto_trading_app/core/models/error_response.dart';

/// Markets Remote Data Source
/// Following Repository Pattern and Strategy Pattern (Mock vs Real API)
/// Following Interface Segregation Principle (ISP) - clean interface
abstract class MarketsRemoteDataSource {
  /// Get all market pairs with pagination and filtering
  Future<PaginatedMarketsData> getMarkets({
    int page = 1,
    int limit = 10,
    bool includeInactive = false,
  });

  /// Get all active market pairs (cached endpoint)
  Future<List<MarketPairModel>> getActiveMarkets();

  /// Get market pair by ID
  Future<MarketPairModel> getMarketById(int pairId);

  /// Get market pair by symbol
  Future<MarketPairModel> getMarketBySymbol(String symbol);

  /// Get market ticker by ID
  Future<MarketTickerModel> getMarketTicker(int pairId);

  /// Get market ticker by symbol
  Future<MarketTickerModel> getMarketTickerBySymbol(String symbol);

  /// Get all tickers for active markets
  Future<List<MarketTickerModel>> getAllTickers();

  /// Get order book by ID
  Future<OrderBookModel> getOrderBook({
    required int pairId,
    int limit = 20,
  });

  /// Get order book by symbol
  Future<OrderBookModel> getOrderBookBySymbol({
    required String symbol,
    int limit = 20,
  });

  /// Get recent trades by ID
  Future<List<TradeModel>> getTrades({
    required int pairId,
    int limit = 50,
  });

  /// Get recent trades by symbol
  Future<List<TradeModel>> getTradesBySymbol({
    required String symbol,
    int limit = 50,
  });

  /// Get OHLCV data
  /// [range] optional: 1d, 1M, 3M, 1y, 5y – khi có range thì backend chỉ trả nến trong khoảng (now − range) đến now; tối đa 500 nến.
  Future<List<OHLCVModel>> getOHLCV({
    required int pairId,
    String interval = '1h',
    String? range,
    String? startTime,
    String? endTime,
    int limit = 100,
  });

  /// Create market pair (Admin only)
  Future<MarketPairModel> createMarketPair(CreateMarketPairDto dto);

  /// Update market pair (Admin only)
  Future<MarketPairModel> updateMarketPair(int pairId, UpdateMarketPairDto dto);

  /// Delete market pair (soft delete - Admin only)
  Future<void> deleteMarketPair(int pairId);
}

class MarketsRemoteDataSourceImpl implements MarketsRemoteDataSource {
  final Dio dio;

  MarketsRemoteDataSourceImpl({required this.dio});

  /// Handle DioException and convert to appropriate exceptions
  /// Following DRY principle - single error handling method
  Never _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw NetworkException(message: 'Connection timeout');
    }

    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    if (statusCode == 401) {
      throw AuthenticationException(message: 'Unauthorized');
    } else if (statusCode == 404) {
      final message = responseData?['message'] ?? 'Resource not found';
      throw NotFoundException(message: message);
    } else if (statusCode == 400) {
      // Parse validation errors
      try {
        final errorResponse =
            ErrorResponse.fromJson(responseData as Map<String, dynamic>);
        throw ValidationException(
          message: errorResponse.message,
          errors: errorResponse.context,
        );
      } catch (_) {
        throw ValidationException(
          message: responseData?['message'] ?? 'Validation failed',
        );
      }
    } else if (statusCode == 409) {
      final message = responseData?['message'] ?? 'Resource already exists';
      throw ServerException(message: message, statusCode: statusCode);
    } else if (statusCode != null && statusCode >= 500) {
      throw ServerException(
        message: responseData?['message'] ?? 'Server error',
        statusCode: statusCode,
      );
    } else {
      throw ServerException(
        message: responseData?['message'] ?? e.message ?? 'Unknown error',
        statusCode: statusCode,
      );
    }
  }

  @override
  Future<PaginatedMarketsData> getMarkets({
    int page = 1,
    int limit = 10,
    bool includeInactive = false,
  }) async {
    if (MockService.isMockModeFor('markets')) {
      return MockService.mockResponse(() {
        var markets = MarketsMock.filter(
          isActive: includeInactive ? null : true,
          baseCurrency: null,
          quoteCurrency: null,
        );

        // Simple pagination
        final start = (page - 1) * limit;
        final end = start + limit;
        final paginatedMarkets = start >= markets.length
            ? <MarketPairModel>[]
            : markets.sublist(
                start,
                end > markets.length ? markets.length : end,
              );

        return PaginatedMarketsData(
          data: paginatedMarkets,
          total: markets.length,
          page: page,
          limit: limit,
          totalPages: (markets.length / limit).ceil(),
        );
      });
    }

    try {
      final response = await dio.get(
        ApiConstants.markets,
        queryParameters: {
          'page': page,
          'limit': limit,
          'includeInactive': includeInactive,
        },
      );

      if (response.statusCode == 200) {
        try {
          final responseData = response.data as Map<String, dynamic>;
          final success = responseData['success'] as bool? ?? false;
          if (!success) {
            throw ServerException(
              message: responseData['message'] as String? ??
                  'Failed to fetch markets',
            );
          }

          final dataJson = responseData['data'] as Map<String, dynamic>? ??
              <String, dynamic>{};
          final pairs = _parseMarketPairs(dataJson['pairs']);
          final parsedTotal = _toInt(dataJson['total'], fallback: pairs.length);
          final parsedPage = _toInt(dataJson['page'], fallback: page);
          final parsedLimit = _toInt(dataJson['limit'], fallback: limit);
          final parsedTotalPages = _toInt(dataJson['totalPages'], fallback: 0);

          return PaginatedMarketsData(
            data: pairs,
            total: parsedTotal,
            page: parsedPage,
            limit: parsedLimit,
            totalPages: parsedTotalPages == 0 ? null : parsedTotalPages,
          );
        } catch (e) {
          // Catch type cast errors and provide better error message
          if (e is TypeError || e.toString().contains('is not a subtype')) {
            throw ServerException(
              message: 'Invalid response format: ${e.toString()}',
            );
          }
          rethrow;
        }
      } else {
        throw ServerException(
          message: 'Failed to fetch markets',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is NetworkException ||
          e is ServerException ||
          e is NotFoundException ||
          e is ValidationException ||
          e is AuthenticationException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  int _toInt(dynamic value, {required int fallback}) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  List<MarketPairModel> _parseMarketPairs(dynamic pairsJson) {
    if (pairsJson is List) {
      return pairsJson
          .whereType<Map<String, dynamic>>()
          .map((item) => MarketPairModel.fromJson(item))
          .toList();
    }
    return <MarketPairModel>[];
  }

  @override
  Future<List<MarketPairModel>> getActiveMarkets() async {
    if (MockService.isMockModeFor('markets')) {
      return MockService.mockResponse(() {
        return MarketsMock.filter(
            isActive: true, baseCurrency: null, quoteCurrency: null);
      });
    }

    try {
      final response = await dio.get(ApiConstants.marketsActive);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<MarketPairModel>>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => (json as List)
              .map((item) =>
                  MarketPairModel.fromJson(item as Map<String, dynamic>))
              .toList(),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw ServerException(
            message: apiResponse.message ?? 'Failed to fetch active markets',
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to fetch active markets',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is NetworkException ||
          e is ServerException ||
          e is NotFoundException ||
          e is ValidationException ||
          e is AuthenticationException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MarketPairModel> getMarketById(int pairId) async {
    if (MockService.isMockModeFor('markets')) {
      return MockService.mockResponse(() {
        final market = MarketsMock.getById(pairId);
        if (market == null) {
          throw NotFoundException(
              message: 'Market pair with id $pairId not found');
        }
        return market;
      });
    }

    try {
      final response = await dio.get(ApiConstants.marketById(pairId));

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<MarketPairModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => MarketPairModel.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw NotFoundException(
            message:
                apiResponse.message ?? 'Market pair with id $pairId not found',
          );
        }
      } else {
        throw NotFoundException(
            message: 'Market pair with id $pairId not found');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is NetworkException ||
          e is ServerException ||
          e is NotFoundException ||
          e is ValidationException ||
          e is AuthenticationException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MarketPairModel> getMarketBySymbol(String symbol) async {
    if (MockService.isMockModeFor('markets')) {
      return MockService.mockResponse(() {
        final market = MarketsMock.getBySymbol(symbol);
        if (market == null) {
          throw NotFoundException(
              message: 'Market pair with symbol $symbol not found');
        }
        return market;
      });
    }

    try {
      // ApiConstants.marketBySymbol already handles URL encoding
      final response = await dio.get(ApiConstants.marketBySymbol(symbol));

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<MarketPairModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => MarketPairModel.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw NotFoundException(
            message: apiResponse.message ??
                'Market pair with symbol $symbol not found',
          );
        }
      } else {
        throw NotFoundException(
            message: 'Market pair with symbol $symbol not found');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is NetworkException ||
          e is ServerException ||
          e is NotFoundException ||
          e is ValidationException ||
          e is AuthenticationException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MarketTickerModel> getMarketTicker(int pairId) async {
    if (MockService.isMockModeFor('markets')) {
      return MockService.mockResponse(() {
        final basePrices = {1: 45000.0, 2: 2850.0, 3: 350.0, 4: 0.52, 5: 7.80};
        final basePrice = basePrices[pairId] ?? 100.0;
        return MarketsMock.generateTicker(pairId, basePrice: basePrice);
      });
    }

    try {
      final response = await dio.get(ApiConstants.marketTicker(pairId));

      if (response.statusCode == 200) {
        // Response wrap: { success, data: MarketTickerDto, timestamp }
        final apiResponse = ApiResponse<MarketTickerModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => MarketTickerModel.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw NotFoundException(
              message: apiResponse.message ?? 'Ticker not found');
        }
      } else {
        throw NotFoundException(message: 'Ticker not found');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is NetworkException ||
          e is ServerException ||
          e is NotFoundException ||
          e is ValidationException ||
          e is AuthenticationException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MarketTickerModel> getMarketTickerBySymbol(String symbol) async {
    if (MockService.isMockModeFor('markets')) {
      return MockService.mockResponse(() {
        final market = MarketsMock.getBySymbol(symbol);
        if (market == null) {
          throw NotFoundException(
              message: 'Market pair with symbol $symbol not found');
        }
        final basePrices = {1: 45000.0, 2: 2850.0, 3: 350.0, 4: 0.52, 5: 7.80};
        final basePrice = basePrices[market.pairId] ?? 100.0;
        return MarketsMock.generateTicker(market.pairId, basePrice: basePrice);
      });
    }

    try {
      final response = await dio.get(ApiConstants.marketTickerBySymbol(symbol));

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<MarketTickerModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => MarketTickerModel.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw NotFoundException(
              message: apiResponse.message ?? 'Ticker not found');
        }
      } else {
        throw NotFoundException(message: 'Ticker not found');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is NetworkException ||
          e is ServerException ||
          e is NotFoundException ||
          e is ValidationException ||
          e is AuthenticationException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<MarketTickerModel>> getAllTickers() async {
    if (MockService.isMockModeFor('markets')) {
      return MockService.mockResponse(() {
        final markets = MarketsMock.filter(
            isActive: true, baseCurrency: null, quoteCurrency: null);
        final basePrices = {1: 45000.0, 2: 2850.0, 3: 350.0, 4: 0.52, 5: 7.80};
        return markets.map((market) {
          final basePrice = basePrices[market.pairId] ?? 100.0;
          return MarketsMock.generateTicker(market.pairId,
              basePrice: basePrice);
        }).toList();
      });
    }

    try {
      final response = await dio.get(ApiConstants.marketsTickersAll);

      if (response.statusCode == 200) {
        // Response wrap: { success, data: MarketTickerDto[], timestamp }
        final apiResponse = ApiResponse<List<MarketTickerModel>>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => (json as List)
              .map((item) =>
                  MarketTickerModel.fromJson(item as Map<String, dynamic>))
              .toList(),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw ServerException(
            message: apiResponse.message ?? 'Failed to fetch all tickers',
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to fetch all tickers',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is NetworkException ||
          e is ServerException ||
          e is NotFoundException ||
          e is ValidationException ||
          e is AuthenticationException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<OrderBookModel> getOrderBook({
    required int pairId,
    int limit = 20,
  }) async {
    if (MockService.isMockModeFor('markets')) {
      return MockService.mockResponse(() {
        final basePrices = {1: 45000.0, 2: 2850.0, 3: 350.0, 4: 0.52, 5: 7.80};
        final basePrice = basePrices[pairId] ?? 100.0;
        return MarketsMock.generateOrderBook(pairId, basePrice: basePrice);
      });
    }

    try {
      final response = await dio.get(
        ApiConstants.marketOrderBook(pairId),
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<OrderBookModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => OrderBookModel.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw NotFoundException(
              message: apiResponse.message ?? 'Order book not found');
        }
      } else {
        throw NotFoundException(message: 'Order book not found');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is NetworkException ||
          e is ServerException ||
          e is NotFoundException ||
          e is ValidationException ||
          e is AuthenticationException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<OrderBookModel> getOrderBookBySymbol({
    required String symbol,
    int limit = 20,
  }) async {
    if (MockService.isMockModeFor('markets')) {
      return MockService.mockResponse(() {
        final market = MarketsMock.getBySymbol(symbol);
        if (market == null) {
          throw NotFoundException(
              message: 'Market pair with symbol $symbol not found');
        }
        final basePrices = {1: 45000.0, 2: 2850.0, 3: 350.0, 4: 0.52, 5: 7.80};
        final basePrice = basePrices[market.pairId] ?? 100.0;
        return MarketsMock.generateOrderBook(market.pairId,
            basePrice: basePrice);
      });
    }

    try {
      final response = await dio.get(
        ApiConstants.marketOrderBookBySymbol(symbol),
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<OrderBookModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => OrderBookModel.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw NotFoundException(
              message: apiResponse.message ?? 'Order book not found');
        }
      } else {
        throw NotFoundException(message: 'Order book not found');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is NetworkException ||
          e is ServerException ||
          e is NotFoundException ||
          e is ValidationException ||
          e is AuthenticationException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<TradeModel>> getTrades({
    required int pairId,
    int limit = 50,
  }) async {
    if (MockService.isMockModeFor('markets')) {
      return MockService.mockResponse(() {
        // Generate mock trades
        return List.generate(limit, (index) {
          return TradeModel(
            tradeId: 1000 + index,
            pairId: pairId,
            price: (45000.0 + (index * 10)).toStringAsFixed(2),
            amount: (0.1 + (index * 0.01)).toStringAsFixed(6),
            side: index % 2 == 0 ? 'BUY' : 'SELL',
            createdAt: DateTime.now().subtract(Duration(minutes: index)),
          );
        });
      });
    }

    try {
      final response = await dio.get(
        ApiConstants.marketTrades(pairId),
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<TradeModel>>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => (json as List)
              .map((item) => TradeModel.fromJson(item as Map<String, dynamic>))
              .toList(),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw NotFoundException(
              message: apiResponse.message ?? 'Trades not found');
        }
      } else {
        throw NotFoundException(message: 'Trades not found');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is NetworkException ||
          e is ServerException ||
          e is NotFoundException ||
          e is ValidationException ||
          e is AuthenticationException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<TradeModel>> getTradesBySymbol({
    required String symbol,
    int limit = 50,
  }) async {
    if (MockService.isMockModeFor('markets')) {
      return MockService.mockResponse(() {
        final market = MarketsMock.getBySymbol(symbol);
        if (market == null) {
          throw NotFoundException(
              message: 'Market pair with symbol $symbol not found');
        }
        return List.generate(limit, (index) {
          return TradeModel(
            tradeId: 1000 + index,
            pairId: market.pairId,
            price: (45000.0 + (index * 10)).toStringAsFixed(2),
            amount: (0.1 + (index * 0.01)).toStringAsFixed(6),
            side: index % 2 == 0 ? 'BUY' : 'SELL',
            createdAt: DateTime.now().subtract(Duration(minutes: index)),
          );
        });
      });
    }

    try {
      final response = await dio.get(
        ApiConstants.marketTradesBySymbol(symbol),
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<TradeModel>>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => (json as List)
              .map((item) => TradeModel.fromJson(item as Map<String, dynamic>))
              .toList(),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw NotFoundException(
              message: apiResponse.message ?? 'Trades not found');
        }
      } else {
        throw NotFoundException(message: 'Trades not found');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is NetworkException ||
          e is ServerException ||
          e is NotFoundException ||
          e is ValidationException ||
          e is AuthenticationException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<OHLCVModel>> getOHLCV({
    required int pairId,
    String interval = '1h',
    String? range,
    String? startTime,
    String? endTime,
    int limit = 100,
  }) async {
    if (MockService.isMockModeFor('markets')) {
      return MockService.mockResponse(() {
        final basePrices = {1: 45000.0, 2: 2850.0, 3: 350.0, 4: 0.52, 5: 7.80};
        final basePrice = basePrices[pairId] ?? 100.0;
        return MarketsMock.generateOHLCV(pairId,
            count: limit, basePrice: basePrice);
      });
    }

    try {
      final effectiveLimit = range != null ? 500 : limit;
      final response = await dio.get(
        ApiConstants.marketOHLCV(pairId),
        queryParameters: {
          'interval': interval,
          if (range != null) 'range': range,
          if (startTime != null && range == null) 'start_time': startTime,
          if (endTime != null && range == null) 'end_time': endTime,
          'limit': effectiveLimit,
        },
      );

      if (response.statusCode == 200) {
        final raw = response.data as Map<String, dynamic>;
        // BE có thể trả qua interceptor: { success, data: { pair_id, interval_sec, candles } } hoặc raw: { pair_id, interval_sec, candles }
        List<OHLCVModel> candles;
        if (raw.containsKey('data') && raw['data'] is Map) {
          final data = raw['data'] as Map<String, dynamic>;
          final list = data['candles'] as List<dynamic>?;
          candles = (list ?? [])
              .map((e) => OHLCVModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (raw.containsKey('candles')) {
          final list = raw['candles'] as List<dynamic>?;
          candles = (list ?? [])
              .map((e) => OHLCVModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          candles = [];
        }
        return candles;
      } else {
        throw NotFoundException(message: 'OHLCV data not found');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is NetworkException ||
          e is ServerException ||
          e is NotFoundException ||
          e is ValidationException ||
          e is AuthenticationException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MarketPairModel> createMarketPair(CreateMarketPairDto dto) async {
    if (MockService.isMockModeFor('markets')) {
      return MockService.mockResponse(() {
        // Mock implementation - create a new market pair
        final newId = MarketsMock.mockMarketPairs.length + 1;
        return MarketPairModel(
          pairId: newId,
          baseCurrencyId: dto.baseCurrencyId,
          quoteCurrencyId: dto.quoteCurrencyId,
          symbol: dto.symbol ?? 'NEW/USDT',
          baseCurrency: null,
          quoteCurrency: null,
          priceScale: dto.priceScale ?? 2,
          amountScale: dto.amountScale ?? 6,
          minOrderAmount: dto.minOrderAmount ?? '0.0001',
          makerFeeRate: (dto.makerFeeRate ?? 0.001).toString(),
          takerFeeRate: (dto.takerFeeRate ?? 0.001).toString(),
          isActive: dto.isActive ?? true,
          createdAt: DateTime.now(),
        );
      });
    }

    try {
      final response = await dio.post(
        ApiConstants.markets,
        data: dto.toJson(),
      );

      if (response.statusCode == 201) {
        final apiResponse = ApiResponse<MarketPairModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => MarketPairModel.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw ServerException(
            message: apiResponse.message ?? 'Failed to create market pair',
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to create market pair',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is NetworkException ||
          e is ServerException ||
          e is NotFoundException ||
          e is ValidationException ||
          e is AuthenticationException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MarketPairModel> updateMarketPair(
      int pairId, UpdateMarketPairDto dto) async {
    if (MockService.isMockModeFor('markets')) {
      return MockService.mockResponse(() {
        final existing = MarketsMock.getById(pairId);
        if (existing == null) {
          throw NotFoundException(
              message: 'Market pair with id $pairId not found');
        }
        // Mock update - merge dto with existing
        return MarketPairModel(
          pairId: existing.pairId,
          baseCurrencyId: existing.baseCurrencyId,
          quoteCurrencyId: existing.quoteCurrencyId,
          symbol: existing.symbol,
          baseCurrency: existing.baseCurrency,
          quoteCurrency: existing.quoteCurrency,
          priceScale: dto.priceScale ?? existing.priceScale,
          amountScale: dto.amountScale ?? existing.amountScale,
          minOrderAmount: dto.minOrderAmount ?? existing.minOrderAmount,
          makerFeeRate: dto.makerFeeRate != null
              ? dto.makerFeeRate!.toString()
              : existing.makerFeeRate,
          takerFeeRate: dto.takerFeeRate != null
              ? dto.takerFeeRate!.toString()
              : existing.takerFeeRate,
          isActive: dto.isActive ?? existing.isActive,
          createdAt: existing.createdAt,
        );
      });
    }

    try {
      final response = await dio.patch(
        ApiConstants.marketById(pairId),
        data: dto.toJson(),
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<MarketPairModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => MarketPairModel.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw ServerException(
            message: apiResponse.message ?? 'Failed to update market pair',
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to update market pair',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is NetworkException ||
          e is ServerException ||
          e is NotFoundException ||
          e is ValidationException ||
          e is AuthenticationException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteMarketPair(int pairId) async {
    if (MockService.isMockModeFor('markets')) {
      return MockService.mockResponse(() {
        final existing = MarketsMock.getById(pairId);
        if (existing == null) {
          throw NotFoundException(
              message: 'Market pair with id $pairId not found');
        }
        // Mock delete - just return void
        return;
      });
    }

    try {
      final response = await dio.delete(ApiConstants.marketById(pairId));

      if (response.statusCode == 204) {
        // Success - no content
        return;
      } else {
        throw ServerException(
          message: 'Failed to delete market pair',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is NetworkException ||
          e is ServerException ||
          e is NotFoundException ||
          e is ValidationException ||
          e is AuthenticationException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
}
