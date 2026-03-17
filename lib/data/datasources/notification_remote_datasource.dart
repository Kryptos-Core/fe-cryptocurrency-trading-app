import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({int page, int limit});
  Future<int> getUnreadCount();
  Future<void> markRead(String notificationId);
  Future<void> markAllRead();
  Future<void> saveFcmToken(String? fcmToken);
  Future<void> broadcast({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  });
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient dioClient;

  NotificationRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.notifications,
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(NotificationModel.fromJson)
            .toList();
      }
      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map(NotificationModel.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? e.message ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await dioClient.dio.get(ApiConstants.notificationsUnreadCount);
      final data = response.data;
      if (data is Map) {
        return int.tryParse(
              (data['unread_count'] ?? data['data']?['unread_count'] ?? 0).toString(),
            ) ??
            0;
      }
      return 0;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> markRead(String notificationId) async {
    try {
      await dioClient.dio.patch(ApiConstants.notificationMarkRead(notificationId));
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> markAllRead() async {
    try {
      await dioClient.dio.patch(ApiConstants.notificationsReadAll);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> saveFcmToken(String? fcmToken) async {
    try {
      await dioClient.dio.patch(
        ApiConstants.usersMeFcmToken,
        data: {'fcm_token': fcmToken},
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> broadcast({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await dioClient.dio.post(
        ApiConstants.notifications,
        data: {
          'title': title,
          'body': body,
          'type': type,
          if (data != null && data.isNotEmpty) 'data': data,
        },
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
