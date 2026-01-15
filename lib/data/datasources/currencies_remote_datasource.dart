import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/services/mock_service.dart';
import 'package:crypto_trading_app/data/models/currency_model.dart';
import 'package:crypto_trading_app/data/mocks/currencies_mock.dart';
import 'package:crypto_trading_app/core/models/api_response.dart';

/// Currencies Remote Data Source
/// Following Repository Pattern and Strategy Pattern (Mock vs Real API)
abstract class CurrenciesRemoteDataSource {
  Future<List<CurrencyModel>> getCurrencies({
    bool? isActive,
    bool? isTradable,
    int page = 1,
    int limit = 10,
  });

  Future<CurrencyModel> getCurrencyById(int currencyId);

  Future<CurrencyModel> getCurrencyBySymbol(String symbol);
}

class CurrenciesRemoteDataSourceImpl implements CurrenciesRemoteDataSource {
  final Dio dio;

  CurrenciesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CurrencyModel>> getCurrencies({
    bool? isActive,
    bool? isTradable,
    int page = 1,
    int limit = 10,
  }) async {
    if (MockService.isMockMode) {
      return MockService.mockResponse(() {
        var currencies = CurrenciesMock.filter(
          isActive: isActive,
          isTradable: isTradable,
        );
        
        // Simple pagination
        final start = (page - 1) * limit;
        final end = start + limit;
        if (start >= currencies.length) {
          return [];
        }
        return currencies.sublist(
          start,
          end > currencies.length ? currencies.length : end,
        );
      });
    }

    try {
      final response = await dio.get(
        '/api/v1/currencies',
        queryParameters: {
          if (isActive != null) 'is_active': isActive,
          if (isTradable != null) 'is_tradable': isTradable,
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = PaginatedResponse<CurrencyModel>.fromJson(
          response.data,
          (json) => CurrencyModel.fromJson(json as Map<String, dynamic>),
        );
        
        if (apiResponse.success) {
          return apiResponse.data;
        } else {
          throw ServerException(message: apiResponse.message ?? 'Failed to fetch currencies');
        }
      } else {
        throw ServerException(
          message: 'Failed to fetch currencies',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Currencies not found');
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
  Future<CurrencyModel> getCurrencyById(int currencyId) async {
    if (MockService.isMockMode) {
      return MockService.mockResponse(() {
        final currency = CurrenciesMock.getById(currencyId);
        if (currency == null) {
          throw NotFoundException(message: 'Currency not found');
        }
        return currency;
      });
    }

    try {
      final response = await dio.get('/api/v1/currencies/$currencyId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<CurrencyModel>.fromJson(
          response.data,
          (json) => CurrencyModel.fromJson(json as Map<String, dynamic>),
        );
        
        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw NotFoundException(message: apiResponse.message ?? 'Currency not found');
        }
      } else {
        throw NotFoundException(
          message: 'Currency not found',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Currency not found');
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
  Future<CurrencyModel> getCurrencyBySymbol(String symbol) async {
    if (MockService.isMockMode) {
      return MockService.mockResponse(() {
        final currency = CurrenciesMock.getBySymbol(symbol);
        if (currency == null) {
          throw NotFoundException(message: 'Currency not found');
        }
        return currency;
      });
    }

    try {
      final response = await dio.get('/api/v1/currencies/symbol/$symbol');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<CurrencyModel>.fromJson(
          response.data,
          (json) => CurrencyModel.fromJson(json as Map<String, dynamic>),
        );
        
        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw NotFoundException(message: apiResponse.message ?? 'Currency not found');
        }
      } else {
        throw NotFoundException(message: 'Currency not found');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Currency not found');
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
