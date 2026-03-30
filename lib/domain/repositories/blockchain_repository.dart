import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_dtos.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/linked_wallet.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/onchain_transaction.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/wc_session_proposal.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/wc_session_status.dart';

abstract class BlockchainRepository {
  Future<Either<Failure, DepositAddressResponse>> getDepositAddress(
    BlockchainNetwork chain,
  );

  Future<Either<Failure, DepositPreviewResponse>> previewDeposit(
    BlockchainNetwork chain,
    String txHash,
  );

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

  // ============ WalletConnect v2 ============

  /// Bước 1: Tạo WalletConnect session URI
  /// FE dùng [WcSessionProposal.wcUri] để hiển thị QR hoặc deep link
  Future<Either<Failure, WcSessionProposal>> initWcSession(
    BlockchainNetwork chain,
  );

  /// Bước 2: Poll trạng thái WC session (mỗi 2 giây)
  /// Khi status = [WcSessionStatus.signed], FE cần submit signature
  Future<Either<Failure, WcSessionStatus>> getWcSessionStatus(
    String sessionId,
  );

  /// Bước 3: Submit signature từ WC SDK sau khi user ký
  /// BE verify on-chain và tạo linked_wallet record
  Future<Either<Failure, VerifyLinkResponse>> submitWcSignature({
    required String sessionId,
    required String address,
    required String signature,
    required BlockchainNetwork chain,
  });
}

