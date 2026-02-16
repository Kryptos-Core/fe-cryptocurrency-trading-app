// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletModel _$WalletModelFromJson(Map<String, dynamic> json) => WalletModel(
      walletId: json['wallet_id'] as String,
      userId: json['user_id'] as String,
      currency:
          CurrencyModel.fromJson(json['currency'] as Map<String, dynamic>),
      available: json['available'] as String,
      frozen: json['frozen'] as String,
      total: json['total'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$WalletModelToJson(WalletModel instance) =>
    <String, dynamic>{
      'wallet_id': instance.walletId,
      'user_id': instance.userId,
      'currency': instance.currency,
      'available': instance.available,
      'frozen': instance.frozen,
      'total': instance.total,
      'updated_at': instance.updatedAt.toIso8601String(),
    };

WalletLedgerModel _$WalletLedgerModelFromJson(Map<String, dynamic> json) =>
    WalletLedgerModel(
      ledgerId: json['ledger_id'] as String,
      userId: json['user_id'] as String,
      currencyId: json['currency_id'] as String,
      refType: json['ref_type'] as String,
      refId: json['ref_id'] as String,
      direction: json['direction'] as String,
      amount: json['amount'] as String,
      balanceAfter: json['balance_after'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$WalletLedgerModelToJson(WalletLedgerModel instance) =>
    <String, dynamic>{
      'ledger_id': instance.ledgerId,
      'user_id': instance.userId,
      'currency_id': instance.currencyId,
      'ref_type': instance.refType,
      'ref_id': instance.refId,
      'direction': instance.direction,
      'amount': instance.amount,
      'balance_after': instance.balanceAfter,
      'created_at': instance.createdAt.toIso8601String(),
    };
