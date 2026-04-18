import 'package:crypto_trading_app/features/markets/domain/entities/currency.dart';

/// Wallet entity representing user's cryptocurrency wallet
/// Following Clean Architecture - Domain Layer
class Wallet {
  final String walletId; // UUID v7
  final String userId;
  final Currency currency;
  final String available;
  final String frozen;
  final String total;
  final DateTime updatedAt;

  const Wallet({
    required this.walletId,
    required this.userId,
    required this.currency,
    required this.available,
    required this.frozen,
    required this.total,
    required this.updatedAt,
  });

  /// Check if wallet has any balance
  bool get hasBalance {
    final totalValue = double.tryParse(total) ?? 0;
    return totalValue > 0;
  }

  /// Check if wallet has available balance
  bool get hasAvailableBalance {
    final availableValue = double.tryParse(available) ?? 0;
    return availableValue > 0;
  }

  Wallet copyWith({
    String? walletId,
    String? userId,
    Currency? currency,
    String? available,
    String? frozen,
    String? total,
    DateTime? updatedAt,
  }) {
    return Wallet(
      walletId: walletId ?? this.walletId,
      userId: userId ?? this.userId,
      currency: currency ?? this.currency,
      available: available ?? this.available,
      frozen: frozen ?? this.frozen,
      total: total ?? this.total,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Wallet &&
          runtimeType == other.runtimeType &&
          walletId == other.walletId;

  @override
  int get hashCode => walletId.hashCode;

  @override
  String toString() {
    return 'Wallet(walletId: $walletId, currency: ${currency.symbol}, available: $available, total: $total)';
  }
}

/// Wallet Ledger entity representing transaction history
class WalletLedger {
  final String ledgerId; // UUID v7
  final String userId;
  final String currencyId;
  final String refType; // DEPOSIT, WITHDRAW, ORDER, TRADE, ADJUST, TRANSFER
  final String refId; // UUID v7
  final String direction; // CREDIT, DEBIT
  final String amount;
  final String balanceAfter;
  final DateTime createdAt;

  const WalletLedger({
    required this.ledgerId,
    required this.userId,
    required this.currencyId,
    required this.refType,
    required this.refId,
    required this.direction,
    required this.amount,
    required this.balanceAfter,
    required this.createdAt,
  });

  /// Check if transaction is credit (incoming)
  bool get isCredit => direction == 'CREDIT';

  /// Check if transaction is debit (outgoing)
  bool get isDebit => direction == 'DEBIT';

  WalletLedger copyWith({
    String? ledgerId,
    String? userId,
    String? currencyId,
    String? refType,
    String? refId,
    String? direction,
    String? amount,
    String? balanceAfter,
    DateTime? createdAt,
  }) {
    return WalletLedger(
      ledgerId: ledgerId ?? this.ledgerId,
      userId: userId ?? this.userId,
      currencyId: currencyId ?? this.currencyId,
      refType: refType ?? this.refType,
      refId: refId ?? this.refId,
      direction: direction ?? this.direction,
      amount: amount ?? this.amount,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletLedger &&
          runtimeType == other.runtimeType &&
          ledgerId == other.ledgerId;

  @override
  int get hashCode => ledgerId.hashCode;

  @override
  String toString() {
    return 'WalletLedger(ledgerId: $ledgerId, refType: $refType, direction: $direction, amount: $amount)';
  }
}
