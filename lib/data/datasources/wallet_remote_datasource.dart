import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/data/models/admin_wallet_adjustment_model.dart';
import 'package:crypto_trading_app/data/models/wallet_balance_model.dart';
import 'package:crypto_trading_app/data/models/wallet_transaction_model.dart';
import 'package:crypto_trading_app/domain/entities/wallet_transaction.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';

/// Remote data source for wallet API operations
///
/// This data source handles all HTTP calls to the wallet API endpoints.
/// It does NOT contain business logic, only API communication and error handling.
///
/// Error Handling:
/// - Throws ServerException on server errors (5xx)
/// - Throws NetworkException on network errors
/// - Throws AuthenticationException on authentication errors (401, 403)
/// - Throws ValidationException on validation errors (400, 422)
abstract class WalletRemoteDataSource {
  /// Get wallet balance for a specific currency
  ///
  /// Throws:
  ///   - ServerException: On server error (5xx)
  ///   - NetworkException: On network error
  ///   - AuthenticationException: On authentication error
  ///   - ValidationException: On validation error
  Future<WalletBalanceModel> getBalance(String currencyId);

  /// Get transaction history (ledger) for a currency
  ///
  /// Throws: ServerException, NetworkException, AuthenticationException
  Future<List<Map<String, dynamic>>> getTransactionHistory(String currencyId);

  /// Execute a wallet transaction
  ///
  /// Throws:
  ///   - ServerException: On server error (5xx)
  ///   - NetworkException: On network error
  ///   - AuthenticationException: On authentication error
  ///   - ValidationException: On validation error (insufficient balance, etc.)
  ///   - BusinessException: On business logic error (can't transfer to self, etc.)
  Future<WalletTransactionResponseModel> executeTransaction(
    WalletTransactionRequest request,
  );

  /// Điều chỉnh số dư ví thủ công (admin/risk officer)
  ///
  /// Throws: ServerException, NetworkException, AuthenticationException, ValidationException
  Future<AdminWalletAdjustmentModel> adminAdjustWallet({
    required String userId,
    required String currencyId,
    required String amount,
    required String type,
    String? note,
  });

  /// Lấy lịch sử điều chỉnh thủ công theo người dùng
  ///
  /// Throws: ServerException, NetworkException, AuthenticationException
  Future<List<AdminWalletAdjustmentModel>> getAdminAdjustmentHistory(
    String userId, {
    int limit = 50,
    int offset = 0,
  });
}

