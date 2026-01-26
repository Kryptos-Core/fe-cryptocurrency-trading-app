// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_market_pair_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateMarketPairDto _$CreateMarketPairDtoFromJson(Map<String, dynamic> json) =>
    CreateMarketPairDto(
      baseCurrencyId: (json['baseCurrencyId'] as num).toInt(),
      quoteCurrencyId: (json['quoteCurrencyId'] as num).toInt(),
      symbol: json['symbol'] as String?,
      priceScale: (json['priceScale'] as num?)?.toInt(),
      amountScale: (json['amountScale'] as num?)?.toInt(),
      minOrderAmount: json['minOrderAmount'] as String?,
      makerFeeRate: (json['makerFeeRate'] as num?)?.toDouble(),
      takerFeeRate: (json['takerFeeRate'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$CreateMarketPairDtoToJson(
        CreateMarketPairDto instance) =>
    <String, dynamic>{
      'baseCurrencyId': instance.baseCurrencyId,
      'quoteCurrencyId': instance.quoteCurrencyId,
      'symbol': instance.symbol,
      'priceScale': instance.priceScale,
      'amountScale': instance.amountScale,
      'minOrderAmount': instance.minOrderAmount,
      'makerFeeRate': instance.makerFeeRate,
      'takerFeeRate': instance.takerFeeRate,
      'isActive': instance.isActive,
    };
