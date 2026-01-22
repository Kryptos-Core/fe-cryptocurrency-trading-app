import 'package:json_annotation/json_annotation.dart';
import 'package:crypto_trading_app/domain/entities/currency.dart';

part 'currency_model.g.dart';

/// Currency Model (DTO)
/// Following Clean Architecture - Data Layer
@JsonSerializable()
class CurrencyModel {
  @JsonKey(name: 'currency_id')
  final int currencyId;
  final String symbol;
  final String name;
  @JsonKey(name: 'precision_scale')
  final int precisionScale;
  @JsonKey(name: 'min_withdraw')
  final String minWithdraw;
  @JsonKey(name: 'is_tradable')
  final bool isTradable;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

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
    );
  }
}
