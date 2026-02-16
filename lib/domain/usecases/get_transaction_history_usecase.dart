import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/core/usecases/usecase.dart';
import 'package:crypto_trading_app/domain/entities/wallet_transaction.dart';
import 'package:crypto_trading_app/domain/repositories/wallet_repository.dart';

/// Use case: Get transaction history (ledger) for a currency
class GetTransactionHistoryApiUseCase
    implements UseCase<List<WalletTransactionResponse>, GetTransactionHistoryParams> {
  final WalletRepository walletRepository;

  GetTransactionHistoryApiUseCase({required this.walletRepository});

  @override
  Future<Either<Failure, List<WalletTransactionResponse>>> call(
    GetTransactionHistoryParams params,
  ) async {
    return await walletRepository.getTransactionHistory(params.currencyId);
  }
}

class GetTransactionHistoryParams {
  final String currencyId;

  GetTransactionHistoryParams({required this.currencyId});
}
