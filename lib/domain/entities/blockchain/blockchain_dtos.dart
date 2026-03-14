import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';

class RequestLinkResponse {
  final String message;
  final int expiresIn;

  const RequestLinkResponse({
    required this.message,
    required this.expiresIn,
  });
}

class VerifyLinkResponse {
  final String linkId;
  final BlockchainNetwork chain;
  final String address;
  final String status;

  const VerifyLinkResponse({
    required this.linkId,
    required this.chain,
    required this.address,
    required this.status,
  });
}

class SubmitDepositRequest {
  final BlockchainNetwork chain;
  final String txHash;
  final String amount;

  const SubmitDepositRequest({
    required this.chain,
    required this.txHash,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'chain': chain.apiValue,
      'txHash': txHash,
      'amount': amount,
    };
  }
}

class RequestWithdrawalRequest {
  final BlockchainNetwork chain;
  final String linkedWalletId;
  final String amount;

  const RequestWithdrawalRequest({
    required this.chain,
    required this.linkedWalletId,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'chain': chain.apiValue,
      'linkedWalletId': linkedWalletId,
      'amount': amount,
    };
  }
}
