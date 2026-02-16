import 'package:json_annotation/json_annotation.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';

part 'trade_model.g.dart';

/// Trade Model
/// Following Data Transfer Object Pattern
@JsonSerializable()
class TradeModel {
  @JsonKey(name: 'trade_id')
  final String tradeId;
  @JsonKey(name: 'pair_id')
  final String pairId;
  final String price;
  final String amount;
  final String side; // "BUY" or "SELL"
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const TradeModel({
    required this.tradeId,
    required this.pairId,
    required this.price,
    required this.amount,
    required this.side,
    required this.createdAt,
  });

  factory TradeModel.fromJson(Map<String, dynamic> json) =>
      _$TradeModelFromJson(json);

  Map<String, dynamic> toJson() => _$TradeModelToJson(this);

  Trade toEntity() {
    return Trade(
      tradeId: tradeId,
      pairId: pairId,
      price: price,
      amount: amount,
      side: TradeSide.fromString(side),
      createdAt: createdAt,
    );
  }
}
