// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trade_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TradeModel _$TradeModelFromJson(Map<String, dynamic> json) => TradeModel(
      tradeId: (json['trade_id'] as num).toInt(),
      pairId: (json['pair_id'] as num).toInt(),
      price: json['price'] as String,
      amount: json['amount'] as String,
      side: json['side'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TradeModelToJson(TradeModel instance) =>
    <String, dynamic>{
      'trade_id': instance.tradeId,
      'pair_id': instance.pairId,
      'price': instance.price,
      'amount': instance.amount,
      'side': instance.side,
      'created_at': instance.createdAt.toIso8601String(),
    };
