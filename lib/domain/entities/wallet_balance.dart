import 'package:equatable/equatable.dart';

/// Wallet balance entity representing user's available and frozen balance for a currency
///
/// This entity encapsulates the wallet balance model following the double-entry
/// accounting principle where:
/// - Available: Money that can be used (withdraw, trade, transfer)
/// - Frozen: Money locked for pending orders
/// - Total: Available + Frozen
class WalletBalance extends Equatable {
  /// User ID who owns this wallet (UUID v7)
  final String userId;

  /// Currency ID (UUID v7)
  final String currencyId;

  /// Available balance (can be used for transactions)
  /// Stored as string to avoid floating-point precision issues
  final String available;

  /// Frozen balance (locked for pending orders)
  /// Stored as string to avoid floating-point precision issues
  final String frozen;

  /// Total balance (available + frozen)
  /// Stored as string to avoid floating-point precision issues
  final String total;

  const WalletBalance({
    required this.userId,
    required this.currencyId,
    required this.available,
    required this.frozen,
    required this.total,
  });

  /// Create a copy of this wallet with some fields replaced
  WalletBalance copyWith({
    String? userId,
    String? currencyId,
    String? available,
    String? frozen,
    String? total,
  }) {
    return WalletBalance(
      userId: userId ?? this.userId,
      currencyId: currencyId ?? this.currencyId,
      available: available ?? this.available,
      frozen: frozen ?? this.frozen,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [userId, currencyId, available, frozen, total];

  @override
  String toString() {
    return 'WalletBalance(userId: $userId, currencyId: $currencyId, available: $available, frozen: $frozen, total: $total)';
  }
}
