import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

/// Top-level handler required by firebase_messaging for background/terminated state.
/// Must be a top-level (non-async class) function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// FCM Service — manages Firebase Messaging setup and local notification display.
///
/// Responsibilities:
/// - Initialize Firebase
/// - Request notification permissions (iOS/Android 13+)
/// - Obtain and return device token for registration
/// - Show local notifications when app is in foreground (firebase_messaging doesn't show them)
/// - Handle notification tap (background/terminated) to pass data to the app
class FcmService {
  static final FcmService _instance = FcmService._();
  factory FcmService() => _instance;
  FcmService._();

  final _logger = Logger();
  final _localNotifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Call once in main() before runApp().
  /// Returns the FCM token or null if unsupported (e.g. Windows desktop).
  Future<String?> initialize({
    void Function(RemoteMessage message)? onMessageOpenedApp,
  }) async {
    if (_initialized) return FirebaseMessaging.instance.getToken();

    // Firebase is only supported on Android, iOS and Web — not Windows desktop
    if (!_isSupportedPlatform()) {
      _logger.w('FCM not supported on this platform');
      return null;
    }

    try {
      await Firebase.initializeApp();
    } catch (e, st) {
      _logger.w('Skip Firebase init in draft mode: $e');
      _logger.d(st.toString());
      return null;
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _initLocalNotifications();

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      _logger.w('FCM permission denied');
      return null;
    }

    // Foreground message display
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // App opened from notification (background)
    if (onMessageOpenedApp != null) {
      FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
    }

    _initialized = true;

    final token = await FirebaseMessaging.instance.getToken();
    _logger.i('FCM token: $token');
    return token;
  }

  Future<String?> getToken() async {
    if (!_isSupportedPlatform()) return null;
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteToken() async {
    if (!_isSupportedPlatform()) return;
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {}
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  bool _isSupportedPlatform() {
    if (kIsWeb) return true;
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(settings: initSettings);

    // Create Android notification channel
    const channel = AndroidNotificationChannel(
      'crypto_notifications',
      'Crypto Notifications',
      description: 'System notifications from the trading platform',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final notificationType = message.data['type']?.toString();

    // Build Android sound: use RawResourceAndroidNotificationSound pointing to the
    // raw resource in android/app/src/main/res/raw/<name> (NO extension).
    final androidDetails = AndroidNotificationDetails(
      'crypto_notifications',
      'Crypto Notifications',
      channelDescription: 'System notifications from the trading platform',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: _resolveAndroidSound(notificationType),
    );

    // Build iOS sound: must match a file in ios/Runner/Resources/ WITH extension.
    // Supported formats: .aiff (preferred), .wav, .caf.
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: _resolveIosSound(notificationType),
    );

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: message.data.isNotEmpty ? message.data['notification_id'] : null,
    );
  }

  /// Resolves the Android raw resource name from the notification type.
  /// Returns null to use the channel default sound.
  AndroidNotificationSound? _resolveAndroidSound(String? notificationType) {
    switch (notificationType) {
      case 'withdrawal_request':
        return const RawResourceAndroidNotificationSound('withdrawal_request');
      case 'withdrawal_approved':
        return const RawResourceAndroidNotificationSound('withdrawal_approved');
      case 'withdrawal_rejected':
        return const RawResourceAndroidNotificationSound('withdrawal_rejected');
      case 'alert':
        return const RawResourceAndroidNotificationSound('alert');
      case 'promo':
        return const RawResourceAndroidNotificationSound('promo');
      default:
        return null; // use channel default
    }
  }

  /// Resolves the iOS sound file name from the notification type.
  /// Must match a file in ios/Runner/Resources/ WITH extension.
  String _resolveIosSound(String? notificationType) {
    switch (notificationType) {
      case 'withdrawal_request':
        return 'withdrawal_request.aiff';
      case 'withdrawal_approved':
        return 'withdrawal_approved.aiff';
      case 'withdrawal_rejected':
        return 'withdrawal_rejected.aiff';
      case 'alert':
        return 'alert.aiff';
      case 'promo':
        return 'promo.aiff';
      default:
        return 'default';
    }
  }
}
