import 'package:json_annotation/json_annotation.dart';

part 'create_currency_dto.g.dart';

/// Create Currency DTO
/// Following Data Transfer Object Pattern
/// Used for creating new currencies via API
@JsonSerializable()
class CreateCurrencyDto {
  final String symbol; // Required, uppercase, 2-16 chars, pattern: ^[A-Z0-9]+$
  final String name; // Required, 1-64 chars
  @JsonKey(name: 'precisionScale')
  final int? precisionScale; // Optional, 0-18, default: 8
  @JsonKey(name: 'minWithdraw')
  final String? minWithdraw; // Optional, decimal string, default: "0"
  @JsonKey(name: 'isTradable')
  final bool? isTradable; // Optional, default: true
  @JsonKey(name: 'isActive')
  final bool? isActive; // Optional, default: true

  const CreateCurrencyDto({
    required this.symbol,
    required this.name,
    this.precisionScale,
    this.minWithdraw,
    this.isTradable,
    this.isActive,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$CreateCurrencyDtoToJson(this);

  /// Create from JSON
  factory CreateCurrencyDto.fromJson(Map<String, dynamic> json) =>
      _$CreateCurrencyDtoFromJson(json);
}
