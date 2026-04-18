import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/features/markets/data/models/currency_model.dart';
import 'package:crypto_trading_app/features/markets/domain/dtos/create_currency_dto.dart';
import 'package:crypto_trading_app/features/markets/domain/dtos/update_currency_dto.dart';
import 'package:crypto_trading_app/features/markets/data/models/paginated_currencies_response.dart';
import 'package:crypto_trading_app/core/models/api_response.dart';
import 'package:crypto_trading_app/core/models/error_response.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';

/// Currencies Remote Data Source
/// Following Repository Pattern and Strategy Pattern (e.g. real API implementation)
/// Following Interface Segregation Principle (ISP) - clean interface
abstract class CurrenciesRemoteDataSource {
  /// Get all currencies with pagination, optional text search and filters.
  Future<PaginatedCurrenciesData> getCurrencies({
    int page = 1,
    int limit = 10,
    bool includeInactive = false,
    String? search,
    bool? isTradable,
    bool? isActive,
  });

  /// Get all active currencies (cached endpoint)
  Future<List<CurrencyModel>> getActiveCurrencies();

  /// Get all tradable currencies (cached endpoint)
  Future<List<CurrencyModel>> getTradableCurrencies();

  /// Get currency by ID
  Future<CurrencyModel> getCurrencyById(String currencyId);

  /// Get currency by symbol
  Future<CurrencyModel> getCurrencyBySymbol(String symbol);

  /// Create new currency (Admin only)
  Future<CurrencyModel> createCurrency(CreateCurrencyDto dto);

  /// Update currency (Admin only)
  Future<CurrencyModel> updateCurrency(
      String currencyId, UpdateCurrencyDto dto);

  /// Delete currency (soft delete - Admin only)
  Future<void> deleteCurrency(String currencyId);
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
  Future<PaginatedCurrenciesData> getCurrencies({
    int page = 1,
    int limit = 10,
    bool includeInactive = false,
    String? search,
    bool? isTradable,
    bool? isActive,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
        'includeInactive': includeInactive,
        'includeMarketData': true,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (isTradable != null) 'isTradable': isTradable,
        if (isActive != null) 'isActive': isActive,
      };
      final response = await dio.get(
        ApiConstants.currencies,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final success = responseData['success'] as bool? ?? false;
        if (!success) {
          throw ServerException(
            message: responseData['message'] as String? ??
                'Failed to fetch currencies',
          );
        }

        final dataJson = responseData['data'] as Map<String, dynamic>? ??
            <String, dynamic>{};
        final currencies = _parseCurrencies(dataJson['currencies']);
        final parsedTotal =
            _toInt(dataJson['total'], fallback: currencies.length);
        final parsedPage = _toInt(dataJson['page'], fallback: page);
        final parsedLimit = _toInt(dataJson['limit'], fallback: limit);

        return PaginatedCurrenciesData(
          currencies: currencies,
          total: parsedTotal,
          page: parsedPage,
          limit: parsedLimit,
        );
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

  int _toInt(dynamic value, {required int fallback}) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  List<CurrencyModel> _parseCurrencies(dynamic currenciesJson) {
    if (currenciesJson is List) {
      return currenciesJson
          .whereType<Map<String, dynamic>>()
          .map((item) => CurrencyModel.fromJson(item))
          .toList();
    }
    return <CurrencyModel>[];
  }

  @override
  Future<List<CurrencyModel>> getActiveCurrencies() async {
    try {
      final response = await dio.get(ApiConstants.currenciesActive);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<CurrencyModel>>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => (json as List)
              .map((item) =>
                  CurrencyModel.fromJson(item as Map<String, dynamic>))
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
    try {
      final response = await dio.get(ApiConstants.currenciesTradable);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<CurrencyModel>>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => (json as List)
              .map((item) =>
                  CurrencyModel.fromJson(item as Map<String, dynamic>))
              .toList(),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw ServerException(
            message:
                apiResponse.message ?? 'Failed to fetch tradable currencies',
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
  Future<CurrencyModel> getCurrencyById(String currencyId) async {
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
            message:
                apiResponse.message ?? 'Currency with ID $currencyId not found',
          );
        }
      } else {
        throw NotFoundException(
            message: 'Currency with ID $currencyId not found');
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
            message:
                apiResponse.message ?? 'Currency with symbol $symbol not found',
          );
        }
      } else {
        throw NotFoundException(
            message: 'Currency with symbol $symbol not found');
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
  Future<CurrencyModel> updateCurrency(
      String currencyId, UpdateCurrencyDto dto) async {
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
  Future<void> deleteCurrency(String currencyId) async {
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
