import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/core/usecases/usecase.dart';
import 'package:crypto_trading_app/domain/entities/wallet_transaction.dart';
import 'package:crypto_trading_app/domain/repositories/wallet_repository.dart';

/// Use case: Execute a wallet transaction (CREDIT, DEBIT, FREEZE, UNFREEZE, TRANSFER)
///
/// This use case handles all types of wallet transactions with proper validation
/// and error handling. It follows the double-entry accounting principle where
/// each transaction creates credit and debit entries.
///
/// Parameters:
///   - request: WalletTransactionRequest with transaction details
///
/// Returns:
///   - Either<Failure, WalletTransactionResponse>
///
/// Example - Deposit (CREDIT):
/// ```dart
/// final params = ExecuteWalletTransactionParams(
///   request: WalletTransactionRequest(
///     currencyId: 1,
///     amount: '10.5',
///     action: WalletTransactionAction.credit,
///     refType: WalletReferenceType.deposit,
///     refId: 123,
///   ),
/// );
/// final result = await executeWalletTransactionApiUseCase(params);
/// result.fold(
///   (failure) => print('Transaction failed: $failure'),
///   (response) => print('New balance: ${response.newBalance.available}'),
/// );
/// ```
///
/// Example - Freeze (for order):
/// ```dart
/// final params = ExecuteWalletTransactionParams(
///   request: WalletTransactionRequest(
///     currencyId: 2,
///     amount: '500000',
///     action: WalletTransactionAction.freeze,
///     refType: WalletReferenceType.order,
///     refId: 789,
///   ),
/// );
/// final result = await executeWalletTransactionApiUseCase(params);
/// ```
///
/// Example - Transfer:
/// ```dart
/// final params = ExecuteWalletTransactionParams(
///   request: WalletTransactionRequest(
///     currencyId: 1,
///     amount: '5.5',
///     action: WalletTransactionAction.transfer,
///     refType: WalletReferenceType.transfer,
///     refId: 456,
///     targetUserId: 2,
///   ),
/// );
/// final result = await executeWalletTransactionApiUseCase(params);
/// ```
class ExecuteWalletTransactionApiUseCase
    implements
        UseCase<WalletTransactionResponse, ExecuteWalletTransactionParams> {
  final WalletRepository walletRepository;

  ExecuteWalletTransactionApiUseCase({required this.walletRepository});

  @override
  Future<Either<Failure, WalletTransactionResponse>> call(
    ExecuteWalletTransactionParams params,
  ) async {
    return await walletRepository.executeTransaction(params.request);
  }
}

class ExecuteWalletTransactionParams {
  final WalletTransactionRequest request;

  ExecuteWalletTransactionParams({required this.request});
}
