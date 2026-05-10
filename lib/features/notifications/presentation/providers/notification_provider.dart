import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/services/notification_sound_service.dart';
import 'package:crypto_trading_app/core/services/websocket_service.dart';
import 'package:crypto_trading_app/features/notifications/application/services/notifications_socket_service.dart';
import 'package:crypto_trading_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:crypto_trading_app/features/notifications/domain/repositories/notification_repository.dart';

/// Notification Provider
/// Observer Pattern: subscribes to WebSocket 'notification:new' events.
/// State: notifications list, unread badge count, loading flag.
class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;

  List<NotificationEntity> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<WebSocketMessage>? _socketSubscription;

  /// Subscription to the /notifications namespace socket for notification:new events
  StreamSubscription<NotificationsSocketMessage>? _notifSocketSubscription;
  /// Subscription to the /notifications namespace socket for payment_config:event events
  StreamSubscription<NotificationsSocketMessage>? _paymentConfigSubscription;
  /// Subscription to the /notifications namespace socket for treasury:event events
  StreamSubscription<NotificationsSocketMessage>? _treasurySubscription;

  /// External callback invoked when a payment_config:event arrives.
  void Function(Map<String, dynamic>)? _paymentConfigCallback;
  /// External callback invoked when a treasury:event arrives.
  void Function(Map<String, dynamic>)? _treasuryCallback;

  NotificationProvider({
    required NotificationRepository repository,
  }) : _repository = repository {
    NotificationSoundService.instance.initialize();
  }

  // ── Getters ────────────────────────────────────────────────────────────────

  List<NotificationEntity> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Initialization ─────────────────────────────────────────────────────────

  /// Fetch initial notifications + unread count.
  /// Also registers FCM token if [fcmToken] is provided.
  /// Call after user authenticates.
  Future<void> initialize({String? fcmToken}) async {
    if (fcmToken != null) {
      await _repository.registerFcmToken(fcmToken);
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    final results = await Future.wait([
      _repository.getNotifications(),
      _repository.getUnreadCount(),
    ]);

    results[0].fold(
      (f) => _error = f.message,
      (list) => _notifications = list as List<NotificationEntity>,
    );

    results[1].fold(
      (_) {},
      (count) => _unreadCount = count as int,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Subscribe to WebSocket stream for real-time 'notification:new' events.
  /// Tái sử dụng WebSocketService.messageStream — zero new sockets.
  void listenSocket(IWebSocketService wsService) {
    _socketSubscription?.cancel();
    _socketSubscription = wsService.messageStream
        .where((msg) => msg.type == 'notification:new')
        .listen(_onNewNotification);
  }

  void stopListening() {
    _socketSubscription?.cancel();
    _socketSubscription = null;
  }

  /// Listen to the /notifications Socket.IO namespace.
  /// Handles both notification:new and payment_config:event messages.
  void listenNotificationsSocket(NotificationsSocketService notifSocket) {
    _notifSocketSubscription?.cancel();
    _paymentConfigSubscription?.cancel();
    _treasurySubscription?.cancel();

    _notifSocketSubscription = notifSocket.messageStream
        .where((msg) => msg.type == 'notification:new')
        .listen((msg) {
      final notif = _buildFromSocketPayload(msg.data);
      if (notif == null) return;
      _notifications = [notif, ..._notifications];
      _unreadCount += 1;
      notifyListeners();

      // Play sound for this notification type
      NotificationSoundService.instance.playForNotificationType(notif.type.value);
    });

    _paymentConfigSubscription = notifSocket.messageStream
        .where((msg) => msg.type == 'payment_config:event')
        .listen((msg) {
      _paymentConfigCallback?.call(msg.data);
    });

    _treasurySubscription = notifSocket.messageStream
        .where((msg) => msg.type == 'treasury:event')
        .listen((msg) {
      _treasuryCallback?.call(msg.data);
    });
  }

  /// Register a callback to be invoked when a payment_config:event arrives.
  /// Called by MainScreen to forward events to PaymentConfigProvider.
  void addPaymentConfigEventListener(void Function(Map<String, dynamic>) callback) {
    _paymentConfigCallback = callback;
  }

  /// Register a callback to be invoked when a treasury:event arrives.
  void addTreasuryEventListener(void Function(Map<String, dynamic>) callback) {
    _treasuryCallback = callback;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> markRead(String notificationId) async {
    // Optimistic update
    _applyMarkRead(notificationId);

    final result = await _repository.markRead(notificationId);
    result.fold(
      (_) => _rollbackMarkRead(notificationId), // revert on failure
      (_) {},
    );
    notifyListeners();
  }

  Future<void> markAllRead() async {
    // Optimistic update
    final previous = List<NotificationEntity>.from(_notifications);
    final previousCount = _unreadCount;

    _notifications = _notifications
        .map((n) => n.isRead ? n : n.copyWith(isRead: true, readAt: DateTime.now()))
        .toList();
    _unreadCount = 0;
    notifyListeners();

    final result = await _repository.markAllRead();
    result.fold(
      (_) {
        _notifications = previous;
        _unreadCount = previousCount;
        notifyListeners();
      },
      (_) {},
    );
  }

  Future<void> loadMore({int page = 1}) async {
    final result = await _repository.getNotifications(page: page);
    result.fold(
      (_) {},
      (list) {
        if (page == 1) {
          _notifications = list;
        } else {
          _notifications = [..._notifications, ...list];
        }
        notifyListeners();
      },
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _onNewNotification(WebSocketMessage message) {
    final data = message.data;
    final notif = _buildFromSocketPayload(data);
    if (notif == null) return;

    _notifications = [notif, ..._notifications];
    _unreadCount += 1;
    notifyListeners();

    // Play sound for this notification type
    NotificationSoundService.instance.playForNotificationType(notif.type.value);
  }

  void _applyMarkRead(String notificationId) {
    _notifications = _notifications.map((n) {
      if (n.notificationId == notificationId && !n.isRead) {
        _unreadCount = (_unreadCount - 1).clamp(0, double.maxFinite.toInt());
        return n.copyWith(isRead: true, readAt: DateTime.now());
      }
      return n;
    }).toList();
    notifyListeners();
  }

  void _rollbackMarkRead(String notificationId) {
    _notifications = _notifications.map((n) {
      if (n.notificationId == notificationId && n.isRead) {
        _unreadCount += 1;
        return n.copyWith(isRead: false);
      }
      return n;
    }).toList();
  }

  NotificationEntity? _buildFromSocketPayload(Map<String, dynamic> data) {
    try {
      final notifId = data['notification_id']?.toString() ?? '';
      if (notifId.isEmpty) return null;
      return NotificationEntity(
        id: notifId,
        userId: '',
        notificationId: notifId,
        isRead: false,
        createdAt: DateTime.now(),
        title: data['title']?.toString() ?? '',
        body: data['body']?.toString() ?? '',
        type: NotificationTypeX.fromString(data['type']?.toString()),
        createdBy: '',
        data: data['data'] is Map ? Map<String, dynamic>.from(data['data'] as Map) : null,
        notificationCreatedAt: DateTime.tryParse(
              data['created_at']?.toString() ?? '',
            ) ??
            DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    stopListening();
    _notifSocketSubscription?.cancel();
    _paymentConfigSubscription?.cancel();
    _treasurySubscription?.cancel();
    super.dispose();
  }
}
