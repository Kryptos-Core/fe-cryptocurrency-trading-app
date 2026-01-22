import 'package:json_annotation/json_annotation.dart';

part 'update_currency_dto.g.dart';

/// Update Currency DTO
/// Following Data Transfer Object Pattern
/// Used for updating existing currencies via API
/// All fields are optional - only provided fields will be updated
@JsonSerializable()
class UpdateCurrencyDto {
  final String? symbol; // Optional, uppercase, 2-16 chars
  final String? name; // Optional, 1-64 chars
  @JsonKey(name: 'precisionScale')
  final int? precisionScale; // Optional, 0-18
  @JsonKey(name: 'minWithdraw')
  final String? minWithdraw; // Optional, decimal string
  @JsonKey(name: 'isTradable')
  final bool? isTradable; // Optional
  @JsonKey(name: 'isActive')
  final bool? isActive; // Optional

  const UpdateCurrencyDto({
    this.symbol,
    this.name,
    this.precisionScale,
    this.minWithdraw,
    this.isTradable,
    this.isActive,
  });

  /// Convert to JSON (only include non-null fields)
  Map<String, dynamic> toJson() {
    final json = _$UpdateCurrencyDtoToJson(this);
    // Remove null values
    json.removeWhere((key, value) => value == null);
    return json;
  }

  /// Create from JSON
  factory UpdateCurrencyDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateCurrencyDtoFromJson(json);
}
