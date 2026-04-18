import 'package:json_annotation/json_annotation.dart';

part 'create_market_pair_dto.g.dart';

/// Create Market Pair DTO
/// Following Data Transfer Object Pattern
/// Used for creating new market pairs via API
@JsonSerializable()
class CreateMarketPairDto {
  @JsonKey(name: 'baseCurrencyId')
  final String baseCurrencyId; // Required (UUID v7)
  @JsonKey(name: 'quoteCurrencyId')
  final String quoteCurrencyId; // Required (UUID v7)
  final String? symbol; // Optional - auto-generated if not provided
  @JsonKey(name: 'priceScale')
  final int? priceScale; // Optional, default: 2
  @JsonKey(name: 'amountScale')
  final int? amountScale; // Optional, default: 6
  @JsonKey(name: 'minOrderAmount')
  final String? minOrderAmount; // Optional, default: "0.0001"
  @JsonKey(name: 'makerFeeRate')
  final double? makerFeeRate; // Optional, default: 0.001 (0.1%)
  @JsonKey(name: 'takerFeeRate')
  final double? takerFeeRate; // Optional, default: 0.001 (0.1%)
  @JsonKey(name: 'isActive')
  final bool? isActive; // Optional, default: true

  const CreateMarketPairDto({
    required this.baseCurrencyId,
    required this.quoteCurrencyId,
    this.symbol,
    this.priceScale,
    this.amountScale,
    this.minOrderAmount,
    this.makerFeeRate,
    this.takerFeeRate,
    this.isActive,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$CreateMarketPairDtoToJson(this);

  /// Create from JSON
  factory CreateMarketPairDto.fromJson(Map<String, dynamic> json) =>
      _$CreateMarketPairDtoFromJson(json);
}
