import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/data/models/wallet_model.dart';
import 'package:crypto_trading_app/core/models/api_response.dart';

/// Wallets Remote Data Source
abstract class WalletsRemoteDataSource {
  Future<List<WalletModel>> getWallets({
    String? currencyId,
    bool includeZero = false,
  });

  Future<WalletModel> getWalletByCurrency(String currencyId);

  Future<WalletModel> getWalletBalance(String walletId);

  Future<List<WalletLedgerModel>> getWalletLedger({
    required String walletId,
    String? refType,
    String? direction,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 10,
  });
}

/// Backend GET /wallets returns flat items: walletId, currencyId, symbol, name, available, frozen, total.
/// Normalize to the shape WalletModel expects (snake_case, nested currency, updated_at).
Map<String, dynamic> _normalizeWalletListItem(Map<String, dynamic> item) {
  return {
    'wallet_id': item['walletId'] ?? item['wallet_id'] ?? '',
    'user_id': item['userId'] ?? item['user_id'] ?? '',
    'currency': {
      'currency_id': item['currencyId'] ?? item['currency_id'] ?? '',
      'symbol': item['symbol'] ?? '',
      'name': item['name'] ?? '',
    },
    'available': item['available']?.toString() ?? '0',
    'frozen': item['frozen']?.toString() ?? '0',
    'total': item['total']?.toString() ?? '0',
    'updated_at':
        item['updatedAt']?.toString() ??
        item['updated_at']?.toString() ??
        DateTime.now().toUtc().toIso8601String(),
  };
}

class WalletsRemoteDataSourceImpl implements WalletsRemoteDataSource {
  final Dio dio;

  WalletsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<WalletModel>> getWallets({
    String? currencyId,
    bool includeZero = false,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.wallets,
        queryParameters: {
          if (currencyId != null) 'currency_id': currencyId,
          'include_zero': includeZero,
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<WalletModel>>.fromJson(
          response.data,
          (json) => (json as List)
              .map((item) => WalletModel.fromJson(
                  _normalizeWalletListItem(item as Map<String, dynamic>)))
              .toList(),
        );
        
        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw ServerException(message: apiResponse.message ?? 'Failed to fetch wallets');
        }
      } else {
        throw ServerException(
          message: 'Failed to fetch wallets',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Wallets not found');
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
  Future<WalletModel> getWalletByCurrency(String currencyId) async {
    try {
      final response = await dio.get(ApiConstants.walletByCurrency(currencyId));

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<WalletModel>.fromJson(
          response.data,
          (json) => WalletModel.fromJson(json as Map<String, dynamic>),
        );
        
        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw NotFoundException(message: apiResponse.message ?? 'Wallet not found');
        }
      } else {
        throw NotFoundException(message: 'Wallet not found');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Wallet not found');
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
  Future<WalletModel> getWalletBalance(String walletId) async {
    try {
      final response = await dio.get(ApiConstants.walletBalance(walletId));

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<WalletModel>.fromJson(
          response.data,
          (json) => WalletModel.fromJson(json as Map<String, dynamic>),
        );
        
        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw NotFoundException(message: apiResponse.message ?? 'Wallet not found');
        }
      } else {
        throw NotFoundException(message: 'Wallet not found');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Wallet not found');
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
  Future<List<WalletLedgerModel>> getWalletLedger({
    required String walletId,
    String? refType,
    String? direction,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.walletLedger(walletId),
        queryParameters: {
          if (refType != null) 'ref_type': refType,
          if (direction != null) 'direction': direction,
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = PaginatedResponse<WalletLedgerModel>.fromJson(
          response.data,
          (json) => WalletLedgerModel.fromJson(json as Map<String, dynamic>),
        );
        
        if (apiResponse.success) {
          return apiResponse.data;
        } else {
          throw ServerException(message: apiResponse.message ?? 'Failed to fetch ledger');
        }
      } else {
        throw ServerException(
          message: 'Failed to fetch ledger',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Ledger not found');
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
