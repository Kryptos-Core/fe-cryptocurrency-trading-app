// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_market_pair_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateMarketPairDto _$UpdateMarketPairDtoFromJson(Map<String, dynamic> json) =>
    UpdateMarketPairDto(
      priceScale: (json['priceScale'] as num?)?.toInt(),
      amountScale: (json['amountScale'] as num?)?.toInt(),
      minOrderAmount: json['minOrderAmount'] as String?,
      makerFeeRate: (json['makerFeeRate'] as num?)?.toDouble(),
      takerFeeRate: (json['takerFeeRate'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$UpdateMarketPairDtoToJson(
        UpdateMarketPairDto instance) =>
    <String, dynamic>{
      'priceScale': instance.priceScale,
      'amountScale': instance.amountScale,
      'minOrderAmount': instance.minOrderAmount,
      'makerFeeRate': instance.makerFeeRate,
      'takerFeeRate': instance.takerFeeRate,
      'isActive': instance.isActive,
    };
