/// Đại diện một giao dịch on-chain (nạp/rút/chuyển trên blockchain).
/// Domain Layer — Clean Architecture.
class OnchainTransaction {
  final String txId;
  final String userId;
  final String? linkedWalletId;
  final String chain;
  final String type; // DEPOSIT | WITHDRAWAL | TRANSFER
  final String? txHash;
  final String fromAddress;
  final String toAddress;
  final String amount;
  final int confirmations;
  final String status; // PENDING | CONFIRMING | COMPLETED | FAILED
  final DateTime createdAt;
  final DateTime? confirmedAt;

  const OnchainTransaction({
    required this.txId,
    required this.userId,
    this.linkedWalletId,
    required this.chain,
    required this.type,
    this.txHash,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.confirmations,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
  });

  bool get isDeposit => type == 'DEPOSIT';
  bool get isWithdrawal => type == 'WITHDRAWAL';
  bool get isCompleted => status == 'COMPLETED';
  bool get isPending => status == 'PENDING' || status == 'CONFIRMING';
  bool get isFailed => status == 'FAILED';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnchainTransaction &&
          runtimeType == other.runtimeType &&
          txId == other.txId;

  @override
  int get hashCode => txId.hashCode;

  @override
  String toString() =>
      'OnchainTransaction(txId: $txId, type: $type, amount: $amount, status: $status)';
}
