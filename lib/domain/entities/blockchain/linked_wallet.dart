import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/linked_wallet_status.dart';

class LinkedWallet {
  final String linkId;
  final BlockchainNetwork chain;
  final String address;
  final String? label;
  final LinkedWalletStatus status;
  final DateTime? linkedAt;

  const LinkedWallet({
    required this.linkId,
    required this.chain,
    required this.address,
    this.label,
    required this.status,
    this.linkedAt,
  });
}

class LinkedWalletBalance {
  final String linkId;
  final BlockchainNetwork chain;
  final String address;
  final String balance;

  const LinkedWalletBalance({
    required this.linkId,
    required this.chain,
    required this.address,
    required this.balance,
  });
}
