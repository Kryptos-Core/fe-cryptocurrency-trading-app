import 'package:json_annotation/json_annotation.dart';
import 'package:crypto_trading_app/domain/entities/wallet.dart';
import 'package:crypto_trading_app/data/models/currency_model.dart';

part 'wallet_model.g.dart';

/// Wallet Model (DTO)
@JsonSerializable()
class WalletModel {
  @JsonKey(name: 'wallet_id')
  final int walletId;
  @JsonKey(name: 'user_id')
  final int userId;
  final CurrencyModel currency;
  final String available;
  final String frozen;
  final String total;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const WalletModel({
    required this.walletId,
    required this.userId,
    required this.currency,
    required this.available,
    required this.frozen,
    required this.total,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletModelToJson(this);

  Wallet toEntity() {
    return Wallet(
      walletId: walletId,
      userId: userId,
      currency: currency.toEntity(),
      available: available,
      frozen: frozen,
      total: total,
      updatedAt: updatedAt,
    );
  }
}

/// Wallet Ledger Model
@JsonSerializable()
class WalletLedgerModel {
  @JsonKey(name: 'ledger_id')
  final int ledgerId;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'currency_id')
  final int currencyId;
  @JsonKey(name: 'ref_type')
  final String refType;
  @JsonKey(name: 'ref_id')
  final int refId;
  final String direction;
  final String amount;
  @JsonKey(name: 'balance_after')
  final String balanceAfter;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const WalletLedgerModel({
    required this.ledgerId,
    required this.userId,
    required this.currencyId,
    required this.refType,
    required this.refId,
    required this.direction,
    required this.amount,
    required this.balanceAfter,
    required this.createdAt,
  });

  factory WalletLedgerModel.fromJson(Map<String, dynamic> json) =>
      _$WalletLedgerModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletLedgerModelToJson(this);

  WalletLedger toEntity() {
    return WalletLedger(
      ledgerId: ledgerId,
      userId: userId,
      currencyId: currencyId,
      refType: refType,
      refId: refId,
      direction: direction,
      amount: amount,
      balanceAfter: balanceAfter,
      createdAt: createdAt,
    );
  }
}
