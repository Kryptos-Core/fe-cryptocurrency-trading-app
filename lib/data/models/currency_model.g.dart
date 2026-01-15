// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrencyModel _$CurrencyModelFromJson(Map<String, dynamic> json) =>
    CurrencyModel(
      currencyId: (json['currency_id'] as num).toInt(),
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      precisionScale: (json['precision_scale'] as num).toInt(),
      minWithdraw: json['min_withdraw'] as String,
      isTradable: json['is_tradable'] as bool,
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$CurrencyModelToJson(CurrencyModel instance) =>
    <String, dynamic>{
      'currency_id': instance.currencyId,
      'symbol': instance.symbol,
      'name': instance.name,
      'precision_scale': instance.precisionScale,
      'min_withdraw': instance.minWithdraw,
      'is_tradable': instance.isTradable,
      'is_active': instance.isActive,
    };
