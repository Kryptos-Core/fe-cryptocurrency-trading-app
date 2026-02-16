import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/data/models/order_model.dart';
import 'package:crypto_trading_app/data/models/order_book_level_model.dart';
import 'package:crypto_trading_app/data/models/create_order_request_dto.dart';

/// Remote data source cho Orders API (Repository Pattern – data access)
///
/// Chỉ gọi HTTP, parse response, map lỗi BE (error_code/error_message) sang Exception.
abstract class OrdersRemoteDataSource {
  Future<OrderModel> createOrder(CreateOrderRequestDto dto);
  Future<OrderModel> cancelOrder(String orderId);
  Future<List<OrderBookLevelModel>> getOrderBook(
    String pairId, {
    required String side,
    int limit = 50,
  });
  Future<({List<OrderModel> data, int total, int page, int limit})> getMyOrders({
    int page = 1,
    int limit = 20,
    String? status,
  });
  Future<OrderModel> getOrderById(String orderId);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final DioClient dioClient;

  OrdersRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<OrderModel> createOrder(CreateOrderRequestDto dto) async {
    try {
      final response = await dioClient.dio.post(
        '/orders',
        data: dto.toJson(),
      );
      return _parseOrderResponse(response.data);
    } on DioException catch (e) {
      throw _mapDioToException(e);
    }
  }

  @override
  Future<OrderModel> cancelOrder(String orderId) async {
    try {
      final response = await dioClient.dio.post(
        '/orders/$orderId/cancel',
        data: <String, dynamic>{},
      );
      return _parseOrderResponse(response.data);
    } on DioException catch (e) {
      throw _mapDioToException(e);
    }
  }

  @override
  Future<List<OrderBookLevelModel>> getOrderBook(
    String pairId, {
    required String side,
    int limit = 50,
  }) async {
    try {
      final response = await dioClient.dio.get(
        '/orders/book/$pairId',
        queryParameters: {'side': side, 'limit': limit},
      );
      final list = response.data is List
          ? response.data as List
          : (response.data is Map && response.data['data'] != null)
              ? (response.data['data'] as List)
              : <dynamic>[];
      return list
          .map((e) =>
              OrderBookLevelModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw _mapDioToException(e);
    }
  }

  @override
  Future<({List<OrderModel> data, int total, int page, int limit})> getMyOrders({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty) query['status'] = status;
      final response = await dioClient.dio.get(
        '/orders/my',
        queryParameters: query,
      );
      final data = response.data is Map ? response.data as Map<String, dynamic> : null;
      final list = data?['data'] as List? ?? response.data as List? ?? [];
      final total = _toInt(data?['total']);
      final pageVal = _toInt(data?['page']) == 0 ? page : _toInt(data?['page']);
      final limitVal = _toInt(data?['limit']) == 0 ? limit : _toInt(data?['limit']);
      final orders = list
          .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return (data: orders, total: total, page: pageVal, limit: limitVal);
    } on DioException catch (e) {
      throw _mapDioToException(e);
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await dioClient.dio.get('/orders/$orderId');
      return _parseOrderResponse(response.data);
    } on DioException catch (e) {
      throw _mapDioToException(e);
    }
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  OrderModel _parseOrderResponse(dynamic data) {
    final map = data is Map
        ? (data['data'] != null ? data['data'] as Map<String, dynamic> : data as Map<String, dynamic>)
        : null;
    if (map == null) throw ServerException(message: 'Invalid order response');
    return OrderModel.fromJson(map);
  }

  Exception _mapDioToException(DioException e) {
    final statusCode = e.response?.statusCode;
    final body = e.response?.data;
    final message = _extractMessage(body);

    if (statusCode == 404) {
      return NotFoundException(message: message.isNotEmpty ? message : 'Order not found');
    }
    if (statusCode == 403) {
      return ValidationException(
        message: message.isNotEmpty ? message : 'Not your order',
      );
    }
    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      return ValidationException(message: message.isNotEmpty ? message : 'Request failed');
    }
    if (statusCode != null && statusCode >= 500) {
      return ServerException(message: message, statusCode: statusCode);
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return NetworkException(message: 'Connection timeout');
    }
    return ServerException(message: message.isNotEmpty ? message : e.message ?? 'Network error');
  }

  String _extractMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      final msg = body['error_message'] ?? body['message'] ?? body['error'];
      if (msg != null && msg.toString().trim().isNotEmpty) return msg.toString();
    }
    return '';
  }
}
