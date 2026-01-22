import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/services/mock_service.dart';
import 'package:crypto_trading_app/data/models/currency_model.dart';
import 'package:crypto_trading_app/data/models/create_currency_dto.dart';
import 'package:crypto_trading_app/data/models/update_currency_dto.dart';
import 'package:crypto_trading_app/data/models/paginated_currencies_response.dart';
import 'package:crypto_trading_app/data/mocks/currencies_mock.dart';
import 'package:crypto_trading_app/core/models/api_response.dart';
import 'package:crypto_trading_app/core/models/error_response.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';

/// Currencies Remote Data Source
/// Following Repository Pattern and Strategy Pattern (Mock vs Real API)
/// Following Interface Segregation Principle (ISP) - clean interface
abstract class CurrenciesRemoteDataSource {
  /// Get all currencies with pagination and filtering
  Future<PaginatedCurrenciesData> getCurrencies({
    int page = 1,
    int limit = 10,
    bool includeInactive = false,
  });

  /// Get all active currencies (cached endpoint)
  Future<List<CurrencyModel>> getActiveCurrencies();

  /// Get all tradable currencies (cached endpoint)
  Future<List<CurrencyModel>> getTradableCurrencies();

  /// Get currency by ID
  Future<CurrencyModel> getCurrencyById(int currencyId);

  /// Get currency by symbol
  Future<CurrencyModel> getCurrencyBySymbol(String symbol);

  /// Create new currency (Admin only)
  Future<CurrencyModel> createCurrency(CreateCurrencyDto dto);

  /// Update currency (Admin only)
  Future<CurrencyModel> updateCurrency(int currencyId, UpdateCurrencyDto dto);

  /// Delete currency (soft delete - Admin only)
  Future<void> deleteCurrency(int currencyId);
}

class CurrenciesRemoteDataSourceImpl implements CurrenciesRemoteDataSource {
  final Dio dio;

