import 'package:dartz/dartz.dart' hide Order;
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/features/orders/data/models/create_order_request_dto.dart';
import 'package:crypto_trading_app/features/orders/domain/entities/order.dart';
import 'package:crypto_trading_app/features/orders/domain/entities/order_book_level.dart';
import 'package:crypto_trading_app/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:crypto_trading_app/features/orders/domain/repositories/orders_repository.dart';

/// Orders repository implementation (Repository Pattern).
///
/// Maps exceptions from data layer to domain failures and converts request DTOs.
class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Order>> createOrder(CreateOrderRequest request) async {
    try {
      final dto = CreateOrderRequestDto(
        pairId: request.pairId,
        side: request.side,
        type: request.type,
        price: request.price,
        amount: request.amount,
        timeInForce: request.timeInForce,
        clientOrderId: request.clientOrderId,
        idempotencyKey: request.idempotencyKey,
      );
      final model = await remoteDataSource.createOrder(dto);
      return Right(model.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, code: e.code));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Order>> cancelOrder(String orderId) async {
    try {
      final model = await remoteDataSource.cancelOrder(orderId);
      return Right(model.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, code: e.code));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderBookLevel>>> getOrderBook(
    String pairId, {
    required String side,
    int limit = 50,
  }) async {
    try {
      final list = await remoteDataSource.getOrderBook(
        pairId,
        side: side,
        limit: limit,
      );
      return Right(list.map((e) => e.toDomain()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MyOrdersResult>> getMyOrders({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final result = await remoteDataSource.getMyOrders(
        page: page,
        limit: limit,
        status: status,
      );
      return Right(MyOrdersResult(
        data: result.data.map((e) => e.toDomain()).toList(),
        total: result.total,
        page: result.page,
        limit: result.limit,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Order>> getOrderById(String orderId) async {
    try {
      final model = await remoteDataSource.getOrderById(orderId);
      return Right(model.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
