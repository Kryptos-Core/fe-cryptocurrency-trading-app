import 'package:json_annotation/json_annotation.dart';
import 'package:crypto_trading_app/features/wallets/domain/entities/wallet_balance.dart';

part 'wallet_balance_model.g.dart';

/// Helper to convert dynamic to String (UUID) safely
String _toId(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  return value.toString();
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
/// JSON structure from API (UUID v7):
/// ```json
/// {
///   "userId": "018e9a7b-...",
///   "currencyId": "018e9a7b-...",
///   "available": "50.5",
///   "frozen": "10.25",
///   "total": "60.75"
/// }
/// ```
@JsonSerializable()
class WalletBalanceModel {
  /// User ID who owns this wallet (UUID v7)
  @JsonKey(name: 'userId', fromJson: _toId)
  final String userId;

  /// Currency ID (UUID v7)
  @JsonKey(name: 'currencyId', fromJson: _toId)
  final String currencyId;

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
