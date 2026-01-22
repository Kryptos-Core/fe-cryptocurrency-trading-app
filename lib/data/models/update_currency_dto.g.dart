// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_currency_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCurrencyDto _$UpdateCurrencyDtoFromJson(Map<String, dynamic> json) =>
    UpdateCurrencyDto(
      symbol: json['symbol'] as String?,
      name: json['name'] as String?,
      precisionScale: (json['precisionScale'] as num?)?.toInt(),
      minWithdraw: json['minWithdraw'] as String?,
      isTradable: json['isTradable'] as bool?,
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$UpdateCurrencyDtoToJson(UpdateCurrencyDto instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'name': instance.name,
      'precisionScale': instance.precisionScale,
      'minWithdraw': instance.minWithdraw,
      'isTradable': instance.isTradable,
      'isActive': instance.isActive,
    };
