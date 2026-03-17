import 'package:crypto_trading_app/domain/entities/notification_entity.dart';

/// Data model — handles JSON serialization from BE response.
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.notificationId,
    required super.isRead,
    super.readAt,
    required super.createdAt,
    required super.title,
    required super.body,
    required super.type,
    required super.createdBy,
    super.data,
    required super.notificationCreatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      notificationId: json['notification_id']?.toString() ?? '',
      isRead: (json['is_read'] == true || json['is_read'] == 1),
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'].toString()) : null,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: NotificationTypeX.fromString(json['type']?.toString()),
      createdBy: json['created_by']?.toString() ?? '',
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : null,
      notificationCreatedAt: DateTime.tryParse(
            json['notification_created_at']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }
}
