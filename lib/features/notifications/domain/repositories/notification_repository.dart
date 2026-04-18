import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/features/notifications/domain/entities/notification_entity.dart';

/// Abstract notification repository — Dependency Inversion Principle.
abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, int>> getUnreadCount();

  Future<Either<Failure, void>> markRead(String notificationId);

  Future<Either<Failure, void>> markAllRead();

  Future<Either<Failure, void>> registerFcmToken(String? fcmToken);

  Future<Either<Failure, void>> broadcastNotification({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  });
}
