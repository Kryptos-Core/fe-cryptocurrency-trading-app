import 'package:crypto_trading_app/core/error/exceptions.dart';
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
  Future<WalletBalanceModel> getBalance(int currencyId);

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
}

/// Implementation of WalletRemoteDataSource
class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final DioClient dioClient;

  WalletRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<WalletBalanceModel> getBalance(int currencyId) async {
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

      return WalletTransactionResponseModel.fromJson(transactionData);
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
}
