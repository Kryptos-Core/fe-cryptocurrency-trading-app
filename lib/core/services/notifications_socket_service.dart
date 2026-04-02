import 'dart:async';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Typed message from the /notifications WebSocket namespace.
class NotificationsSocketMessage {
  final String type; // 'notification:new' | 'payment_config:event' | 'treasury:event' | 'wallet:balance' | etc.
  final Map<String, dynamic> data;
  final int timestamp;

  const NotificationsSocketMessage({
    required this.type,
    required this.data,
    required this.timestamp,
  });
}

/// Real-time wallet balance update event.
class WalletBalanceEvent {
  final String currencyId;
  final String symbol;
  final String available;
  final String frozen;
  final String total;
  final int updatedAt;

  const WalletBalanceEvent({
    required this.currencyId,
    required this.symbol,
    required this.available,
    required this.frozen,
    required this.total,
    required this.updatedAt,
  });

  factory WalletBalanceEvent.fromJson(Map<String, dynamic> json) {
    return WalletBalanceEvent(
      currencyId: json['currencyId']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      available: json['available']?.toString() ?? '0',
      frozen: json['frozen']?.toString() ?? '0',
      total: json['total']?.toString() ?? '0',
      updatedAt: json['updatedAt'] is int
          ? json['updatedAt'] as int
          : DateTime.now().millisecondsSinceEpoch,
    );
  }
}

/// Service responsible for the /notifications Socket.IO namespace connection.
///
/// Lifetime: singleton, connected after user authenticates and disconnected on logout.
/// Observer Pattern: exposes [messageStream] for consumers to filter by type.
class NotificationsSocketService {
  final Logger _logger = Logger();

  io.Socket? _socket;
  StreamController<NotificationsSocketMessage>? _controller;
  StreamController<WalletBalanceEvent>? _walletBalanceController;

  bool get isConnected => _socket?.connected ?? false;

  Stream<NotificationsSocketMessage> get messageStream =>
      _controller?.stream ?? const Stream.empty();

  /// Stream of real-time wallet balance updates.
  Stream<WalletBalanceEvent> get walletBalanceStream =>
      _walletBalanceController?.stream ?? const Stream.empty();

  /// Connect and authenticate with the /notifications namespace.
  Future<void> connect(String socketUrl, String token) async {
    if (isConnected) return;

    _controller ??= StreamController<NotificationsSocketMessage>.broadcast();
    _walletBalanceController ??= StreamController<WalletBalanceEvent>.broadcast();

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

    _socket!.on('treasury:event', (raw) {
      _emit('treasury:event', raw);
    });

    _socket!.on('wallet:balance', (raw) {
      _emit('wallet:balance', raw);
      _emitWalletBalance(raw);
    });

    _socket!.on('system_config:updated', (raw) {
      _logger.i('SystemConfig updated via WebSocket');
      _emit('system_config:updated', raw);
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

  void _emitWalletBalance(dynamic raw) {
    try {
      final payload = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
      final data = payload['data'] is Map
          ? Map<String, dynamic>.from(payload['data'] as Map)
          : payload;
      final event = WalletBalanceEvent.fromJson(data);
      _walletBalanceController?.add(event);
      _logger.d('WalletBalance event: ${event.symbol} available=${event.available}');
    } catch (e) {
      _logger.e('Failed to parse wallet:balance event: $e');
    }
  }

  void dispose() {
    disconnect();
    _controller?.close();
    _controller = null;
    _walletBalanceController?.close();
    _walletBalanceController = null;
  }
}
