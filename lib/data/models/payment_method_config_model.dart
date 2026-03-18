/// Payment method config model — mirrors BE PaymentMethodConfig entity.
/// encrypted_config is NOT returned by the list API, only the metadata is exposed.
class PaymentMethodConfigModel {
  final String configId;
  final String type; // 'PAYOS' | 'ETH' | 'TRON' | 'SOL'
  final String network; // 'MAINNET' | 'TESTNET' | 'NILE' | 'SHASTA' | 'SEPOLIA' etc.
  final String displayName;
  final int configVersion;
  final String status; // 'ACTIVE' | 'TRANSITIONING' | 'INACTIVE'
  final int gracePeriodMinutes;
  final DateTime? transitionStartedAt;
  final DateTime? activatedAt;
  final int sortOrder;
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentMethodConfigModel({
    required this.configId,
    required this.type,
    required this.network,
    required this.displayName,
    required this.configVersion,
    required this.status,
    required this.gracePeriodMinutes,
    this.transitionStartedAt,
    this.activatedAt,
    required this.sortOrder,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentMethodConfigModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodConfigModel(
      configId: json['config_id'] as String,
      type: json['type'] as String,
      network: json['network'] as String,
      displayName: json['display_name'] as String,
      configVersion: (json['config_version'] as num?)?.toInt() ?? 1,
      status: json['status'] as String? ?? 'INACTIVE',
      gracePeriodMinutes: (json['grace_period_minutes'] as num?)?.toInt() ?? 15,
      transitionStartedAt: json['transition_started_at'] != null
          ? DateTime.tryParse(json['transition_started_at'] as String)
          : null,
      activatedAt: json['activated_at'] != null
          ? DateTime.tryParse(json['activated_at'] as String)
          : null,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdBy: json['created_by'] as String? ?? '',
      updatedBy: json['updated_by'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  bool get isActive => status == 'ACTIVE';
  bool get isTransitioning => status == 'TRANSITIONING';
  bool get isInactive => status == 'INACTIVE';

  /// How many minutes remain in the grace period (only valid when TRANSITIONING).
  int? get graceMinsRemaining {
    if (!isTransitioning || transitionStartedAt == null) return null;
    final elapsed = DateTime.now().difference(transitionStartedAt!).inMinutes;
    final remaining = gracePeriodMinutes - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  String get typeLabel {
    switch (type) {
      case 'PAYOS':
        return 'PayOS (Chuyển khoản ngân hàng)';
      case 'ETH':
        return 'Ethereum';
      case 'TRON':
        return 'TRON';
      case 'SOL':
        return 'Solana';
      default:
        return type;
    }
  }
}

/// Event payload received via WebSocket `payment_config:event`
class PaymentConfigEvent {
  final String event; // 'TRANSITIONING' | 'ACTIVATED' | 'DEACTIVATED'
  final String type;
  final String network;
  final String configId;
  final int? graceMins;
  final DateTime timestamp;

  const PaymentConfigEvent({
    required this.event,
    required this.type,
    required this.network,
    required this.configId,
    this.graceMins,
    required this.timestamp,
  });

  factory PaymentConfigEvent.fromJson(Map<String, dynamic> json) {
    return PaymentConfigEvent(
      event: json['event'] as String,
      type: json['type'] as String,
      network: json['network'] as String,
      configId: json['configId'] as String,
      graceMins: (json['graceMins'] as num?)?.toInt(),
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
