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
      transitionStartedAt: _parseServerInstant(json['transition_started_at']),
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

  /// Time left until grace ends; [Duration.zero] if past end but still TRANSITIONING.
  /// Uses wall-clock end = [transitionStartedAt] + [gracePeriodMinutes].
  Duration? get graceCountdown {
    if (!isTransitioning || transitionStartedAt == null) return null;
    final end = transitionStartedAt!.add(Duration(minutes: gracePeriodMinutes));
    final left = end.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  /// Whole minutes remaining (0 when under one minute but not yet expired).
  int? get graceMinsRemaining {
    final cd = graceCountdown;
    if (cd == null) return null;
    if (cd <= Duration.zero) return 0;
    return cd.inMinutes;
  }

  /// Parses API datetimes; unqualified values are treated as UTC (MySQL DATETIME).
  static DateTime? _parseServerInstant(dynamic v) {
    if (v == null) return null;
    final raw = v.toString().trim();
    if (raw.isEmpty) return null;
    var dt = DateTime.tryParse(raw);
    if (dt != null) {
      return dt;
    }
    final norm = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
    if (!norm.endsWith('Z') && !RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(norm)) {
      dt = DateTime.tryParse('${norm}Z');
    }
    return dt;
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
