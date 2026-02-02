// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletTransactionResponseModel _$WalletTransactionResponseModelFromJson(
        Map<String, dynamic> json) =>
    WalletTransactionResponseModel(
      transactionId: json['transactionId'] as String,
      userId: (json['userId'] as num).toInt(),
      currencyId: (json['currencyId'] as num).toInt(),
      action: json['action'] as String,
      amount: json['amount'] as String,
      refType: json['refType'] as String,
      refId: (json['refId'] as num).toInt(),
      newBalance: WalletBalanceModel.fromJson(
          json['newBalance'] as Map<String, dynamic>),
      timestamp: json['timestamp'] as String,
    );

Map<String, dynamic> _$WalletTransactionResponseModelToJson(
        WalletTransactionResponseModel instance) =>
    <String, dynamic>{
      'transactionId': instance.transactionId,
      'userId': instance.userId,
      'currencyId': instance.currencyId,
      'action': instance.action,
      'amount': instance.amount,
      'refType': instance.refType,
      'refId': instance.refId,
      'newBalance': instance.newBalance,
      'timestamp': instance.timestamp,
    };
