import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';

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

class DepositAddressResponse {
  final BlockchainNetwork chain;
  final String depositAddress;
  final String? note;

  const DepositAddressResponse({
    required this.chain,
    required this.depositAddress,
    this.note,
  });
}

class DepositPreviewResponse {
  final BlockchainNetwork chain;
  final String txHash;
  final String status;
  final int confirmations;
  final String fromAddress;
  final String toAddress;
  final String onchainAmount;
  final bool senderLinked;

  const DepositPreviewResponse({
    required this.chain,
    required this.txHash,
    required this.status,
    required this.confirmations,
    required this.fromAddress,
    required this.toAddress,
    required this.onchainAmount,
    required this.senderLinked,
  });
}

class SubmitDepositRequest {
  final BlockchainNetwork chain;
  final String txHash;
  final String? amount;

  const SubmitDepositRequest({
    required this.chain,
    required this.txHash,
    this.amount,
  });

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'chain': chain.apiValue,
      'txHash': txHash,
    };
    final a = amount?.trim();
    if (a != null && a.isNotEmpty) {
      m['amount'] = a;
    }
    return m;
  }
}

class RequestWithdrawalRequest {
  final BlockchainNetwork chain;
  final String linkedWalletId;
  final String amount;
  final String? currency;

  const RequestWithdrawalRequest({
    required this.chain,
    required this.linkedWalletId,
    required this.amount,
    this.currency,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'chain': chain.apiValue,
      'linkedWalletId': linkedWalletId,
      'amount': amount,
    };
    if (currency != null) {
      json['currency'] = currency;
    }
    return json;
  }
}
