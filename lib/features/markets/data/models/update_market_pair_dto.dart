import 'package:json_annotation/json_annotation.dart';

part 'update_market_pair_dto.g.dart';

/// Update Market Pair DTO
/// Following Data Transfer Object Pattern
/// Used for updating existing market pairs via API
/// All fields are optional - only provided fields will be updated
@JsonSerializable()
class UpdateMarketPairDto {
  @JsonKey(name: 'priceScale')
  final int? priceScale;
  @JsonKey(name: 'amountScale')
  final int? amountScale;
  @JsonKey(name: 'minOrderAmount')
  final String? minOrderAmount;
  @JsonKey(name: 'makerFeeRate')
  final double? makerFeeRate;
  @JsonKey(name: 'takerFeeRate')
  final double? takerFeeRate;
  @JsonKey(name: 'isActive')
  final bool? isActive;

  const UpdateMarketPairDto({
    this.priceScale,
    this.amountScale,
    this.minOrderAmount,
    this.makerFeeRate,
    this.takerFeeRate,
    this.isActive,
  });

  /// Convert to JSON (only include non-null fields)
  Map<String, dynamic> toJson() {
    final json = _$UpdateMarketPairDtoToJson(this);
    // Remove null values
    json.removeWhere((key, value) => value == null);
    return json;
  }

  /// Create from JSON
  factory UpdateMarketPairDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateMarketPairDtoFromJson(json);
}
