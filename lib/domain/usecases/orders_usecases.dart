import 'package:dartz/dartz.dart' hide Order;
import 'package:equatable/equatable.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/core/usecases/usecase.dart';
import 'package:crypto_trading_app/domain/entities/order.dart';
import 'package:crypto_trading_app/domain/entities/order_book_level.dart';
import 'package:crypto_trading_app/domain/repositories/orders_repository.dart';

// ---------- Create Order ----------

class CreateOrderUseCase implements UseCase<Order, CreateOrderParams> {
  final OrdersRepository repository;

  CreateOrderUseCase({required this.repository});

  @override
  Future<Either<Failure, Order>> call(CreateOrderParams params) =>
      repository.createOrder(params.request);
}

class CreateOrderParams extends Equatable {
  final CreateOrderRequest request;

  const CreateOrderParams({required this.request});

  @override
  List<Object?> get props => [request];
}

// ---------- Cancel Order ----------

class CancelOrderUseCase implements UseCase<Order, CancelOrderParams> {
  final OrdersRepository repository;

  CancelOrderUseCase({required this.repository});

  @override
  Future<Either<Failure, Order>> call(CancelOrderParams params) =>
      repository.cancelOrder(params.orderId);
}

class CancelOrderParams extends Equatable {
  final int orderId;

  const CancelOrderParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

// ---------- Order Book ----------

class GetOrdersBookUseCase implements UseCase<List<OrderBookLevel>, GetOrdersBookParams> {
  final OrdersRepository repository;

  GetOrdersBookUseCase({required this.repository});

  @override
  Future<Either<Failure, List<OrderBookLevel>>> call(GetOrdersBookParams params) =>
      repository.getOrderBook(
        params.pairId,
        side: params.side,
        limit: params.limit,
      );
}

class GetOrdersBookParams extends Equatable {
  final int pairId;
  final String side;
  final int limit;

  const GetOrdersBookParams({
    required this.pairId,
    required this.side,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [pairId, side, limit];
}

// ---------- My Orders ----------

class GetMyOrdersUseCase implements UseCase<MyOrdersResult, GetMyOrdersParams> {
  final OrdersRepository repository;

  GetMyOrdersUseCase({required this.repository});

  @override
  Future<Either<Failure, MyOrdersResult>> call(GetMyOrdersParams params) =>
      repository.getMyOrders(
        page: params.page,
        limit: params.limit,
        status: params.status,
      );
}

class GetMyOrdersParams extends Equatable {
  final int page;
  final int limit;
  final String? status;

  const GetMyOrdersParams({
    this.page = 1,
    this.limit = 20,
    this.status,
  });

  @override
  List<Object?> get props => [page, limit, status];
}

// ---------- Order By Id ----------

class GetOrderByIdUseCase implements UseCase<Order, GetOrderByIdParams> {
  final OrdersRepository repository;

  GetOrderByIdUseCase({required this.repository});

  @override
  Future<Either<Failure, Order>> call(GetOrderByIdParams params) =>
      repository.getOrderById(params.orderId);
}

class GetOrderByIdParams extends Equatable {
  final int orderId;

  const GetOrderByIdParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}
