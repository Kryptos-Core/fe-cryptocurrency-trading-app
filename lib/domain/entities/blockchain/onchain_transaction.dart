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
      // Treasury ops rows may appear in shared history feeds — show as transfer for traders.
      case 'SWEEP':
      case 'FUND':
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
  /// Số lượng native coin gốc (TRX/ETH/SOL)
  final String amount;
  final OnchainTxStatus status;
  final int confirmations;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  /// Số USDT thực tế được credit vào Ví Tiền Ảo (null nếu chưa settled hoặc withdrawal)
  final String? creditedAmount;
  /// ID currency được credit (thường là USDT currency_id)
  final String? creditedCurrencyId;
  /// Tỷ giá quy đổi: 1 native coin = X USDT tại thời điểm giao dịch
  final String? conversionRate;

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
    this.creditedAmount,
    this.creditedCurrencyId,
    this.conversionRate,
  });

  /// Trả về true nếu đây là deposit đã được quy đổi sang USDT
  bool get hasFxConversion =>
      type == OnchainTxType.deposit &&
      creditedAmount != null &&
      conversionRate != null &&
      conversionRate != '1';
}
