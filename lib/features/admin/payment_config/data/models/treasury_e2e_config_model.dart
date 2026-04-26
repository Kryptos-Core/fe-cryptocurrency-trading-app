/// Treasury E2E config model for admin UI.
class TreasuryE2EConfigModel {
  final String configId;
  final String environment;
  final String displayName;
  final String apiBaseUrl;
  final String chain;
  final String? linkedWalletId;
  final String withdrawAmountAuto;
  final String withdrawAmountManual;
  final String? depositTxHash;
  final String? depositAmount;
  final bool allowSkip;
  final bool healthFailOnCritical;
  final int staleManualMinutes;
  final int staleConfirmingMinutes;
  final int failedWithdrawals24h;
  final int reconcilePairLimit;
  final String reconciliationThreshold;
  final int configVersion;
  final String status;
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? activatedAt;
  final DateTime? archivedAt;
  final bool hasTraderBearerToken;
  final bool hasRiskBearerToken;
  final String? traderBearerTokenMasked;
  final String? riskBearerTokenMasked;
  final String? traderUserId;
  final String? riskUserId;

  const TreasuryE2EConfigModel({
    required this.configId,
    required this.environment,
    required this.displayName,
    required this.apiBaseUrl,
    required this.chain,
    required this.linkedWalletId,
    required this.withdrawAmountAuto,
    required this.withdrawAmountManual,
    required this.depositTxHash,
    required this.depositAmount,
    required this.allowSkip,
    required this.healthFailOnCritical,
    required this.staleManualMinutes,
    required this.staleConfirmingMinutes,
    required this.failedWithdrawals24h,
    required this.reconcilePairLimit,
    required this.reconciliationThreshold,
    required this.configVersion,
    required this.status,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.activatedAt,
    required this.archivedAt,
    this.hasTraderBearerToken = false,
    this.hasRiskBearerToken = false,
    this.traderBearerTokenMasked,
    this.riskBearerTokenMasked,
    this.traderUserId,
    this.riskUserId,
  });

  factory TreasuryE2EConfigModel.fromJson(Map<String, dynamic> json) {
    return TreasuryE2EConfigModel(
      configId: (json['treasury_e2e_config_id'] ?? json['config_id'] ?? '') as String,
      environment: (json['environment'] ?? 'development') as String,
      displayName: (json['display_name'] ?? '') as String,
      apiBaseUrl: (json['api_base_url'] ?? '') as String,
      chain: (json['chain'] ?? '') as String,
      linkedWalletId: json['linked_wallet_id'] as String?,
      withdrawAmountAuto: '${json['withdraw_amount_auto'] ?? '0'}',
      withdrawAmountManual: '${json['withdraw_amount_manual'] ?? '0'}',
      depositTxHash: json['deposit_tx_hash'] as String?,
      depositAmount: json['deposit_amount']?.toString(),
      allowSkip: json['allow_skip'] == true,
      healthFailOnCritical: json['health_fail_on_critical'] == true,
      staleManualMinutes: (json['stale_manual_minutes'] as num?)?.toInt() ?? 15,
      staleConfirmingMinutes: (json['stale_confirming_minutes'] as num?)?.toInt() ?? 30,
      failedWithdrawals24h: (json['failed_withdrawals_24h'] as num?)?.toInt() ?? 10,
      reconcilePairLimit: (json['reconcile_pair_limit'] as num?)?.toInt() ?? 100,
      reconciliationThreshold: '${json['reconciliation_threshold'] ?? '0.001'}',
      configVersion: (json['config_version'] as num?)?.toInt() ?? 1,
      status: (json['status'] ?? 'INACTIVE') as String,
      createdBy: (json['created_by'] ?? '') as String,
      updatedBy: (json['updated_by'] ?? '') as String,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      activatedAt: json['activated_at'] != null
          ? DateTime.tryParse(json['activated_at'].toString())
          : null,
      archivedAt: json['archived_at'] != null
          ? DateTime.tryParse(json['archived_at'].toString())
          : null,
      hasTraderBearerToken: json['has_trader_bearer_token'] == true,
      hasRiskBearerToken: json['has_risk_bearer_token'] == true,
      traderBearerTokenMasked: json['trader_bearer_token_masked'] as String?,
      riskBearerTokenMasked: json['risk_bearer_token_masked'] as String?,
      traderUserId: json['trader_user_id'] as String?,
      riskUserId: json['risk_user_id'] as String?,
    );
  }

  bool get isActive => status == 'ACTIVE';
  bool get isInactive => status == 'INACTIVE';
  bool get isArchived => status == 'ARCHIVED';
}
