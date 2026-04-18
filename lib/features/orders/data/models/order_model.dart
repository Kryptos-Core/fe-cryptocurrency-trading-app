import 'package:crypto_trading_app/features/orders/domain/entities/order.dart';

String _toId(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  return v.toString();
}

String _toString(dynamic v) {
  if (v == null) return '0';
  return v.toString();
}

String? _toStringOrNull(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

DateTime _toDateTime(dynamic v) {
  if (v == null) return DateTime.now();
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
  return DateTime.now();
}

/// Order model (data layer) – map từ API response (snake_case); IDs là UUID v7
class OrderModel {
  final String orderId;
  final String userId;
  final String pairId;
  final String side;
  final String type;
  final String? price;
  final String amount;
  final String filledAmount;
  final String? avgPrice;
  final String status;
  final String timeInForce;
  final String reservedQuote;
  final String reservedBase;
  final String? clientOrderId;
  final String idempotencyKey;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.pairId,
    required this.side,
    required this.type,
    this.price,
    required this.amount,
    required this.filledAmount,
    this.avgPrice,
    required this.status,
    required this.timeInForce,
    required this.reservedQuote,
    required this.reservedBase,
    this.clientOrderId,
    required this.idempotencyKey,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: _toId(json['order_id']),
      userId: _toId(json['user_id']),
      pairId: _toId(json['pair_id']),
      side: _toString(json['side']),
      type: _toString(json['type']),
      price: _toStringOrNull(json['price']),
      amount: _toString(json['amount'] ?? '0'),
      filledAmount: _toString(json['filled_amount'] ?? '0'),
      avgPrice: _toStringOrNull(json['avg_price']),
      status: _toString(json['status'] ?? 'OPEN'),
      timeInForce: _toString(json['time_in_force'] ?? 'GTC'),
      reservedQuote: _toString(json['reserved_quote'] ?? '0'),
      reservedBase: _toString(json['reserved_base'] ?? '0'),
      clientOrderId: _toStringOrNull(json['client_order_id']),
      idempotencyKey: _toString(json['idempotency_key'] ?? ''),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  Order toDomain() {
    return Order(
      orderId: orderId,
      userId: userId,
      pairId: pairId,
      side: OrderSide.fromString(side),
      type: OrderType.fromString(type),
      price: price,
      amount: amount,
      filledAmount: filledAmount,
      avgPrice: avgPrice,
      status: OrderStatus.fromString(status),
      timeInForce: TimeInForce.fromString(timeInForce),
      reservedQuote: reservedQuote,
      reservedBase: reservedBase,
      clientOrderId: clientOrderId,
      idempotencyKey: idempotencyKey,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
