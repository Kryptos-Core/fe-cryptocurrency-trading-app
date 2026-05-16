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
  Future<Map<String, dynamic>> reconcile(String txId, String action, {String? reason});
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
      return _parseResponse(response.data, 'approve');
    } on DioException catch (e) {
      throw _wrapDioException(e, 'Khong the chap nhan yeu cau rut tien');
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
      return _parseResponse(response.data, 'reject');
    } on DioException catch (e) {
      throw _wrapDioException(e, 'Khong the tu choi yeu cau rut tien');
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
      return _parseResponse(response.data, 'processPending');
    } on DioException catch (e) {
      throw _wrapDioException(e, 'Failed to process pending');
    } catch (e) {
      throw ServerException(message: 'Failed to process pending: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> reconcile(String txId, String action, {String? reason}) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.blockchainAdminWithdrawalReconcile(txId),
        data: {
          'action': action,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );
      return _parseResponse(response.data, 'reconcile');
    } on DioException catch (e) {
      throw _wrapDioException(e, 'Khong the thuc hien hanh dong nay');
    } catch (e) {
      throw ServerException(message: 'Khong the thuc hien hanh dong nay: ${e.toString()}');
    }
  }

  // ── Shared helpers ───────────────────────────────────────────────────────────────

  /// Parse response body, throwing on application-level errors (even with HTTP 200).
  Map<String, dynamic> _parseResponse(dynamic raw, String operation) {
    if (raw is! Map<String, dynamic>) {
      throw ServerException(message: '$operation: Invalid response format from server');
    }
    // NestJS may wrap errors in { statusCode, message, error } or { error: { message } }
    final statusCode = raw['statusCode'] as int?;
    final errorField = raw['error'];
    final messageField = raw['message'];

    // Application error (even with HTTP 200 — NestJS throws via exception filter)
    if (errorField != null || statusCode != null || messageField != null) {
      String msg = '$operation failed';
      if (errorField is Map<String, dynamic>) {
        msg = errorField['message']?.toString() ?? msg;
      }
      if (messageField != null && messageField is String && messageField.isNotEmpty) {
        msg = messageField;
      }
      throw ServerException(message: msg, statusCode: statusCode);
    }

    return raw['data'] as Map<String, dynamic>? ?? raw;
  }

  /// Wrap DioException into user-friendly ServerException.
  ServerException _wrapDioException(DioException e, String fallback) {
    final data = e.response?.data;
    String msg = fallback;
    if (data is Map<String, dynamic>) {
      final nestedMsg = data['error']?['message']?.toString();
      if (nestedMsg != null && nestedMsg.isNotEmpty) {
        msg = nestedMsg;
      } else {
        final flatMsg = data['message']?.toString();
        if (flatMsg != null && flatMsg.isNotEmpty) {
          msg = flatMsg;
        } else {
          final errorMsg = data['error']?.toString();
          if (errorMsg != null && errorMsg.isNotEmpty && errorMsg != 'Error') {
            msg = errorMsg;
          }
        }
      }
    }
    return ServerException(message: msg, statusCode: e.response?.statusCode);
  }
}
