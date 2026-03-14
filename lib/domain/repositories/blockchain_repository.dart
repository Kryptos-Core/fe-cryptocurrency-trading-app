import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_dtos.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/linked_wallet.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/onchain_transaction.dart';

abstract class BlockchainRepository {
  Future<Either<Failure, RequestLinkResponse>> requestLink({
    required BlockchainNetwork chain,
    required String address,
    String? label,
  });

  Future<Either<Failure, VerifyLinkResponse>> verifyLink({
    required BlockchainNetwork chain,
    required String address,
    required String signature,
  });

  Future<Either<Failure, List<LinkedWallet>>> getLinkedWallets();

  Future<Either<Failure, LinkedWalletBalance>> getLinkedWalletBalance(
    String linkId,
  );

  Future<Either<Failure, bool>> unlinkWallet(String linkId);

  Future<Either<Failure, OnchainTransaction>> submitDeposit(
    SubmitDepositRequest request,
  );

  Future<Either<Failure, OnchainTransaction>> requestWithdrawal(
    RequestWithdrawalRequest request,
  );

  Future<Either<Failure, List<OnchainTransaction>>> getTransactions({
    int limit = 50,
  });
}
