import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';

class ManagedWallet {
  final String walletId;
  final String userId;
  final BlockchainNetwork chain;
  final String address;
  final String? label;
  final bool isDefaultDeposit;
  final DateTime? defaultSetAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ManagedWallet({
    required this.walletId,
    required this.userId,
    required this.chain,
    required this.address,
    this.label,
    required this.isDefaultDeposit,
    this.defaultSetAt,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  String get truncatedAddress {
    if (address.length <= 14) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 6)}';
  }

  String get displayLabel => label?.isNotEmpty == true ? label! : truncatedAddress;
}
