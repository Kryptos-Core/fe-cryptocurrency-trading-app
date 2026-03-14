import 'package:json_annotation/json_annotation.dart';
import 'package:crypto_trading_app/domain/entities/currency.dart';

part 'currency_model.g.dart';

/// Backend may return null for numeric fields (e.g. after Binance sync); treat as 0.
int _nullSafeIntFromJson(Object? value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// Backend may return null for string fields; treat as empty string.
String _nullSafeStringFromJson(Object? value) {
  if (value == null) return '';
  if (value is String) return value;
  return value.toString();
}

String? _nullableStringFromJson(Object? value) {
  if (value == null) return null;
  if (value is String) {
    if (value.trim().isEmpty) return null;
    return value;
  }
  final parsed = value.toString();
  return parsed.trim().isEmpty ? null : parsed;
}

/// Backend may return null for bool; treat as false.
bool _nullSafeBoolFromJson(Object? value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}

/// Currency Model (DTO)
/// Following Clean Architecture - Data Layer
@JsonSerializable()
class CurrencyModel {
  @JsonKey(name: 'currency_id', fromJson: _nullSafeStringFromJson)
  final String currencyId;
  @JsonKey(fromJson: _nullSafeStringFromJson)
  final String symbol;
  @JsonKey(fromJson: _nullSafeStringFromJson)
  final String name;
  @JsonKey(name: 'precision_scale', fromJson: _nullSafeIntFromJson)
  final int precisionScale;
  @JsonKey(name: 'min_withdraw', fromJson: _nullSafeStringFromJson)
  final String minWithdraw;
  @JsonKey(name: 'is_tradable', fromJson: _nullSafeBoolFromJson)
  final bool isTradable;
  @JsonKey(name: 'is_active', fromJson: _nullSafeBoolFromJson)
  final bool isActive;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @JsonKey(name: 'lastPrice', fromJson: _nullableStringFromJson)
  final String? lastPrice;
  @JsonKey(name: 'priceChangePercent24h', fromJson: _nullableStringFromJson)
  final String? priceChangePercent24h;
  @JsonKey(name: 'volume24h', fromJson: _nullableStringFromJson)
  final String? volume24h;

  const CurrencyModel({
    required this.currencyId,
    required this.symbol,
    required this.name,
    required this.precisionScale,
    required this.minWithdraw,
    required this.isTradable,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.lastPrice,
    this.priceChangePercent24h,
    this.volume24h,
  });

  /// Convert from JSON
  factory CurrencyModel.fromJson(Map<String, dynamic> json) =>
      _$CurrencyModelFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$CurrencyModelToJson(this);

  /// Convert to Domain Entity
  Currency toEntity() {
    return Currency(
      currencyId: currencyId,
      symbol: symbol,
      name: name,
      precisionScale: precisionScale,
      minWithdraw: minWithdraw,
      isTradable: isTradable,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastPrice: lastPrice,
      priceChangePercent24h: priceChangePercent24h,
      volume24h: volume24h,
    );
  }

  /// Create from Domain Entity
  factory CurrencyModel.fromEntity(Currency entity) {
    return CurrencyModel(
      currencyId: entity.currencyId,
      symbol: entity.symbol,
      name: entity.name,
      precisionScale: entity.precisionScale,
      minWithdraw: entity.minWithdraw,
      isTradable: entity.isTradable,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastPrice: entity.lastPrice,
      priceChangePercent24h: entity.priceChangePercent24h,
      volume24h: entity.volume24h,
    );
  }
}
