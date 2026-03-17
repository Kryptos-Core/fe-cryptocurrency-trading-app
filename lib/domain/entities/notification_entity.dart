import 'package:equatable/equatable.dart';

/// Notification type matching backend ENUM('system','alert','promo')
enum NotificationType { system, alert, promo }

extension NotificationTypeX on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.system:
        return 'system';
      case NotificationType.alert:
        return 'alert';
      case NotificationType.promo:
        return 'promo';
    }
  }

  static NotificationType fromString(String? s) {
    switch (s) {
      case 'alert':
        return NotificationType.alert;
      case 'promo':
        return NotificationType.promo;
      default:
        return NotificationType.system;
    }
  }
}

/// Domain entity — pure Dart, no framework dependencies.
class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String notificationId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final String title;
  final String body;
  final NotificationType type;
  final String createdBy;
  final Map<String, dynamic>? data;
  final DateTime notificationCreatedAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.notificationId,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    required this.title,
    required this.body,
    required this.type,
    required this.createdBy,
    this.data,
    required this.notificationCreatedAt,
  });

  NotificationEntity copyWith({bool? isRead, DateTime? readAt}) {
    return NotificationEntity(
      id: id,
      userId: userId,
      notificationId: notificationId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
      title: title,
      body: body,
      type: type,
      createdBy: createdBy,
      data: data,
      notificationCreatedAt: notificationCreatedAt,
    );
  }

  @override
  List<Object?> get props => [id, notificationId, isRead];
}
