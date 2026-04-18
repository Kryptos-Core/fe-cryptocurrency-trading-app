// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrencyModel _$CurrencyModelFromJson(Map<String, dynamic> json) =>
    CurrencyModel(
      currencyId: _nullSafeStringFromJson(json['currency_id']),
      symbol: _nullSafeStringFromJson(json['symbol']),
      name: _nullSafeStringFromJson(json['name']),
      precisionScale: _nullSafeIntFromJson(json['precision_scale']),
      minWithdraw: _nullSafeStringFromJson(json['min_withdraw']),
      isTradable: _nullSafeBoolFromJson(json['is_tradable']),
      isActive: _nullSafeBoolFromJson(json['is_active']),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      lastPrice: _nullableStringFromJson(json['lastPrice']),
      priceChangePercent24h:
          _nullableStringFromJson(json['priceChangePercent24h']),
      volume24h: _nullableStringFromJson(json['volume24h']),
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
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'lastPrice': instance.lastPrice,
      'priceChangePercent24h': instance.priceChangePercent24h,
      'volume24h': instance.volume24h,
    };
