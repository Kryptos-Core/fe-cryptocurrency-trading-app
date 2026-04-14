import 'package:dartz/dartz.dart' hide Order;
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/order.dart';
import 'package:crypto_trading_app/domain/entities/order_book_level.dart';

/// Request DTO for creating an order (domain-agnostic shape)
class CreateOrderRequest {
  final String pairId;
  final String side; // BUY | SELL
  final String type; // LIMIT | MARKET
  final String? price;
  final String amount;
  final String timeInForce; // GTC | IOC | FOK
  final String? clientOrderId;
  final String idempotencyKey;

  const CreateOrderRequest({
    required this.pairId,
    required this.side,
    required this.type,
    this.price,
    required this.amount,
    this.timeInForce = 'GTC',
    this.clientOrderId,
    required this.idempotencyKey,
  });
}

/// Paginated response for "my orders"
class MyOrdersResult {
  final List<Order> data;
  final int total;
  final int page;
  final int limit;

  const MyOrdersResult({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });
}

/// Repository interface for Orders API (Repository Pattern)
///
/// BE manages order state; FE calls API and renders results.
abstract class OrdersRepository {
  /// Create order. Idempotent via idempotencyKey.
  Future<Either<Failure, Order>> createOrder(CreateOrderRequest request);

  /// Cancel order (OPEN/PARTIAL only).
  Future<Either<Failure, Order>> cancelOrder(String orderId);

  /// Order book by pair + side (bid/ask levels).
  Future<Either<Failure, List<OrderBookLevel>>> getOrderBook(
    String pairId, {
    required String side,
    int limit = 50,
  });

  /// Current user orders with paging and optional status filter.
  Future<Either<Failure, MyOrdersResult>> getMyOrders({
    int page = 1,
    int limit = 20,
    String? status,
  });

  /// Single order detail (owner only).
  Future<Either<Failure, Order>> getOrderById(String orderId);
}
