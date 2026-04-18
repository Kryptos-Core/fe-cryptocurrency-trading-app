class ManagedWalletTransaction {
  final String txId;
  final String? txHash;
  final String fromAddress;
  final String toAddress;
  final String amount;
  final String status;
  final DateTime createdAt;

  const ManagedWalletTransaction({
    required this.txId,
    this.txHash,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  String get truncatedHash {
    final h = txHash ?? '';
    if (h.length <= 14) return h;
    return '${h.substring(0, 8)}...${h.substring(h.length - 6)}';
  }

  bool get isIncoming => toAddress.isNotEmpty;
}
