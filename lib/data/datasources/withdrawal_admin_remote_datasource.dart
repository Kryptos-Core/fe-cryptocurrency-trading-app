import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/data/models/admin_withdrawal_model.dart';
import 'package:dio/dio.dart';

abstract class WithdrawalAdminRemoteDataSource {
  Future<Map<String, dynamic>> listWithdrawals({
    String? userId,
    String? status,
    String? chain,
    String? search,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int limit = 20,
  });
  Future<AdminWithdrawalModel> getWithdrawalDetail(String txId);
  Future<AdminWithdrawalStatsModel> getStats();
  Future<Map<String, dynamic>> approve(String txId);
  Future<Map<String, dynamic>> reject(String txId, {String? reason});
  Future<Map<String, dynamic>> processPending({int limit = 20});
}

class WithdrawalAdminRemoteDataSourceImpl implements WithdrawalAdminRemoteDataSource {
  final DioClient dioClient;

  WithdrawalAdminRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<Map<String, dynamic>> listWithdrawals({
    String? userId,
    String? status,
    String? chain,
    String? search,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.blockchainAdminWithdrawals,
        queryParameters: {
          if (userId != null && userId.isNotEmpty) 'userId': userId,
          if (status != null && status.isNotEmpty) 'status': status,
          if (chain != null && chain.isNotEmpty) 'chain': chain,
          if (search != null && search.isNotEmpty) 'search': search,
          if (dateFrom != null && dateFrom.isNotEmpty) 'dateFrom': dateFrom,
          if (dateTo != null && dateTo.isNotEmpty) 'dateTo': dateTo,
          'page': page,
          'limit': limit,
        },
      );
      final raw = response.data;
      if (raw is Map<String, dynamic>) {
        final data = raw['data'] as List<dynamic>? ?? [];
        return {
          'data': data
              .whereType<Map<String, dynamic>>()
              .map(AdminWithdrawalModel.fromJson)
              .toList(),
          'total': raw['total'] as int? ?? 0,
          'page': raw['page'] as int? ?? page,
          'limit': raw['limit'] as int? ?? limit,
        };
      }
      return {'data': <AdminWithdrawalModel>[], 'total': 0, 'page': page, 'limit': limit};
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Failed to load withdrawals',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AdminWithdrawalModel> getWithdrawalDetail(String txId) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.blockchainAdminWithdrawalDetail(txId),
      );
      final raw = response.data;
      if (raw is Map<String, dynamic>) {
        return AdminWithdrawalModel.fromJson(raw);
      }
      throw const FormatException('Invalid response');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Failed to load withdrawal detail',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AdminWithdrawalStatsModel> getStats() async {
    try {
      final response = await dioClient.dio.get(ApiConstants.blockchainAdminWithdrawalStats);
      final raw = response.data;
      if (raw is Map<String, dynamic>) {
        final data = raw['data'] ?? raw;
        return AdminWithdrawalStatsModel.fromJson(
          data is Map<String, dynamic> ? data : Map<String, dynamic>.from(raw),
        );
      }
      return AdminWithdrawalStatsModel(pendingCount: 0, pendingTotalByChain: {});
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Failed to load stats',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> approve(String txId) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.blockchainWithdrawManualApprove(txId),
        data: {},
      );
      final raw = response.data;
      if (raw is Map<String, dynamic>) {
        return raw['data'] ?? raw;
      }
      return {};
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Failed to approve',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> reject(String txId, {String? reason}) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.blockchainWithdrawManualReject(txId),
        data: reason != null ? {'reason': reason} : {},
      );
      final raw = response.data;
      if (raw is Map<String, dynamic>) {
        return raw['data'] ?? raw;
      }
      return {};
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Failed to reject',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> processPending({int limit = 20}) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.blockchainWithdrawProcessPending,
        queryParameters: {'limit': limit},
      );
      final raw = response.data;
      if (raw is Map<String, dynamic>) {
        return raw['data'] ?? raw;
      }
      return {};
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Failed to process pending',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
