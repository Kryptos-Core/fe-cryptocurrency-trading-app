class TreasuryWalletModel {
  final String walletId;
  final String chain;
  final String address;
  final String purpose;
  final String? label;
  final bool isActive;
  /// Backend: default on-chain deposit address for users on this chain.
  final bool isDefaultUserDeposit;
  final String? balance;
  final String? symbol;
  /// TRON: USDT (TRC-20) human balance from API
  final String? usdtTrc20Balance;
  final DateTime? createdAt;

  const TreasuryWalletModel({
    required this.walletId,
    required this.chain,
    required this.address,
    required this.purpose,
    required this.label,
    required this.isActive,
    this.isDefaultUserDeposit = false,
    this.balance,
    this.symbol,
    this.usdtTrc20Balance,
    this.createdAt,
  });

  factory TreasuryWalletModel.fromJson(Map<String, dynamic> json) {
    return TreasuryWalletModel(
      walletId: (json['wallet_id'] ?? json['walletId'] ?? '').toString(),
      chain: (json['chain'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      purpose: (json['purpose'] ?? 'BOTH').toString(),
      label: json['label']?.toString(),
      isActive: json['is_active'] != false && json['is_active'] != 0,
      isDefaultUserDeposit: json['is_default_user_deposit'] == true ||
          json['is_default_user_deposit'] == 1 ||
          json['isDefaultUserDeposit'] == true,
      balance: json['balance']?.toString(),
      symbol: json['symbol']?.toString(),
      usdtTrc20Balance: json['usdtTrc20Balance']?.toString() ??
          json['usdt_trc20_balance']?.toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }

  String get shortAddress {
    if (address.length <= 14) return address;
    return '${address.substring(0, 7)}...${address.substring(address.length - 7)}';
  }
}

class TreasuryOperationModel {
  final String operationId;
  final String type;
  final String chain;
  final String status;
  final String amount;
  final String? txHash;
  final String? fromWalletId;
  final String? toWalletId;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final String? failureReason;

  const TreasuryOperationModel({
    required this.operationId,
    required this.type,
    required this.chain,
    required this.status,
    required this.amount,
    this.txHash,
    this.fromWalletId,
    this.toWalletId,
    this.createdAt,
    this.completedAt,
    this.failureReason,
  });

  factory TreasuryOperationModel.fromJson(Map<String, dynamic> json) {
    return TreasuryOperationModel(
      operationId: (json['operation_id'] ?? json['operationId'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      chain: (json['chain'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      amount: (json['amount'] ?? '0').toString(),
      txHash: json['tx_hash']?.toString(),
      fromWalletId: json['from_wallet_id']?.toString(),
      toWalletId: json['to_wallet_id']?.toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      completedAt: DateTime.tryParse((json['completed_at'] ?? '').toString()),
      failureReason: json['failure_reason']?.toString(),
    );
  }
}

class TreasuryTransactionModel {
  final String txId;
  final String type;
  final String chain;
  final String status;
  final String amount;
  final String? txHash;
  final String fromAddress;
  final String toAddress;
  final DateTime? createdAt;

  const TreasuryTransactionModel({
    required this.txId,
    required this.type,
    required this.chain,
    required this.status,
    required this.amount,
    this.txHash,
    required this.fromAddress,
    required this.toAddress,
    this.createdAt,
  });

  factory TreasuryTransactionModel.fromJson(Map<String, dynamic> json) {
    return TreasuryTransactionModel(
      txId: (json['tx_id'] ?? json['txId'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      chain: (json['chain'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      amount: (json['amount'] ?? '0').toString(),
      txHash: json['tx_hash']?.toString(),
      fromAddress: (json['from_address'] ?? '').toString(),
      toAddress: (json['to_address'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }
}

class TreasuryMainWalletModel {
  final String mainWalletId;
  final String chain;
  final String address;
  final String? label;
  final String balance;
  final String symbol;
  final String? usdtTrc20Balance;
  final bool isDefault;
  final String status;
  final DateTime? createdAt;
  final DateTime? lastRotatedAt;

  const TreasuryMainWalletModel({
    required this.mainWalletId,
    required this.chain,
    required this.address,
    this.label,
    required this.balance,
    required this.symbol,
    this.usdtTrc20Balance,
    required this.isDefault,
    required this.status,
    this.createdAt,
    this.lastRotatedAt,
  });

  factory TreasuryMainWalletModel.fromJson(Map<String, dynamic> json) {
    return TreasuryMainWalletModel(
      mainWalletId: (json['mainWalletId'] ?? json['main_wallet_id'] ?? '').toString(),
      chain: (json['chain'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      label: json['label']?.toString(),
      balance: (json['balance'] ?? '0').toString(),
      symbol: (json['symbol'] ?? '').toString(),
      usdtTrc20Balance: json['usdtTrc20Balance']?.toString() ??
          json['usdt_trc20_balance']?.toString(),
      isDefault: json['isDefault'] == true || json['is_default'] == true,
      status: (json['status'] ?? 'ACTIVE').toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      lastRotatedAt: json['last_rotated_at'] != null ? DateTime.tryParse(json['last_rotated_at'].toString()) : null,
    );
  }
}

class TreasuryPageResult<T> {
  final List<T> items;
  final int total;
  final int page;
  final int limit;

  const TreasuryPageResult({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });
}
