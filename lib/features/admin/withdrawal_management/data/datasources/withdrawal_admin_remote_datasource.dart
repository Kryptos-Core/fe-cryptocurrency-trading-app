import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/features/admin/withdrawal_management/data/models/admin_withdrawal_model.dart';
import 'package:dio/dio.dart';

int _asInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

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
        final dataField = raw['data'];
        final List<dynamic> listRaw;
        final int total;
        final int pageNum;
        final int limitNum;

        if (dataField is List<dynamic>) {
          listRaw = dataField;
          total = _asInt(raw['total']);
          pageNum = _asInt(raw['page'], page);
          limitNum = _asInt(raw['limit'], limit);
        } else if (dataField is Map<String, dynamic>) {
          final inner = dataField;
          final innerList = inner['data'];
          listRaw = innerList is List<dynamic> ? innerList : <dynamic>[];
          total = _asInt(inner['total']);
          pageNum = _asInt(inner['page'], page);
          limitNum = _asInt(inner['limit'], limit);
        } else {
          listRaw = <dynamic>[];
          total = 0;
          pageNum = page;
          limitNum = limit;
        }

        return {
          'data': listRaw
              .whereType<Map<String, dynamic>>()
              .map(AdminWithdrawalModel.fromJson)
              .toList(),
          'total': total,
          'page': pageNum,
          'limit': limitNum,
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
      if (raw is! Map<String, dynamic>) throw const FormatException('Invalid response');
      // Backend trả flat object; nếu wrap trong { data: {...} } thì unwrap
      final inner = raw.containsKey('data') && raw['data'] is Map<String, dynamic>
          ? raw['data'] as Map<String, dynamic>
          : raw;
      return AdminWithdrawalModel.fromJson(inner);
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
      // NestJS wraps error in { statusCode, message, error } or { message }
      final data = e.response?.data;
      String msg = 'Khong the chap nhan yeu cau rut tien';
      if (data is Map<String, dynamic>) {
        // Try nested { error: { message: ... } } first
        final nestedMsg = data['error']?['message']?.toString();
        if (nestedMsg != null && nestedMsg.isNotEmpty) {
          msg = nestedMsg;
        } else {
          // Try flat { message: ... }
          final flatMsg = data['message']?.toString();
          if (flatMsg != null && flatMsg.isNotEmpty) {
            msg = flatMsg;
          }
        }
      }
      throw ServerException(
        message: msg,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: 'Khong the chap nhan yeu cau rut tien: ${e.toString()}');
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
      final data = e.response?.data;
      String msg = 'Khong the tu choi yeu cau rut tien';
      if (data is Map<String, dynamic>) {
        final nestedMsg = data['error']?['message']?.toString();
        if (nestedMsg != null && nestedMsg.isNotEmpty) {
          msg = nestedMsg;
        } else {
          final flatMsg = data['message']?.toString();
          if (flatMsg != null && flatMsg.isNotEmpty) {
            msg = flatMsg;
          }
        }
      }
      throw ServerException(
        message: msg,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: 'Khong the tu choi yeu cau rut tien: ${e.toString()}');
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
