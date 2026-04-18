// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_balance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletBalanceModel _$WalletBalanceModelFromJson(Map<String, dynamic> json) =>
    WalletBalanceModel(
      userId: _toId(json['userId']),
      currencyId: _toId(json['currencyId']),
      available: _toString(json['available']),
      frozen: _toString(json['frozen']),
      total: _toString(json['total']),
    );

Map<String, dynamic> _$WalletBalanceModelToJson(WalletBalanceModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'currencyId': instance.currencyId,
      'available': instance.available,
      'frozen': instance.frozen,
      'total': instance.total,
    };
