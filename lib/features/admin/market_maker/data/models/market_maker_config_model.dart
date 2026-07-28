class MarketMakerPairOption {
  final String pairId;
  final String symbol;
  final String minOrderAmount;

  const MarketMakerPairOption({
    required this.pairId,
    required this.symbol,
    required this.minOrderAmount,
  });

  factory MarketMakerPairOption.fromJson(Map<String, dynamic> json) {
    return MarketMakerPairOption(
      pairId: (json['pair_id'] ?? '').toString(),
      symbol: (json['symbol'] ?? '').toString(),
      minOrderAmount: (json['min_order_amount'] ?? '0').toString(),
    );
  }

  /// Returns the numeric min order amount for client-side comparison.
  /// Returns `null` if the string is not a valid number.
  double? get minOrderAmountValue {
    final v = double.tryParse(minOrderAmount);
    if (v == null || !v.isFinite || v < 0) return null;
    return v;
  }
}

class MarketMakerConfigModel {
  final String configId;
  final String userId;
  final String pairId;
  final int spreadBps;
  final int spreadAlertThresholdBps;
  final String orderAmount;
  final bool isActive;
  final String? stopLossPct;
  final String? maxPositionBase;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MarketMakerConfigModel({
    required this.configId,
    required this.userId,
    required this.pairId,
    required this.spreadBps,
    required this.spreadAlertThresholdBps,
    required this.orderAmount,
    required this.isActive,
    required this.stopLossPct,
    required this.maxPositionBase,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MarketMakerConfigModel.fromJson(Map<String, dynamic> json) {
    return MarketMakerConfigModel(
      configId: (json['config_id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      pairId: (json['pair_id'] ?? '').toString(),
      spreadBps: (json['spread_bps'] as num?)?.toInt() ?? 0,
      spreadAlertThresholdBps:
          (json['spread_alert_threshold_bps'] as num?)?.toInt() ?? 0,
      orderAmount: (json['order_amount'] ?? '0').toString(),
      isActive: (json['is_active'] as bool?) ?? false,
      stopLossPct: json['stop_loss_pct']?.toString(),
      maxPositionBase: json['max_position_base']?.toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}
