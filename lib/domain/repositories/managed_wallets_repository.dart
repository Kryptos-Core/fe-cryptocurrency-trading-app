import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/managed_wallet/managed_wallet.dart';
import 'package:crypto_trading_app/domain/entities/managed_wallet/managed_wallet_balance.dart';
import 'package:crypto_trading_app/domain/entities/managed_wallet/managed_wallet_transaction.dart';
import 'package:crypto_trading_app/domain/entities/managed_wallet/deposit_method.dart';

abstract class ManagedWalletsRepository {
  Future<Either<Failure, List<ManagedWallet>>> listWallets();

  Future<Either<Failure, List<ManagedWallet>>> getDepositDefaults();

  Future<Either<Failure, ManagedWalletBalance>> getWalletDetail(String walletId);

  Future<Either<Failure, List<ManagedWalletTransaction>>> getWalletTransactions(String walletId);

  Future<Either<Failure, bool>> sendTrx({
    required String walletId,
    required String toAddress,
    required String amount,
  });

  Future<Either<Failure, ManagedWallet>> setDepositDefault(String walletId);

  Future<Either<Failure, String>> setRecommendedChain(String chain);

  Future<Either<Failure, bool>> deactivateWallet(String walletId);

  Future<Either<Failure, DepositMethodsResponse>> getDepositMethods();
}
