import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/data/datasources/wallet_local_datasource.dart';
import 'package:crypto_trading_app/data/datasources/wallet_remote_datasource.dart';
import 'package:crypto_trading_app/domain/entities/wallet_balance.dart';
import 'package:crypto_trading_app/domain/entities/wallet_transaction.dart';
import 'package:crypto_trading_app/domain/entities/wallet_balance.dart';
import 'package:crypto_trading_app/domain/repositories/wallet_repository.dart';

/// This repository bridges between the domain layer and data layer.
/// It handles:
/// - Error translation (Exceptions → Failures)
/// - Data source selection (Remote vs Local)
/// - Caching logic
/// - Business rule enforcement
class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;
  final WalletLocalDataSource localDataSource;

  WalletRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, WalletBalance>> getBalance(int currencyId) async {
    try {
      // Try to get from remote (API)
      final balanceModel = await remoteDataSource.getBalance(currencyId);

      // Cache locally for offline access
      await localDataSource.cacheBalance(
        balanceModel.toDomain(),
        currencyId,
      );

      return Right(balanceModel.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      // Network error - try to return cached balance
      final cached = await localDataSource.getCachedBalance(currencyId);
      if (cached != null) {
        return Right(cached); // Return cached balance
      }
      return Left(NetworkFailure(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WalletTransactionResponse>>> getTransactionHistory(
    int currencyId,
  ) async {
    try {
      final list = await remoteDataSource.getTransactionHistory(currencyId);
      final placeholders = WalletBalance(
        userId: 0,
        currencyId: currencyId,
        available: '0',
        frozen: '0',
        total: '0',
      );
      final results = list.map((e) {
        final action = (e['direction'] as String?) == 'CREDIT'
            ? WalletTransactionAction.credit
            : WalletTransactionAction.debit;
        final refTypeStr = e['refType'] as String? ?? 'DEPOSIT';
        final refType = WalletReferenceType.fromString(refTypeStr) ??
            WalletReferenceType.deposit;
        final createdAt = e['createdAt'] as String?;
        final timestamp = createdAt != null
            ? DateTime.tryParse(createdAt) ?? DateTime.now()
            : DateTime.now();
        return WalletTransactionResponse(
          transactionId: 'ledger-${e['refId']}',
          userId: 0,
          currencyId: currencyId,
          action: action,
          amount: (e['amount'] ?? '0').toString(),
          refType: refType,
          refId: (e['refId'] as num?)?.toInt() ?? 0,
          newBalance: placeholders,
          timestamp: timestamp,
        );
      }).toList();
      return Right(results);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WalletTransactionResponse>> executeTransaction(
    WalletTransactionRequest request,
  ) async {
    try {
      // Validate request before sending
      final validationError = _validateTransactionRequest(request);
      if (validationError != null) {
        return Left(ValidationFailure(message: validationError));
      }

      // Execute remote transaction
      final responseModel = await remoteDataSource.executeTransaction(request);
      final response = responseModel.toDomain();

      // Cache the new balance locally
      await localDataSource.cacheBalance(
        response.newBalance,
        request.currencyId,
      );

      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<void> cacheBalance(WalletBalance balance, int currencyId) async {
    await localDataSource.cacheBalance(balance, currencyId);
  }

  @override
  Future<WalletBalance?> getCachedBalance(int currencyId) async {
    return await localDataSource.getCachedBalance(currencyId);
  }

  @override
  Future<void> clearCachedBalance(int currencyId) async {
    await localDataSource.clearCachedBalance(currencyId);
  }

  @override
  Future<void> clearAllCachedBalances() async {
    await localDataSource.clearAllCachedBalances();
  }

  /// Validate transaction request
  /// Returns error message if invalid, null if valid
  String? _validateTransactionRequest(WalletTransactionRequest request) {
    // Validate amount format (decimal with max 18 decimals)
    if (!_isValidDecimalAmount(request.amount)) {
      return 'Invalid amount format. Must be decimal with max 18 decimals (e.g., "5.123456789012345678")';
    }

    // Validate amount > 0
    try {
      final amountNum = double.parse(request.amount);
      if (amountNum <= 0) {
        return 'Amount must be greater than 0';
      }
    } catch (e) {
      return 'Invalid amount value';
    }

    // Validate TRANSFER action has targetUserId
    if (request.action == WalletTransactionAction.transfer &&
        request.targetUserId == null) {
      return 'Target user ID is required for TRANSFER action';
    }

    // Validate currencyId > 0
    if (request.currencyId <= 0) {
      return 'Invalid currency ID';
    }

    // Validate refId > 0
    if (request.refId <= 0) {
      return 'Invalid reference ID';
    }

    return null; // Valid
  }

  /// Check if amount is valid decimal format
  /// Valid formats: "5", "5.5", "5.123456789012345678" (max 18 decimals)
  bool _isValidDecimalAmount(String amount) {
    final decimalRegex = RegExp(r'^\d+(\.\d{1,18})?$');
    return decimalRegex.hasMatch(amount);
  }
}
