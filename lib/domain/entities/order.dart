import 'package:equatable/equatable.dart';

/// Order side: BUY or SELL
enum OrderSide {
  buy('BUY'),
  sell('SELL');

  const OrderSide(this.value);
  final String value;

  static OrderSide fromString(String s) {
    return OrderSide.values.firstWhere(
      (e) => e.value == s,
      orElse: () => OrderSide.buy,
    );
  }
}

/// Order type: LIMIT or MARKET
enum OrderType {
  limit('LIMIT'),
  market('MARKET');

  const OrderType(this.value);
  final String value;

  static OrderType fromString(String s) {
    return OrderType.values.firstWhere(
      (e) => e.value == s,
      orElse: () => OrderType.limit,
    );
  }
}

/// Order status (State Pattern: possible states)
enum OrderStatus {
  open('OPEN'),
  partial('PARTIAL'),
  filled('FILLED'),
  cancelled('CANCELLED'),
  rejected('REJECTED');

  const OrderStatus(this.value);
  final String value;

  static OrderStatus fromString(String s) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == s,
      orElse: () => OrderStatus.open,
    );
  }

  /// Chỉ OPEN, PARTIAL mới hủy được
  bool get isCancellable =>
      this == OrderStatus.open || this == OrderStatus.partial;

  /// Trạng thái kết thúc
  bool get isTerminal =>
      this == OrderStatus.filled ||
      this == OrderStatus.cancelled ||
      this == OrderStatus.rejected;
}

/// Time in force
enum TimeInForce {
  gtc('GTC'),
  ioc('IOC'),
  fok('FOK');

  const TimeInForce(this.value);
  final String value;

  static TimeInForce fromString(String s) {
    return TimeInForce.values.firstWhere(
      (e) => e.value == s,
      orElse: () => TimeInForce.gtc,
    );
  }
}

/// Order entity (domain)
///
/// BE quản lý state; FE chỉ hiển thị và gửi lệnh.
class Order extends Equatable {
  final int orderId;
  final int userId;
  final int pairId;
  final OrderSide side;
  final OrderType type;
  final String? price;
  final String amount;
  final String filledAmount;
  final String? avgPrice;
  final OrderStatus status;
  final TimeInForce timeInForce;
  final String reservedQuote;
  final String reservedBase;
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

  bool get isCancellable => status.isCancellable;

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
}
