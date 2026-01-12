import 'package:equatable/equatable.dart';

/// Wallet Entity - Domain Layer
class Wallet extends Equatable {
  final int walletId;
  final int userId;
  final int currencyId;
  final double available;
  final double frozen;
  final DateTime updatedAt;

  const Wallet({
    required this.walletId,
    required this.userId,
    required this.currencyId,
    this.available = 0.0,
    this.frozen = 0.0,
    required this.updatedAt,
  });

  /// Total balance (available + frozen)
  double get total => available + frozen;

  @override
  List<Object?> get props => [
        walletId,
        userId,
        currencyId,
        available,
        frozen,
        updatedAt,
      ];

  Wallet copyWith({
    int? walletId,
    int? userId,
    int? currencyId,
    double? available,
    double? frozen,
    DateTime? updatedAt,
  }) {
    return Wallet(
      walletId: walletId ?? this.walletId,
      userId: userId ?? this.userId,
      currencyId: currencyId ?? this.currencyId,
      available: available ?? this.available,
      frozen: frozen ?? this.frozen,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