  CurrenciesRemoteDataSourceImpl({required this.dio});

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
        final errorResponse = ErrorResponse.fromJson(responseData as Map<String, dynamic>);
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
  Future<PaginatedCurrenciesData> getCurrencies({
    int page = 1,
    int limit = 10,
    bool includeInactive = false,
  }) async {
    if (MockService.isMockModeFor('currencies')) {
      return MockService.mockResponse(() {
        var currencies = CurrenciesMock.filter(
          isActive: includeInactive ? null : true,
          isTradable: null,
        );

        // Simple pagination
        final start = (page - 1) * limit;
        final end = start + limit;
        final paginatedCurrencies = start >= currencies.length
            ? <CurrencyModel>[]
            : currencies.sublist(
                start,
                end > currencies.length ? currencies.length : end,
              );

        return PaginatedCurrenciesData(
          currencies: paginatedCurrencies,
          total: currencies.length,
          page: page,
          limit: limit,
        );
      });
    }

    try {
      final response = await dio.get(
        ApiConstants.currencies,
        queryParameters: {
          'page': page,
          'limit': limit,
          'includeInactive': includeInactive,
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = PaginatedCurrenciesResponse.fromJson(
          response.data as Map<String, dynamic>,
        );

        if (apiResponse.success) {
          return apiResponse.data;
        } else {
          throw ServerException(
            message: apiResponse.message ?? 'Failed to fetch currencies',
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to fetch currencies',
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
  Future<List<CurrencyModel>> getActiveCurrencies() async {
    if (MockService.isMockModeFor('currencies')) {
      return MockService.mockResponse(() {
        return CurrenciesMock.filter(isActive: true, isTradable: null);
      });
    }

    try {
      final response = await dio.get(ApiConstants.currenciesActive);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<CurrencyModel>>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => (json as List)
              .map((item) => CurrencyModel.fromJson(item as Map<String, dynamic>))
              .toList(),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw ServerException(
            message: apiResponse.message ?? 'Failed to fetch active currencies',
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to fetch active currencies',
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
  Future<List<CurrencyModel>> getTradableCurrencies() async {
    if (MockService.isMockModeFor('currencies')) {
      return MockService.mockResponse(() {
        return CurrenciesMock.filter(isActive: true, isTradable: true);
      });
    }

    try {
      final response = await dio.get(ApiConstants.currenciesTradable);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<CurrencyModel>>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => (json as List)
              .map((item) => CurrencyModel.fromJson(item as Map<String, dynamic>))
              .toList(),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw ServerException(
            message: apiResponse.message ?? 'Failed to fetch tradable currencies',
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to fetch tradable currencies',
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
  Future<CurrencyModel> getCurrencyById(int currencyId) async {
    if (MockService.isMockModeFor('currencies')) {
      return MockService.mockResponse(() {
        final currency = CurrenciesMock.getById(currencyId);
        if (currency == null) {
          throw NotFoundException(message: 'Currency with ID $currencyId not found');
        }
        return currency;
      });
    }

    try {
      final response = await dio.get(ApiConstants.currencyById(currencyId));

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<CurrencyModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => CurrencyModel.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw NotFoundException(
            message: apiResponse.message ?? 'Currency with ID $currencyId not found',
          );
        }
      } else {
        throw NotFoundException(message: 'Currency with ID $currencyId not found');
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
  Future<CurrencyModel> getCurrencyBySymbol(String symbol) async {
    if (MockService.isMockModeFor('currencies')) {
      return MockService.mockResponse(() {
        final currency = CurrenciesMock.getBySymbol(symbol);
        if (currency == null) {
          throw NotFoundException(message: 'Currency with symbol $symbol not found');
        }
        return currency;
      });
    }

    try {
      final response = await dio.get(ApiConstants.currencyBySymbol(symbol));

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<CurrencyModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => CurrencyModel.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw NotFoundException(
            message: apiResponse.message ?? 'Currency with symbol $symbol not found',
          );
        }
      } else {
        throw NotFoundException(message: 'Currency with symbol $symbol not found');
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
  Future<CurrencyModel> createCurrency(CreateCurrencyDto dto) async {
    if (MockService.isMockModeFor('currencies')) {
      return MockService.mockResponse(() {
        // Mock implementation - create a new currency
        final newId = CurrenciesMock.mockCurrencies.length + 1;
        return CurrencyModel(
          currencyId: newId,
          symbol: dto.symbol.toUpperCase(),
          name: dto.name,
          precisionScale: dto.precisionScale ?? 8,
          minWithdraw: dto.minWithdraw ?? '0',
          isTradable: dto.isTradable ?? true,
          isActive: dto.isActive ?? true,
        );
      });
    }

    try {
      final response = await dio.post(
        ApiConstants.currencies,
        data: dto.toJson(),
      );

      if (response.statusCode == 201) {
        final apiResponse = ApiResponse<CurrencyModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => CurrencyModel.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw ServerException(
            message: apiResponse.message ?? 'Failed to create currency',
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to create currency',
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
  Future<CurrencyModel> updateCurrency(int currencyId, UpdateCurrencyDto dto) async {
    if (MockService.isMockModeFor('currencies')) {
      return MockService.mockResponse(() {
        final existing = CurrenciesMock.getById(currencyId);
        if (existing == null) {
          throw NotFoundException(message: 'Currency with ID $currencyId not found');
        }
        // Mock update - merge dto with existing
        return CurrencyModel(
          currencyId: existing.currencyId,
          symbol: dto.symbol?.toUpperCase() ?? existing.symbol,
          name: dto.name ?? existing.name,
          precisionScale: dto.precisionScale ?? existing.precisionScale,
          minWithdraw: dto.minWithdraw ?? existing.minWithdraw,
          isTradable: dto.isTradable ?? existing.isTradable,
          isActive: dto.isActive ?? existing.isActive,
        );
      });
    }

    try {
      final response = await dio.patch(
        ApiConstants.currencyById(currencyId),
        data: dto.toJson(),
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<CurrencyModel>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => CurrencyModel.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw ServerException(
            message: apiResponse.message ?? 'Failed to update currency',
          );
        }
      } else {
        throw ServerException(
          message: 'Failed to update currency',
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
  Future<void> deleteCurrency(int currencyId) async {
    if (MockService.isMockModeFor('currencies')) {
      return MockService.mockResponse(() {
        final existing = CurrenciesMock.getById(currencyId);
        if (existing == null) {
          throw NotFoundException(message: 'Currency with ID $currencyId not found');
        }
        // Mock delete - just return void
        return;
      });
    }

    try {
      final response = await dio.delete(ApiConstants.currencyById(currencyId));

      if (response.statusCode == 204) {
        // Success - no content
        return;
      } else {
        throw ServerException(
          message: 'Failed to delete currency',
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
