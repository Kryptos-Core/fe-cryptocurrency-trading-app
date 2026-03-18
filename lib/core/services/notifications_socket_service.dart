import 'dart:async';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Typed message from the /notifications WebSocket namespace.
class NotificationsSocketMessage {
  final String type; // 'notification:new' | 'payment_config:event' | etc.
  final Map<String, dynamic> data;
  final int timestamp;

  const NotificationsSocketMessage({
    required this.type,
    required this.data,
    required this.timestamp,
  });
}

/// Service responsible for the /notifications Socket.IO namespace connection.
///
/// Lifetime: singleton, connected after user authenticates and disconnected on logout.
/// Observer Pattern: exposes [messageStream] for consumers to filter by type.
class NotificationsSocketService {
  final Logger _logger = Logger();

  io.Socket? _socket;
  StreamController<NotificationsSocketMessage>? _controller;

  bool get isConnected => _socket?.connected ?? false;

  Stream<NotificationsSocketMessage> get messageStream =>
      _controller?.stream ?? const Stream.empty();

  /// Connect and authenticate with the /notifications namespace.
  Future<void> connect(String socketUrl, String token) async {
    if (isConnected) return;

    _controller ??= StreamController<NotificationsSocketMessage>.broadcast();

    _logger.i('NotificationsSocket: connecting to $socketUrl');

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(10000)
          .setReconnectionAttempts(10)
          .build(),
    );

    _socket!.onConnect((_) {
      _logger.i('NotificationsSocket: connected — authenticating');
      _socket!.emit('auth', {
        'type': 'auth',
        'data': {'token': token},
      });
    });

    _socket!.on('notification:new', (raw) {
      _emit('notification:new', raw);
    });

    _socket!.on('payment_config:event', (raw) {
      _emit('payment_config:event', raw);
    });

    _socket!.on('auth_response', (raw) {
      _logger.d('NotificationsSocket auth_response: $raw');
    });

    _socket!.onDisconnect((_) {
      _logger.w('NotificationsSocket: disconnected');
    });

    _socket!.onError((error) {
      _logger.e('NotificationsSocket error: $error');
    });

    _socket!.connect();
  }

  Future<void> disconnect() async {
    _socket?.disconnect();
    _socket = null;
    _logger.i('NotificationsSocket: disconnected');
  }

  void _emit(String type, dynamic raw) {
    final payload = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    final data = payload['data'] is Map
        ? Map<String, dynamic>.from(payload['data'] as Map)
        : payload;
    final ts = payload['timestamp'];
    _controller?.add(NotificationsSocketMessage(
      type: type,
      data: data,
      timestamp: ts is int ? ts : DateTime.now().millisecondsSinceEpoch,
    ));
  }

  void dispose() {
    disconnect();
    _controller?.close();
    _controller = null;
  }
}
