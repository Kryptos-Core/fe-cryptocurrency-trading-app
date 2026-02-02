import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/core/usecases/usecase.dart';
import 'package:crypto_trading_app/domain/entities/wallet_balance.dart';
import 'package:crypto_trading_app/domain/repositories/wallet_repository.dart';

/// Use case: Get wallet balance for a specific currency
///
/// This use case retrieves the current balance (available, frozen, total)
/// for a specific cryptocurrency currency.
///
/// Parameters:
///   - currencyId: The currency ID to fetch balance for
///
/// Returns:
///   - Either<Failure, WalletBalance>
///
/// Example:
/// ```dart
/// final result = await getWalletBalanceApiUseCase(GetWalletBalanceParams(currencyId: 1));
/// result.fold(
///   (failure) => print('Error: $failure'),
///   (balance) => print('Balance: ${balance.available}'),
/// );
/// ```
class GetWalletBalanceApiUseCase
    implements UseCase<WalletBalance, GetWalletBalanceParams> {
  final WalletRepository walletRepository;

  GetWalletBalanceApiUseCase({required this.walletRepository});

  @override
  Future<Either<Failure, WalletBalance>> call(
    GetWalletBalanceParams params,
  ) async {
    return await walletRepository.getBalance(params.currencyId);
  }
}

class GetWalletBalanceParams {
  final int currencyId;

  GetWalletBalanceParams({required this.currencyId});
}
