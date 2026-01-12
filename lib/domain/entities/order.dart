import 'package:equatable/equatable.dart';

/// Order Entity - Domain Layer
class Order extends Equatable {
  final int orderId;
  final int userId;
  final int pairId;
  final OrderSide side;
  final OrderType type;
  final double? price; // null for market orders
  final double amount;
  final double filledAmount;
  final double? avgPrice;
  final OrderStatus status;
  final TimeInForce timeInForce;
  final double reservedQuote;
  final double reservedBase;
  final String? clientOrderId;
  final String idempotencyKey;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.orderId,
    required this.userId,
    required this.pairId,
    required this.side,
    required this.type,
    this.price,
    required this.amount,
    this.filledAmount = 0.0,
    this.avgPrice,
    this.status = OrderStatus.open,
    this.timeInForce = TimeInForce.gtc,
    this.reservedQuote = 0.0,
    this.reservedBase = 0.0,
    this.clientOrderId,
    required this.idempotencyKey,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if order is fully filled
  bool get isFilled => filledAmount >= amount;

  /// Check if order is partially filled
  bool get isPartiallyFilled => filledAmount > 0 && filledAmount < amount;

  /// Calculate remaining amount
  double get remainingAmount => amount - filledAmount;

  /// Calculate fill percentage
  double get fillPercentage => (filledAmount / amount) * 100;

  @override
  List<Object?> get props => [
        orderId,
        userId,
        pairId,
        side,
        type,
        price,
        amount,
        filledAmount,
        avgPrice,
        status,
        timeInForce,
        reservedQuote,
        reservedBase,
        clientOrderId,
        idempotencyKey,
        createdAt,
        updatedAt,
      ];

  Order copyWith({
    int? orderId,
    int? userId,
    int? pairId,
    OrderSide? side,
    OrderType? type,
    double? price,
    double? amount,
    double? filledAmount,
    double? avgPrice,
    OrderStatus? status,
    TimeInForce? timeInForce,
    double? reservedQuote,
    double? reservedBase,
    String? clientOrderId,
    String? idempotencyKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      pairId: pairId ?? this.pairId,
      side: side ?? this.side,
      type: type ?? this.type,
      price: price ?? this.price,
      amount: amount ?? this.amount,
      filledAmount: filledAmount ?? this.filledAmount,
      avgPrice: avgPrice ?? this.avgPrice,
      status: status ?? this.status,
      timeInForce: timeInForce ?? this.timeInForce,
      reservedQuote: reservedQuote ?? this.reservedQuote,
      reservedBase: reservedBase ?? this.reservedBase,
      clientOrderId: clientOrderId ?? this.clientOrderId,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum OrderSide {
  buy,
  sell,
}

enum OrderType {
  limit,
  market,
}

enum OrderStatus {
  open,
  partial,
  filled,
  cancelled,
  rejected,
}

enum TimeInForce {
  gtc, // Good Till Cancel
  ioc, // Immediate or Cancel
  fok, // Fill or Kill
}
