/// Server-driven defaults for empty MM config form (system_configs / env).
class MarketMakerFormDefaultsModel {
  final int spreadBps;
  final int spreadAlertThresholdBps;
  final String orderAmount;

  const MarketMakerFormDefaultsModel({
    required this.spreadBps,
    required this.spreadAlertThresholdBps,
    required this.orderAmount,
  });

  factory MarketMakerFormDefaultsModel.fromJson(Map<String, dynamic> json) {
    return MarketMakerFormDefaultsModel(
      spreadBps: (json['spread_bps'] as num?)?.toInt() ?? 10,
      spreadAlertThresholdBps:
          (json['spread_alert_threshold_bps'] as num?)?.toInt() ?? 20,
      orderAmount: json['order_amount']?.toString() ?? '0.001',
    );
  }
}