/// Implementation of WalletRemoteDataSource
class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final DioClient dioClient;

  WalletRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<WalletBalanceModel> getBalance(String currencyId) async {
    try {
      print(
          '[WalletRemoteDataSource] Fetching balance for currencyId: $currencyId');

      final response = await dioClient.dio.get(
        '/wallets/balance',
        queryParameters: {'currencyId': currencyId},
      );

      print('[WalletRemoteDataSource] Response status: ${response.statusCode}');
      print('[WalletRemoteDataSource] Response data: ${response.data}');

      // API returns: { "data": {...}, "statusCode": 200, "message": "Success" }
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw ServerException(
            message:
                'Invalid response format: expected Map, got ${data.runtimeType}');
      }

      final balanceData = data['data'] as Map<String, dynamic>?;
      if (balanceData == null) {
        print(
            '[WalletRemoteDataSource] ERROR: Balance data is null in response');
        throw ServerException(message: 'Balance data not found in response');
      }

      print('[WalletRemoteDataSource] Balance data: $balanceData');
      final balanceModel = WalletBalanceModel.fromJson(balanceData);
      print(
          '[WalletRemoteDataSource] Successfully parsed balance: available=${balanceModel.available}, frozen=${balanceModel.frozen}');

      return balanceModel;
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on AuthenticationException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e, stackTrace) {
      print('[WalletRemoteDataSource] ERROR: $e');
      print('[WalletRemoteDataSource] Stack trace: $stackTrace');
      throw ServerException(
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactionHistory(
    String currencyId,
  ) async {
    try {
      final response = await dioClient.dio.get(
        '/wallets/ledger',
        queryParameters: {'currencyId': currencyId},
      );
      final data = response.data;
      if (data is List) {
        return List<Map<String, dynamic>>.from(
          data.map((e) => Map<String, dynamic>.from(e as Map)),
        );
      }
      if (data is Map<String, dynamic> && data['data'] != null) {
        final list = data['data'] as List;
        return List<Map<String, dynamic>>.from(
          list.map((e) => Map<String, dynamic>.from(e as Map)),
        );
      }
      return [];
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  @override
  Future<WalletTransactionResponseModel> executeTransaction(
    WalletTransactionRequest request,
  ) async {
    try {
      final response = await dioClient.dio.post(
        '/wallets/transactions',
        data: request.toJson(),
      );

      // API returns: { "data": {...}, "statusCode": 200, "message": "Transaction successful" }
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw ServerException(message: 'Invalid response format');
      }

      final transactionData = data['data'] as Map<String, dynamic>?;
      if (transactionData == null) {
        throw ServerException(
          message: 'Transaction data not found in response',
        );
      }

      // Backend may return full transaction payload (with newBalance) or balance-only
      if (transactionData.containsKey('newBalance')) {
        return WalletTransactionResponseModel.fromJson(transactionData);
      }
      // Balance-only response: { userId, currencyId, available, frozen, total }
      if (transactionData.containsKey('available') &&
          transactionData.containsKey('total')) {
        final timestamp = data['timestamp']?.toString() ??
            DateTime.now().toUtc().toIso8601String();
        final newBalance =
            WalletBalanceModel.fromJson(transactionData);
        return WalletTransactionResponseModel(
          transactionId: '',
          userId: newBalance.userId,
          currencyId: newBalance.currencyId,
          action: request.action.value,
          amount: request.amount,
          refType: request.refType.value,
          refId: request.refId,
          newBalance: newBalance,
          timestamp: timestamp,
        );
      }

      return WalletTransactionResponseModel.fromJson(transactionData);
    } on DioException catch (e) {
      final data = e.response?.data;
      final statusCode = e.response?.statusCode;
      if (e.response != null && data is Map<String, dynamic>) {
        final message = (data['message'] ?? data['error'])?.toString();
        if (message != null && message.isNotEmpty) {
          if (statusCode != null && statusCode >= 400 && statusCode < 500) {
            throw ValidationException(message: message);
          }
          if (statusCode != null && statusCode >= 500) {
            throw ServerException(
              message: message,
              statusCode: statusCode,
            );
          }
        }
      }
      rethrow;
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on AuthenticationException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  @override
  Future<AdminWalletAdjustmentModel> adminAdjustWallet({
    required String userId,
    required String currencyId,
    required String amount,
    required String type,
    String? note,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.walletsAdminAdjust,
        data: {
          'userId': userId,
          'currencyId': currencyId,
          'amount': amount,
          'type': type,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
      final data = response.data;
      final payload = (data is Map<String, dynamic> && data['data'] != null)
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
      return AdminWalletAdjustmentModel.fromJson(payload);
    } on DioException catch (e) {
      _handleDioError(e);
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString().replaceAll('Exception: ', ''));
    }
    // unreachable — _handleDioError always throws
    throw ServerException(message: 'Unknown error');
  }

  @override
  Future<List<AdminWalletAdjustmentModel>> getAdminAdjustmentHistory(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.walletsAdminAdjustmentHistory(userId),
        queryParameters: {'limit': limit, 'offset': offset},
      );
      final data = response.data;
      final list = (data is Map<String, dynamic> && data['data'] is List)
          ? data['data'] as List
          : (data is List ? data : []);
      return list
          .map((e) => AdminWalletAdjustmentModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } on ServerException {
      rethrow;
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _handleDioError(DioException e) {
    final data = e.response?.data;
    final statusCode = e.response?.statusCode;
    if (e.response != null && data is Map<String, dynamic>) {
      final message = (data['message'] ?? data['error'])?.toString();
      if (message != null && message.isNotEmpty) {
        if (statusCode != null && statusCode >= 400 && statusCode < 500) {
          throw ValidationException(message: message);
        }
        if (statusCode != null && statusCode >= 500) {
          throw ServerException(message: message, statusCode: statusCode);
        }
      }
    }
    throw ServerException(message: e.message ?? 'Network error');
  }
}
