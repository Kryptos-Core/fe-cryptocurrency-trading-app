import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/onchain_tx_status.dart';

enum OnchainTxType {
  deposit,
  withdrawal,
  transfer,
}

extension OnchainTxTypeX on OnchainTxType {
  String get apiValue {
    switch (this) {
      case OnchainTxType.deposit:
        return 'DEPOSIT';
      case OnchainTxType.withdrawal:
        return 'WITHDRAWAL';
      case OnchainTxType.transfer:
        return 'TRANSFER';
    }
  }

  static OnchainTxType fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'DEPOSIT':
        return OnchainTxType.deposit;
      case 'WITHDRAWAL':
        return OnchainTxType.withdrawal;
      case 'TRANSFER':
        return OnchainTxType.transfer;
      default:
        throw ArgumentError('Unsupported on-chain tx type: $value');
    }
  }
}

class OnchainTransaction {
  final String txId;
  final BlockchainNetwork chain;
  final OnchainTxType type;
  final String? txHash;
  final String fromAddress;
  final String toAddress;
  final String amount;
  final OnchainTxStatus status;
  final int confirmations;
  final DateTime createdAt;
  final DateTime? confirmedAt;

  const OnchainTransaction({
    required this.txId,
    required this.chain,
    required this.type,
    this.txHash,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.status,
    required this.confirmations,
    required this.createdAt,
    this.confirmedAt,
  });
}
