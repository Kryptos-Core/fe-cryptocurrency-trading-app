/// Flat on-chain ledger row for admin user detail (matches JSON from admin API).
/// Separate from [OnchainTransaction] in blockchain domain (typed chains / enums).
class UserLedgerOnchainTransaction {
  final String txId;
  final String userId;
  final String? linkedWalletId;
  final String chain;
  final String type;
  final String? txHash;
  final String fromAddress;
  final String toAddress;
  final String amount;
  final int confirmations;
  final String status;
  final DateTime createdAt;
  final DateTime? confirmedAt;

  /// API `type` is typically DEPOSIT | WITHDRAWAL | TRANSFER (uppercase).
  bool get isDeposit => type.toUpperCase() == 'DEPOSIT';

  /// Terminal failure state from API `status`.
  bool get isFailed => status.toUpperCase() == 'FAILED';

  const UserLedgerOnchainTransaction({
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
}
