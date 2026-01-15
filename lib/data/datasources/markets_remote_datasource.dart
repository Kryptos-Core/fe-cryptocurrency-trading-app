import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/services/mock_service.dart';
import 'package:crypto_trading_app/data/models/market_pair_model.dart';
import 'package:crypto_trading_app/data/mocks/markets_mock.dart';
import 'package:crypto_trading_app/core/models/api_response.dart';

/// Markets Remote Data Source
abstract class MarketsRemoteDataSource {
  Future<List<MarketPairModel>> getMarkets({
    bool? isActive,
    String? baseCurrency,
    String? quoteCurrency,
    int page = 1,
    int limit = 10,
  });

  Future<MarketPairModel> getMarketById(int pairId);

  Future<MarketPairModel> getMarketBySymbol(String symbol);

  Future<MarketTickerModel> getMarketTicker(int pairId);

  Future<OrderBookModel> getOrderBook({
    required int pairId,
    int limit = 20,
  });

  Future<List<OHLCVModel>> getOHLCV({
    required int pairId,
    String interval = '1h',
    String? startTime,
    String? endTime,
    int limit = 100,
  });
}

class MarketsRemoteDataSourceImpl implements MarketsRemoteDataSource {
  final Dio dio;

  MarketsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<MarketPairModel>> getMarkets({
    bool? isActive,
    String? baseCurrency,
    String? quoteCurrency,
    int page = 1,
    int limit = 10,
  }) async {
    if (MockService.isMockMode) {
      return MockService.mockResponse(() {
        var markets = MarketsMock.filter(
          isActive: isActive,
          baseCurrency: baseCurrency,
          quoteCurrency: quoteCurrency,
        );
        
        final start = (page - 1) * limit;
        final end = start + limit;
        if (start >= markets.length) {
          return [];
        }
        return markets.sublist(
          start,
          end > markets.length ? markets.length : end,
        );
      });
    }

    try {
      final response = await dio.get(
        '/api/v1/markets',
        queryParameters: {
          if (isActive != null) 'is_active': isActive,
          if (baseCurrency != null) 'base_currency': baseCurrency,
          if (quoteCurrency != null) 'quote_currency': quoteCurrency,
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = PaginatedResponse<MarketPairModel>.fromJson(
          response.data,
          (json) => MarketPairModel.fromJson(json as Map<String, dynamic>),
        );
        
        if (apiResponse.success) {
          return apiResponse.data;
        } else {
          throw ServerException(message: apiResponse.message ?? 'Failed to fetch markets');
        }
      } else {
        throw ServerException(
          message: 'Failed to fetch markets',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Markets not found');
      } else {
        throw ServerException(
          message: e.response?.data?['message'] ?? 'Server error',
          statusCode: e.response?.statusCode,
        );
      }
    } catch (e) {
      if (e is NetworkException || e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MarketPairModel> getMarketById(int pairId) async {
    if (MockService.isMockMode) {
      return MockService.mockResponse(() {
        final market = MarketsMock.getById(pairId);
        if (market == null) {
          throw NotFoundException(message: 'Market not found');
        }
        return market;
      });
    }

    try {
      final response = await dio.get('/api/v1/markets/$pairId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<MarketPairModel>.fromJson(
          response.data,
          (json) => MarketPairModel.fromJson(json as Map<String, dynamic>),
        );
        
        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw NotFoundException(message: apiResponse.message ?? 'Market not found');
        }
      } else {
        throw NotFoundException(message: 'Market not found');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Market not found');
      } else {
        throw ServerException(
          message: e.response?.data?['message'] ?? 'Server error',
          statusCode: e.response?.statusCode,
        );
      }
    } catch (e) {
      if (e is NetworkException || e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MarketPairModel> getMarketBySymbol(String symbol) async {
    if (MockService.isMockMode) {
      return MockService.mockResponse(() {
        final market = MarketsMock.getBySymbol(symbol);
        if (market == null) {
          throw NotFoundException(message: 'Market not found');
        }
        return market;
      });
    }

    try {
      final response = await dio.get('/api/v1/markets/symbol/$symbol');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<MarketPairModel>.fromJson(
          response.data,
          (json) => MarketPairModel.fromJson(json as Map<String, dynamic>),
        );
        
        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw NotFoundException(message: apiResponse.message ?? 'Market not found');
        }
      } else {
        throw NotFoundException(message: 'Market not found');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Market not found');
      } else {
        throw ServerException(
          message: e.response?.data?['message'] ?? 'Server error',
          statusCode: e.response?.statusCode,
        );
      }
    } catch (e) {
      if (e is NetworkException || e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MarketTickerModel> getMarketTicker(int pairId) async {
    if (MockService.isMockMode) {
      return MockService.mockResponse(() {
        // Generate dynamic ticker based on pairId
        final basePrices = {1: 45000.0, 2: 2850.0, 3: 350.0, 4: 0.52, 5: 7.80};
        final basePrice = basePrices[pairId] ?? 100.0;
        return MarketsMock.generateTicker(pairId, basePrice: basePrice);
      });
    }

    try {
      final response = await dio.get('/api/v1/markets/$pairId/ticker');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<MarketTickerModel>.fromJson(
          response.data,
          (json) => MarketTickerModel.fromJson(json as Map<String, dynamic>),
        );
        
        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw NotFoundException(message: apiResponse.message ?? 'Ticker not found');
        }
      } else {
        throw NotFoundException(message: 'Ticker not found');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Ticker not found');
      } else {
        throw ServerException(
          message: e.response?.data?['message'] ?? 'Server error',
          statusCode: e.response?.statusCode,
        );
      }
    } catch (e) {
      if (e is NetworkException || e is ServerException || e is NotFoundException) {
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
    if (MockService.isMockMode) {
      return MockService.mockResponse(() {
        final basePrices = {1: 45000.0, 2: 2850.0, 3: 350.0, 4: 0.52, 5: 7.80};
        final basePrice = basePrices[pairId] ?? 100.0;
        return MarketsMock.generateOrderBook(pairId, basePrice: basePrice);
      });
    }

    try {
      final response = await dio.get(
        '/api/v1/markets/$pairId/orderbook',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<OrderBookModel>.fromJson(
          response.data,
          (json) => OrderBookModel.fromJson(json as Map<String, dynamic>),
        );
        
        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw NotFoundException(message: apiResponse.message ?? 'Order book not found');
        }
      } else {
        throw NotFoundException(message: 'Order book not found');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Order book not found');
      } else {
        throw ServerException(
          message: e.response?.data?['message'] ?? 'Server error',
          statusCode: e.response?.statusCode,
        );
      }
    } catch (e) {
      if (e is NetworkException || e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<OHLCVModel>> getOHLCV({
    required int pairId,
    String interval = '1h',
    String? startTime,
    String? endTime,
    int limit = 100,
  }) async {
    if (MockService.isMockMode) {
      return MockService.mockResponse(() {
        final basePrices = {1: 45000.0, 2: 2850.0, 3: 350.0, 4: 0.52, 5: 7.80};
        final basePrice = basePrices[pairId] ?? 100.0;
        return MarketsMock.generateOHLCV(pairId, count: limit, basePrice: basePrice);
      });
    }

    try {
      final response = await dio.get(
        '/api/v1/markets/$pairId/ohlcv',
        queryParameters: {
          'interval': interval,
          if (startTime != null) 'start_time': startTime,
          if (endTime != null) 'end_time': endTime,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<OHLCVModel>>.fromJson(
          response.data,
          (json) => (json as List).map((item) => OHLCVModel.fromJson(item as Map<String, dynamic>)).toList(),
        );
        
        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw NotFoundException(message: apiResponse.message ?? 'OHLCV data not found');
        }
      } else {
        throw NotFoundException(message: 'OHLCV data not found');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'OHLCV data not found');
      } else {
        throw ServerException(
          message: e.response?.data?['message'] ?? 'Server error',
          statusCode: e.response?.statusCode,
        );
      }
    } catch (e) {
      if (e is NetworkException || e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
}
