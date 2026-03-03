import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/data/models/market_pair_model.dart';
import 'package:crypto_trading_app/data/models/paginated_markets_response.dart';
import 'package:crypto_trading_app/data/models/create_market_pair_dto.dart';
import 'package:crypto_trading_app/data/models/update_market_pair_dto.dart';
import 'package:crypto_trading_app/data/models/trade_model.dart';
import 'package:crypto_trading_app/core/models/api_response.dart';
import 'package:crypto_trading_app/core/models/error_response.dart';

/// Markets Remote Data Source
/// Following Repository Pattern
/// Following Interface Segregation Principle (ISP) - clean interface
abstract class MarketsRemoteDataSource {
  /// Get all market pairs with pagination and filtering.
  /// [includeTickers] when true, response data includes tickers for current page (one request instead of GET /markets/tickers/all).
  Future<PaginatedMarketsData> getMarkets({
    int page = 1,
    int limit = 10,
    bool includeInactive = false,
    bool includeTickers = false,
  });

  /// Get all active market pairs (cached endpoint)
  Future<List<MarketPairModel>> getActiveMarkets();

  /// Get market pair by ID
  Future<MarketPairModel> getMarketById(String pairId);

  /// Get market pair by symbol
  Future<MarketPairModel> getMarketBySymbol(String symbol);

  /// Get market ticker by ID
  Future<MarketTickerModel> getMarketTicker(String pairId);

  /// Get market ticker by symbol
  Future<MarketTickerModel> getMarketTickerBySymbol(String symbol);

  /// Get all tickers for active markets
  Future<List<MarketTickerModel>> getAllTickers();

  /// Get order book by ID
  Future<OrderBookModel> getOrderBook({
    required String pairId,
    int limit = 20,
  });

  /// Get order book by symbol
  Future<OrderBookModel> getOrderBookBySymbol({
    required String symbol,
    int limit = 20,
  });

  /// Get recent trades by ID
  Future<List<TradeModel>> getTrades({
    required String pairId,
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
    required String pairId,
    String interval = '1h',
    String? range,
    String? startTime,
    String? endTime,
    int limit = 100,
  });

  /// Create market pair (Admin only)
  Future<MarketPairModel> createMarketPair(CreateMarketPairDto dto);

  /// Update market pair (Admin only)
  Future<MarketPairModel> updateMarketPair(String pairId, UpdateMarketPairDto dto);

  /// Delete market pair (soft delete - Admin only)
  Future<void> deleteMarketPair(String pairId);
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
    bool includeTickers = false,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.markets,
        queryParameters: {
          'page': page,
          'limit': limit,
          'includeInactive': includeInactive,
          if (includeTickers) 'includeTickers': true,
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

          // GET /markets — API spec: data is OBJECT { pairs, total, page, limit }.
          // List = data.pairs (not data; data is not an array).
          final dataJson = responseData['data'];
          final Map<String, dynamic> paginatedMeta;
          final List<MarketPairModel> pairs;

          List<MarketTickerModel>? tickers;
          if (dataJson is Map<String, dynamic>) {
            paginatedMeta = dataJson;
            pairs = _parseMarketPairs(dataJson['pairs']);
            // data.tickers present when includeTickers=true (same format as GET /markets/tickers/all)
            tickers = _parseTickers(dataJson['tickers']);
          } else if (dataJson is List) {
            // Fallback if backend ever sends data as array
            paginatedMeta = <String, dynamic>{};
            pairs = _parseMarketPairs(dataJson);
            tickers = null;
            paginatedMeta['total'] = responseData['total'];
            paginatedMeta['page'] = responseData['page'];
            paginatedMeta['limit'] = responseData['limit'];
            paginatedMeta['totalPages'] = responseData['totalPages'];
          } else {
            paginatedMeta = <String, dynamic>{};
            pairs = _parseMarketPairs(responseData['pairs']);
            tickers = null;
          }

          final parsedTotal = _toInt(paginatedMeta['total'], fallback: pairs.length);
          final parsedPage = _toInt(paginatedMeta['page'], fallback: page);
          final parsedLimit = _toInt(paginatedMeta['limit'], fallback: limit);
          final parsedTotalPages = _toInt(paginatedMeta['totalPages'], fallback: 0);

          return PaginatedMarketsData(
            data: pairs,
            total: parsedTotal,
            page: parsedPage,
            limit: parsedLimit,
            totalPages: parsedTotalPages == 0 ? null : parsedTotalPages,
            tickers: tickers,
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

  /// Normalize ticker map so both snake_case (pair_id, last_price, ...) and camelCase (pairId, lastPrice, ...) from backend are supported.
  Map<String, dynamic> _normalizeTickerJson(Map<String, dynamic> item) {
    return <String, dynamic>{
      'pairId': item['pairId'] ?? item['pair_id'],
      'symbol': item['symbol'],
      'lastPrice': item['lastPrice'] ?? item['last_price'],
      'open24h': item['open24h'] ?? item['open_24h'],
      'high24h': item['high24h'] ?? item['high_24h'],
      'low24h': item['low24h'] ?? item['low_24h'],
      'volume24h': item['volume24h'] ?? item['volume_24h'],
      'quoteVolume24h': item['quoteVolume24h'] ?? item['quote_volume_24h'],
      'change24h': item['change24h'] ?? item['change_24h'],
      'changeAmount24h': item['changeAmount24h'] ?? item['change_amount_24h'],
      'bestBid': item['bestBid'] ?? item['best_bid'],
      'bestAsk': item['bestAsk'] ?? item['best_ask'],
      'timestamp': item['timestamp'],
    };
  }

  List<MarketTickerModel>? _parseTickers(dynamic tickersJson) {
    if (tickersJson == null || tickersJson is! List) return null;
    return tickersJson
        .whereType<Map<String, dynamic>>()
        .map((item) => MarketTickerModel.fromJson(_normalizeTickerJson(item)))
        .toList();
  }

  /// GET /markets/active — API spec: data is ARRAY [ pair, ... ]. List = data.
  @override
  Future<List<MarketPairModel>> getActiveMarkets() async {
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
  Future<MarketPairModel> getMarketById(String pairId) async {
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
  Future<MarketTickerModel> getMarketTicker(String pairId) async {
    try {
      final response = await dio.get(ApiConstants.marketTicker(pairId));

      if (response.statusCode == 200) {
        // Response wrap: { success, data: MarketTickerDto, timestamp }
        final apiResponse = ApiResponse<MarketTickerModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => MarketTickerModel.fromJson(
            _normalizeTickerJson(json as Map<String, dynamic>),
          ),
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
    try {
      final response = await dio.get(ApiConstants.marketTickerBySymbol(symbol));

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<MarketTickerModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => MarketTickerModel.fromJson(
            _normalizeTickerJson(json as Map<String, dynamic>),
          ),
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

  /// GET /markets/tickers/all — API spec: data is ARRAY [ ticker, ... ]. List = data.
  @override
  Future<List<MarketTickerModel>> getAllTickers() async {
    try {
      final response = await dio.get(ApiConstants.marketsTickersAll);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<MarketTickerModel>>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => (json as List)
              .map((item) => MarketTickerModel.fromJson(
                  _normalizeTickerJson(item as Map<String, dynamic>)))
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
    required String pairId,
    int limit = 20,
  }) async {
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
    required String pairId,
    int limit = 50,
  }) async {
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
    required String pairId,
    String interval = '1h',
    String? range,
    String? startTime,
    String? endTime,
    int limit = 100,
  }) async {
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
      String pairId, UpdateMarketPairDto dto) async {
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
  Future<void> deleteMarketPair(String pairId) async {
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
