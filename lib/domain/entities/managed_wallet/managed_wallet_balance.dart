class ManagedWalletBalance {
  final String walletId;
  final String address;
  final String balance;
  final String symbol;
  final DateTime fetchedAt;

  const ManagedWalletBalance({
    required this.walletId,
    required this.address,
    required this.balance,
    required this.symbol,
    required this.fetchedAt,
  });
}
