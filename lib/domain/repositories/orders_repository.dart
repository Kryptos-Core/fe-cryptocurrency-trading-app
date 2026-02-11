import 'package:dartz/dartz.dart' hide Order;
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/order.dart';
import 'package:crypto_trading_app/domain/entities/order_book_level.dart';

/// Request DTO for creating an order (domain-agnostic shape)
class CreateOrderRequest {
  final int pairId;
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
/// BE quản lý state; FE gọi API và hiển thị kết quả.
abstract class OrdersRepository {
  /// Tạo lệnh. Idempotency qua idempotencyKey.
  Future<Either<Failure, Order>> createOrder(CreateOrderRequest request);

  /// Hủy lệnh (chỉ OPEN/PARTIAL).
  Future<Either<Failure, Order>> cancelOrder(int orderId);

  /// Order book theo pair + side (bid/ask levels).
  Future<Either<Failure, List<OrderBookLevel>>> getOrderBook(
    int pairId, {
    required String side,
    int limit = 50,
  });

  /// Danh sách lệnh của user (có phân trang, lọc status).
  Future<Either<Failure, MyOrdersResult>> getMyOrders({
    int page = 1,
    int limit = 20,
    String? status,
  });

  /// Chi tiết một lệnh (chỉ chủ lệnh).
  Future<Either<Failure, Order>> getOrderById(int orderId);
}
