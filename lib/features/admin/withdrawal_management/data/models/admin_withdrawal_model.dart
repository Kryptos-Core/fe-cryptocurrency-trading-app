/// Admin withdrawal list/detail item from GET /blockchain/admin/withdrawals
class AdminWithdrawalModel {
  final String txId;
  final String userId;
  final String chain;
  final String type;
  final String? txHash;
  final String fromAddress;
  final String toAddress;
  final String amount;
  final String status;
  final int confirmations;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final String? userEmail;
  final String? userFirstName;
  final String? userLastName;
  final String? userWalletBalance;

  AdminWithdrawalModel({
    required this.txId,
    required this.userId,
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
    this.userEmail,
    this.userFirstName,
    this.userLastName,
    this.userWalletBalance,
  });

  String get userDisplayName {
    if (userFirstName != null && userFirstName!.isNotEmpty) {
      return '${userFirstName!} ${userLastName ?? ''}'.trim();
    }
    return userEmail ?? userId;
  }

  /// Symbol cho UI: TRON chains luôn dùng USDT (TRC-20)
  String get assetSymbol {
    if (chain == 'TRON_NILE' || chain == 'TRON_SHASTA' || chain == 'TRON_MAINNET') {
      return 'USDT';
    }
    // Các chain khác có thể là native coin
    final parts = chain.split('_');
    return parts.isNotEmpty ? parts.last : chain;
  }

  factory AdminWithdrawalModel.fromJson(Map<String, dynamic> json) {
    return AdminWithdrawalModel(
      txId: json['txId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      chain: json['chain']?.toString() ?? '',
      type: json['type']?.toString() ?? 'WITHDRAWAL',
      txHash: json['txHash']?.toString(),
      fromAddress: json['fromAddress']?.toString() ?? '',
      toAddress: json['toAddress']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      status: json['status']?.toString() ?? 'PENDING',
      confirmations: (json['confirmations'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      confirmedAt: DateTime.tryParse(json['confirmedAt']?.toString() ?? ''),
      userEmail: json['userEmail']?.toString(),
      userFirstName: json['userFirstName']?.toString(),
      userLastName: json['userLastName']?.toString(),
      userWalletBalance: json['userWalletBalance']?.toString(),
    );
  }
}

/// Stats from GET /blockchain/admin/withdrawals/stats
class AdminWithdrawalStatsModel {
  final int pendingCount;
  final Map<String, String> pendingTotalByChain;

  AdminWithdrawalStatsModel({
    required this.pendingCount,
    required this.pendingTotalByChain,
  });

  factory AdminWithdrawalStatsModel.fromJson(Map<String, dynamic> json) {
    final byChain = json['pendingTotalByChain'];
    Map<String, String> map = {};
    if (byChain is Map) {
      for (final e in byChain.entries) {
        map[e.key.toString()] = e.value?.toString() ?? '0';
      }
    }
    return AdminWithdrawalStatsModel(
      pendingCount: (json['pendingCount'] as num?)?.toInt() ?? 0,
      pendingTotalByChain: map,
    );
  }
}
