import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:dio/dio.dart';

abstract class FiatWithdrawalsRemoteDataSource {
  Future<List<Map<String, dynamic>>> getBanks();
  Future<Map<String, dynamic>> createBankAccount({
    required String bankCode,
    required String accountNumber,
    required String accountHolderName,
  });
  Future<Map<String, dynamic>> resolveBankAccountHolder({
    required String bankCode,
    required String accountNumber,
  });
  Future<List<Map<String, dynamic>>> getMyBankAccounts();
  Future<Map<String, dynamic>> createWithdrawalRequest({
    required String bankAccountId,
    required String amount,
    required String idempotencyKey,
  });
  Future<List<Map<String, dynamic>>> getMyRequests({int limit = 50});

  Future<Map<String, dynamic>> adminListBankAccounts({
    String? status,
    String? userId,
    int page = 1,
    int limit = 20,
  });
  Future<Map<String, dynamic>> adminListRequests({
    String? status,
    String? userId,
    int page = 1,
    int limit = 20,
  });
  Future<void> adminVerifyBankAccount(String bankAccountId);
  Future<void> adminRejectBankAccount(String bankAccountId, {String? reason});
  Future<void> adminCompleteRequest(String requestId, {
    required String transferReference,
    String? adminNote,
  });
  Future<void> adminRejectRequest(String requestId, {String? reason});
}

class FiatWithdrawalsRemoteDataSourceImpl implements FiatWithdrawalsRemoteDataSource {
  FiatWithdrawalsRemoteDataSourceImpl({required this.dioClient});

  final DioClient dioClient;

  dynamic _unwrapData(dynamic responseData) {
    final m = responseData as Map<String, dynamic>?;
    if (m == null) return null;
    return m['data'];
  }

  String _err(DioException e) =>
      e.response?.data is Map && (e.response!.data as Map)['message'] != null
          ? (e.response!.data as Map)['message'].toString()
          : e.message ?? 'Request failed';

  @override
  Future<List<Map<String, dynamic>>> getBanks() async {
    try {
      final res = await dioClient.dio.get(ApiConstants.fiatWithdrawalsBanks);
      final data = _unwrapData(res.data);
      if (data is! List) {
        throw const FormatException('Invalid banks response');
      }
      return data.whereType<Map<String, dynamic>>().toList();
    } on DioException catch (e) {
      throw ServerException(message: _err(e));
    }
  }

  @override
  Future<Map<String, dynamic>> createBankAccount({
    required String bankCode,
    required String accountNumber,
    required String accountHolderName,
  }) async {
    try {
      final res = await dioClient.dio.post(
        ApiConstants.fiatWithdrawalsBankAccounts,
        data: {
          'bankCode': bankCode,
          'accountNumber': accountNumber,
          'accountHolderName': accountHolderName,
        },
      );
      final data = _unwrapData(res.data);
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Invalid create bank response');
      }
      return data;
    } on DioException catch (e) {
      throw ServerException(message: _err(e));
    }
  }

  @override
  Future<Map<String, dynamic>> resolveBankAccountHolder({
    required String bankCode,
    required String accountNumber,
  }) async {
    try {
      final res = await dioClient.dio.get(
        ApiConstants.fiatWithdrawalsResolveBankHolder,
        queryParameters: {
          'bankCode': bankCode,
          'accountNumber': accountNumber,
        },
      );
      final data = _unwrapData(res.data);
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Invalid resolve bank holder response');
      }
      return data;
    } on DioException catch (e) {
      throw ServerException(message: _err(e));
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMyBankAccounts() async {
    try {
      final res = await dioClient.dio.get(ApiConstants.fiatWithdrawalsBankAccounts);
      final data = _unwrapData(res.data);
      if (data is! List) {
        throw const FormatException('Invalid bank accounts response');
      }
      return data.whereType<Map<String, dynamic>>().toList();
    } on DioException catch (e) {
      throw ServerException(message: _err(e));
    }
  }

  @override
  Future<Map<String, dynamic>> createWithdrawalRequest({
    required String bankAccountId,
    required String amount,
    required String idempotencyKey,
  }) async {
    try {
      final res = await dioClient.dio.post(
        ApiConstants.fiatWithdrawalsRequests,
        data: {
          'bankAccountId': bankAccountId,
          'amount': amount,
          'idempotencyKey': idempotencyKey,
        },
      );
      final data = _unwrapData(res.data);
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Invalid withdrawal request response');
      }
      return data;
    } on DioException catch (e) {
      throw ServerException(message: _err(e));
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMyRequests({int limit = 50}) async {
    try {
      final res = await dioClient.dio.get(
        ApiConstants.fiatWithdrawalsRequests,
        queryParameters: {'limit': limit},
      );
      final data = _unwrapData(res.data);
      if (data is! List) {
        throw const FormatException('Invalid requests response');
      }
      return data.whereType<Map<String, dynamic>>().toList();
    } on DioException catch (e) {
      throw ServerException(message: _err(e));
    }
  }

  @override
  Future<Map<String, dynamic>> adminListBankAccounts({
    String? status,
    String? userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await dioClient.dio.get(
        ApiConstants.fiatWithdrawalsAdminBankAccounts,
        queryParameters: {
          if (status != null) 'status': status,
          if (userId != null) 'userId': userId,
          'page': page,
          'limit': limit,
        },
      );
      final data = _unwrapData(res.data);
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Invalid admin banks response');
      }
      return data;
    } on DioException catch (e) {
      throw ServerException(message: _err(e));
    }
  }

  @override
  Future<Map<String, dynamic>> adminListRequests({
    String? status,
    String? userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await dioClient.dio.get(
        ApiConstants.fiatWithdrawalsAdminRequests,
        queryParameters: {
          if (status != null) 'status': status,
          if (userId != null) 'userId': userId,
          'page': page,
          'limit': limit,
        },
      );
      final data = _unwrapData(res.data);
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Invalid admin requests response');
      }
      return data;
    } on DioException catch (e) {
      throw ServerException(message: _err(e));
    }
  }

  @override
  Future<void> adminVerifyBankAccount(String bankAccountId) async {
    try {
      await dioClient.dio.post(
        ApiConstants.fiatWithdrawalsAdminBankAccountVerify(bankAccountId),
      );
    } on DioException catch (e) {
      throw ServerException(message: _err(e));
    }
  }

  @override
  Future<void> adminRejectBankAccount(String bankAccountId, {String? reason}) async {
    try {
      await dioClient.dio.post(
        ApiConstants.fiatWithdrawalsAdminBankAccountReject(bankAccountId),
        data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
      );
    } on DioException catch (e) {
      throw ServerException(message: _err(e));
    }
  }

  @override
  Future<void> adminCompleteRequest(
    String requestId, {
    required String transferReference,
    String? adminNote,
  }) async {
    try {
      await dioClient.dio.post(
        ApiConstants.fiatWithdrawalsAdminRequestComplete(requestId),
        data: {
          'transferReference': transferReference,
          if (adminNote != null && adminNote.isNotEmpty) 'adminNote': adminNote,
        },
      );
    } on DioException catch (e) {
      throw ServerException(message: _err(e));
    }
  }

  @override
  Future<void> adminRejectRequest(String requestId, {String? reason}) async {
    try {
      await dioClient.dio.post(
        ApiConstants.fiatWithdrawalsAdminRequestReject(requestId),
        data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
      );
    } on DioException catch (e) {
      throw ServerException(message: _err(e));
    }
  }
}
