import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/services/mock_service.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/data/models/wallet_model.dart';
import 'package:crypto_trading_app/data/mocks/wallets_mock.dart';
import 'package:crypto_trading_app/core/models/api_response.dart';

/// Wallets Remote Data Source
abstract class WalletsRemoteDataSource {
  Future<List<WalletModel>> getWallets({
    int? currencyId,
    bool includeZero = false,
  });

  Future<WalletModel> getWalletByCurrency(int currencyId);

  Future<WalletModel> getWalletBalance(int walletId);

  Future<List<WalletLedgerModel>> getWalletLedger({
    required int walletId,
    String? refType,
    String? direction,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 10,
  });
}

class WalletsRemoteDataSourceImpl implements WalletsRemoteDataSource {
  final Dio dio;

  WalletsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<WalletModel>> getWallets({
    int? currencyId,
    bool includeZero = false,
  }) async {
    if (MockService.isMockModeFor('wallets')) {
      return MockService.mockResponse(() {
        return WalletsMock.filter(
          currencyId: currencyId,
          includeZero: includeZero,
        );
      });
    }

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
          (json) => (json as List).map((item) => WalletModel.fromJson(item as Map<String, dynamic>)).toList(),
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
  Future<WalletModel> getWalletByCurrency(int currencyId) async {
    if (MockService.isMockModeFor('wallets')) {
      return MockService.mockResponse(() {
        final wallet = WalletsMock.getByCurrencyId(currencyId);
        if (wallet == null) {
          throw NotFoundException(message: 'Wallet not found');
        }
        return wallet;
      });
    }

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
  Future<WalletModel> getWalletBalance(int walletId) async {
    if (MockService.isMockModeFor('wallets')) {
      return MockService.mockResponse(() {
        final wallet = WalletsMock.getById(walletId);
        if (wallet == null) {
          throw NotFoundException(message: 'Wallet not found');
        }
        return wallet;
      });
    }

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
    required int walletId,
    String? refType,
    String? direction,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    if (MockService.isMockModeFor('wallets')) {
      return MockService.mockResponse(() {
        var ledger = WalletsMock.generateLedger(walletId, count: 20);
        
        // Apply filters
        if (refType != null) {
          ledger = ledger.where((l) => l.refType == refType).toList();
        }
        if (direction != null) {
          ledger = ledger.where((l) => l.direction == direction).toList();
        }
        
        // Simple pagination
        final start = (page - 1) * limit;
        final end = start + limit;
        if (start >= ledger.length) {
          return [];
        }
        return ledger.sublist(
          start,
          end > ledger.length ? ledger.length : end,
        );
      });
    }

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
