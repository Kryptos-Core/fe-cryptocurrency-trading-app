import 'package:json_annotation/json_annotation.dart';
import 'package:crypto_trading_app/domain/entities/wallet_balance.dart';

part 'wallet_balance_model.g.dart';

/// Helper to convert dynamic to int safely
int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// Helper to convert dynamic to String safely
String _toString(dynamic value) {
  if (value == null) return '0';
  return value.toString();
}

/// Data Transfer Object (DTO) for wallet balance from API
///
/// This model is used for JSON serialization/deserialization from the API response.
/// It maps to the domain entity WalletBalance via the toDomain() method.
///
/// JSON structure from API:
/// ```json
/// {
///   "userId": 1,
///   "currencyId": 1,
///   "available": "50.5",
///   "frozen": "10.25",
///   "total": "60.75"
/// }
/// ```
@JsonSerializable()
class WalletBalanceModel {
  /// User ID who owns this wallet
  @JsonKey(name: 'userId', fromJson: _toInt)
  final int userId;

  /// Currency ID (1=BTC, 2=ETH, etc.)
  @JsonKey(name: 'currencyId', fromJson: _toInt)
  final int currencyId;

  /// Available balance as decimal string
  @JsonKey(name: 'available', fromJson: _toString)
  final String available;

  /// Frozen balance as decimal string
  @JsonKey(name: 'frozen', fromJson: _toString)
  final String frozen;

  /// Total balance as decimal string (available + frozen)
  @JsonKey(name: 'total', fromJson: _toString)
  final String total;

  const WalletBalanceModel({
    required this.userId,
    required this.currencyId,
    required this.available,
    required this.frozen,
    required this.total,
  });

  /// Create from JSON (used by json_serializable)
  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) =>
      _$WalletBalanceModelFromJson(json);

  /// Convert to JSON (used by json_serializable)
  Map<String, dynamic> toJson() => _$WalletBalanceModelToJson(this);

  /// Convert DTO to domain entity
  ///
  /// This method transforms the data model from API into domain entity
  /// for use in business logic
  WalletBalance toDomain() {
    return WalletBalance(
      userId: userId,
      currencyId: currencyId,
      available: available,
      frozen: frozen,
      total: total,
    );
  }

  @override
  String toString() {
    return 'WalletBalanceModel(userId: $userId, currencyId: $currencyId, available: $available, frozen: $frozen, total: $total)';
  }
}
