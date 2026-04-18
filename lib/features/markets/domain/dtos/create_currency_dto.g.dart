// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_currency_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCurrencyDto _$CreateCurrencyDtoFromJson(Map<String, dynamic> json) =>
    CreateCurrencyDto(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      precisionScale: (json['precisionScale'] as num?)?.toInt(),
      minWithdraw: json['minWithdraw'] as String?,
      isTradable: json['isTradable'] as bool?,
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$CreateCurrencyDtoToJson(CreateCurrencyDto instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'name': instance.name,
      'precisionScale': instance.precisionScale,
      'minWithdraw': instance.minWithdraw,
      'isTradable': instance.isTradable,
      'isActive': instance.isActive,
    };
