import 'dart:async';
import 'dart:math';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// ============================================================================
/// WebSocket Service - Updated per Backend Specification
/// Protocol: Socket.io
/// Message Format: JSON with type, data, timestamp
/// Authentication: Bearer token in first auth message
/// Supported Events: auth, subscribe, ticker, ohlc, error, unsubscribe

// ============================================================================
// Message Models (as per BE spec)
// ============================================================================

/// Ticker data model - Real-time price updates (every 1 second)
class TickerData {
  final String pairId;
  final String symbol;
  final double lastPrice;
  final double bid;
  final double ask;
  final double volume24h;
  final double volume24hUsd;
  final double change24h;
  final double changePercent24h;
  final double high24h;
  final double low24h;
  final double open24h;
  final DateTime timestamp;

  TickerData({
    required this.pairId,
    required this.symbol,
    required this.lastPrice,
    required this.bid,
    required this.ask,
    required this.volume24h,
    required this.volume24hUsd,
    required this.change24h,
    required this.changePercent24h,
    required this.high24h,
    required this.low24h,
    required this.open24h,
    required this.timestamp,
  });

  factory TickerData.fromJson(Map<String, dynamic> json) {
    // Handle timestamp as milliseconds since epoch or ISO8601 string
    DateTime timestamp = DateTime.now();
    if (json['timestamp'] != null) {
      final ts = json['timestamp'];
      if (ts is int) {
        // Milliseconds since epoch
        timestamp = DateTime.fromMillisecondsSinceEpoch(ts);
      } else if (ts is String) {
        // ISO8601 string
        timestamp = DateTime.tryParse(ts) ?? DateTime.now();
      }
    }

    return TickerData(
      pairId: json['pair_id']?.toString() ?? '',
      symbol: json['symbol'] as String,
      lastPrice: double.parse(json['last_price'].toString()),
      bid: double.parse(json['bid'].toString()),
      ask: double.parse(json['ask'].toString()),
      volume24h: double.parse(json['volume_24h'].toString()),
      volume24hUsd: double.parse(json['volume_24h_usd'].toString()),
      change24h: double.parse(json['change_24h'].toString()),
      changePercent24h: double.parse(json['change_percent_24h'].toString()),
      high24h: double.parse(json['high_24h'].toString()),
      low24h: double.parse(json['low_24h'].toString()),
      open24h: double.parse(json['open_24h'].toString()),
      timestamp: timestamp,
    );
  }

  bool get isPriceUp => change24h >= 0;
  String get changeText =>
      '${isPriceUp ? "+" : ""}${changePercent24h.toStringAsFixed(2)}%';
}

/// OHLC Candle data model - Candlestick data
class OHLCData {
  final String pairId;
  final String interval;
  final int openTime;
  final int closeTime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final double quoteVolume;
  final int tradesCount;
  final bool isClosed;

  OHLCData({
    required this.pairId,
    required this.interval,
    required this.openTime,
    required this.closeTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.quoteVolume,
    required this.tradesCount,
    required this.isClosed,
  });

  factory OHLCData.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) => (v is int)
        ? v
        : (v is num)
            ? v.toInt()
            : int.tryParse(v?.toString() ?? '') ?? 0;
    // BE sends snake_case (open_time, close_time, quote_volume, trades_count, is_closed); support both
    final rawOpen = json['open_time'] ?? json['openTime'];
    final rawClose = json['close_time'] ?? json['closeTime'];
    int toMs(int t) =>
        t < 10000000000 ? t * 1000 : t; // seconds -> ms if Unix seconds
    final openTime = toMs(parseInt(rawOpen));
    final closeTime = toMs(parseInt(rawClose));
    return OHLCData(
      pairId: (json['pair_id'] ?? json['pairId'])?.toString() ?? '',
      interval: (json['interval'] as String?) ?? '1m',
      openTime: openTime,
      closeTime: closeTime,
      open: double.tryParse(json['open']?.toString() ?? '') ?? 0,
      high: double.tryParse(json['high']?.toString() ?? '') ?? 0,
      low: double.tryParse(json['low']?.toString() ?? '') ?? 0,
      close: double.tryParse(json['close']?.toString() ?? '') ?? 0,
      volume: double.tryParse(json['volume']?.toString() ?? '') ?? 0,
      quoteVolume: double.tryParse(
              (json['quote_volume'] ?? json['quoteVolume'])?.toString() ??
                  '') ??
          0,
      tradesCount: parseInt(json['trades_count'] ?? json['tradesCount']),
      isClosed: json['is_closed'] == true || json['isClosed'] == true,
    );
  }

  DateTime get openDateTime => DateTime.fromMillisecondsSinceEpoch(openTime);
  DateTime get closeDateTime => DateTime.fromMillisecondsSinceEpoch(closeTime);
}

/// WebSocket error model
class WebSocketErrorData {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  WebSocketErrorData({
    required this.code,
    required this.message,
    this.details,
  });

  factory WebSocketErrorData.fromJson(Map<String, dynamic> json) {
    return WebSocketErrorData(
      code: json['code'] as String,
      message: json['message'] as String,
      details: json['details'] as Map<String, dynamic>?,
    );
  }
}

/// Generic WebSocket message wrapper
class WebSocketMessage {
  final String type; // 'auth', 'subscribe', 'ticker', 'ohlc', 'error', etc
  final Map<String, dynamic> data;
  final DateTime timestamp;

  WebSocketMessage({
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'] as String? ?? 'unknown',
      data: json['data'] as Map<String, dynamic>? ?? {},
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'].toString())
          : DateTime.now(),
    );
  }
}

/// Workspace subscription model — mirrors BE WorkspaceSubscription
class WorkspaceSubscription {
  final String pairId;
  final List<String> channels;
  final String? interval;

  const WorkspaceSubscription({
    required this.pairId,
    required this.channels,
    this.interval,
  });

  factory WorkspaceSubscription.fromJson(Map<String, dynamic> json) {
    return WorkspaceSubscription(
      pairId: json['pair_id']?.toString() ?? '',
      channels: List<String>.from(json['channels'] as List? ?? []),
      interval: json['interval'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'pair_id': pairId,
        'channels': channels,
        if (interval != null) 'interval': interval,
      };
}

/// Workspace state model — mirrors BE WorkspaceState
class WorkspaceState {
  final String userId;
  final List<WorkspaceSubscription> pairs;
  final DateTime updatedAt;

  const WorkspaceState({
    required this.userId,
    required this.pairs,
    required this.updatedAt,
  });

  factory WorkspaceState.fromJson(Map<String, dynamic> json) {
    final pairsList = json['pairs'] as List? ?? [];
    return WorkspaceState(
      userId: json['user_id']?.toString() ?? '',
      pairs: pairsList
          .map((p) => WorkspaceSubscription.fromJson(p as Map<String, dynamic>))
          .toList(),
      updatedAt: json['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int)
          : DateTime.now(),
    );
  }
}

// ============================================================================
// WebSocket Service Interface & Implementation
// ============================================================================

/// WebSocket Service Interface - Strategy Pattern
abstract class IWebSocketService {
  Future<void> connect(String url, String token);
  Future<void> disconnect();
  void send(Map<String, dynamic> message);

  // Subscription methods
  void subscribeToPair(String pairId, List<String> channels,
      {String? interval});
  void unsubscribeFromPair(String pairId);

  // Dashboard room
  void joinDashboard();
  void leaveDashboard();

  // Getters
  bool get isConnected;

  /// Raw message stream — all events from socket
  Stream<WebSocketMessage> get messageStream;

  // ── Typed sub-streams (Observer/stream pipeline pattern) ──────────────────
  /// Stream of real-time ticker updates for subscribed pairs
  Stream<TickerData> get tickerStream;

  /// Stream of real-time OHLC candle updates for subscribed pairs
  Stream<OHLCData> get ohlcStream;

  /// Stream of batched dashboard ticker snapshots (throttled every 5s)
  Stream<List<TickerData>> get dashboardStream;

  /// Stream of workspace restore events from server after reconnect
  Stream<WorkspaceState> get workspaceRestoredStream;
}

/// WebSocket Service Implementation (Socket.IO)
class WebSocketService implements IWebSocketService {
  final Logger _logger = Logger();

  io.Socket? _socket;
  StreamController<WebSocketMessage>? _messageController;

  // Configuration
  static const Duration _maxReconnectDelay = Duration(seconds: 60);
  /// Grace period to wait for workspace_restored before falling back to manual re-subscribe.
  static const Duration _workspaceRestoreGrace = Duration(seconds: 3);

  // State
  String? _currentUrl;
  String? _currentToken;
  bool _isManuallyDisconnected = false;
  int _reconnectAttempts = 0;

  /// Last subscription issued by this client — used for fallback re-subscribe on reconnect.
  _PendingSubscription? _lastSubscription;

  /// Whether we already received workspace_restored for this connection (prevents duplicate subscribe).
  bool _workspaceRestored = false;

  @override
  bool get isConnected => _socket?.connected ?? false;

  @override
  Stream<WebSocketMessage> get messageStream =>
      _messageController?.stream ?? const Stream.empty();

  // ── Typed sub-streams ─────────────────────────────────────────────────────

  @override
  Stream<TickerData> get tickerStream => messageStream
      .where((m) => m.type == 'ticker')
      .map((m) => TickerData.fromJson(m.data));

  @override
  Stream<OHLCData> get ohlcStream => messageStream
      .where((m) => m.type == 'ohlc')
      .map((m) => OHLCData.fromJson(m.data));

  @override
  Stream<List<TickerData>> get dashboardStream => messageStream
      .where((m) => m.type == 'dashboard_tickers')
      .map((m) {
        final raw = m.data['data'];
        if (raw is List) {
          return raw
              .whereType<Map<String, dynamic>>()
              .map(TickerData.fromJson)
              .toList();
        }
        return <TickerData>[];
      });

  @override
  Stream<WorkspaceState> get workspaceRestoredStream => messageStream
      .where((m) => m.type == 'workspace_restored')
      .map((m) => WorkspaceState.fromJson(m.data));

  @override
  Future<void> connect(String url, String token) async {
    _currentUrl = url;
    _currentToken = token;
    _isManuallyDisconnected = false;

    try {
      _messageController ??= StreamController<WebSocketMessage>.broadcast();

      _logger.i('🔌 Connecting to Socket.IO: $url');

      // Connect to /trading namespace
      _socket = io.io(
        url,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .disableAutoConnect()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(5)
            .build(),
      );

      // Setup event listeners
      _socket!.onConnect((_) {
        _logger.i('✅ Socket.IO connected');
        _reconnectAttempts = 0; // Reset on successful connection

        // Authenticate immediately
        _authenticate();
      });

      _socket!.on('auth_response', (data) {
        _handleMessage(
          WebSocketMessage.fromJson({
            'type': 'auth_response',
            'data': data is Map ? data : {},
            'timestamp': DateTime.now().toIso8601String(),
          }),
        );
      });

      _socket!.on('ticker', (data) {
        final payloadData = _extractPayloadData(data);
        final payloadTimestamp = _extractPayloadTimestamp(data);
        _handleMessage(
          WebSocketMessage(
            type: 'ticker',
            data: payloadData,
            timestamp: payloadTimestamp ?? DateTime.now(),
          ),
        );
      });

      _socket!.on('ohlc', (data) {
        final payloadData = _extractPayloadData(data);
        final payloadTimestamp = _extractPayloadTimestamp(data);
        _handleMessage(
          WebSocketMessage(
            type: 'ohlc',
            data: payloadData,
            timestamp: payloadTimestamp ?? DateTime.now(),
          ),
        );
      });

      // Dashboard room: batch ticker updates every 5 seconds from server
      _socket!.on('dashboard_tickers', (data) {
        final payloadData = _extractPayloadData(data);
        final payloadTimestamp = _extractPayloadTimestamp(data);
        _handleMessage(
          WebSocketMessage(
            type: 'dashboard_tickers',
            data: payloadData,
            timestamp: payloadTimestamp ?? DateTime.now(),
          ),
        );
      });

      _socket!.on('subscribed', (data) {
        _handleMessage(
          WebSocketMessage.fromJson({
            'type': 'subscribed',
            'data': data is Map ? data : {},
            'timestamp': DateTime.now().toIso8601String(),
          }),
        );
      });

      _socket!.on('unsubscribed', (data) {
        _handleMessage(
          WebSocketMessage.fromJson({
            'type': 'unsubscribed',
            'data': data is Map ? data : {},
            'timestamp': DateTime.now().toIso8601String(),
          }),
        );
      });

      _socket!.on('workspace_restored', (data) {
        _workspaceRestored = true; // Suppress fallback re-subscribe
        final payloadData = _extractPayloadData(data);
        final payloadTimestamp = _extractPayloadTimestamp(data);
        _handleMessage(
          WebSocketMessage(
            type: 'workspace_restored',
            data: payloadData,
            timestamp: payloadTimestamp ?? DateTime.now(),
          ),
        );
      });

      _socket!.on('error', (data) {
        _handleMessage(
          WebSocketMessage.fromJson({
            'type': 'error',
            'data': data is Map ? data : {'message': data},
            'timestamp': DateTime.now().toIso8601String(),
          }),
        );
      });

      _socket!.onDisconnect((_) {
        _logger.w('⚠️ Socket.IO disconnected');
        if (!_isManuallyDisconnected &&
            _currentUrl != null &&
            _currentToken != null) {
          _attemptReconnect();
        }
      });

      _socket!.onError((error) {
        _logger.e('❌ Socket.IO error: $error');
        _handleError(error);
      });

      // Connect to the server
      _socket!.connect();

      _logger.i('✅ Socket.IO connection initiated');
    } catch (e) {
      _logger.e('❌ Connection error: $e');
      _attemptReconnect();
    }
  }

  @override
  Future<void> disconnect() async {
    _isManuallyDisconnected = true;

    try {
      _socket?.disconnect();
      // Don't close the stream - it's a broadcast stream that will be reused
      // when connecting again. Closing it prevents any future events from being
      // added, even if we reconnect.
      // await _messageController?.close();
      _logger.i('✅ Socket.IO disconnected');
    } catch (e) {
      _logger.e('❌ Error disconnecting: $e');
    }
  }

  // =========================================================================
  // Message Handling
  // =========================================================================

  Map<String, dynamic> _extractPayloadData(dynamic payload) {
    if (payload is Map && payload['data'] is Map) {
      return Map<String, dynamic>.from(payload['data'] as Map);
    }
    if (payload is Map) {
      return Map<String, dynamic>.from(payload);
    }
    return <String, dynamic>{};
  }

  DateTime? _extractPayloadTimestamp(dynamic payload) {
    if (payload is Map && payload['timestamp'] != null) {
      final ts = payload['timestamp'];
      if (ts is int) {
        return DateTime.fromMillisecondsSinceEpoch(ts);
      }
      if (ts is String) {
        return DateTime.tryParse(ts);
      }
    }
    return null;
  }

  void _handleMessage(WebSocketMessage message) {
    try {
      _messageController?.add(message);
    } catch (e) {
      _logger.e('Error handling message: $e');
    }
  }

  void _handleError(dynamic error) {
    _logger.e('❌ Socket.IO error: $error');
    _messageController?.addError(error);
  }

  // =========================================================================
  // Authentication (per BE spec: emit 'auth' event with type and data)
  // =========================================================================

  void _authenticate() {
    if (_currentToken == null) {
      _logger.e('❌ No token provided for authentication');
      return;
    }

    _workspaceRestored = false;

    final authMessage = {
      'type': 'auth',
      'data': {
        'token': _currentToken, // Just the token, no "Bearer" prefix
      },
    };

    _logger.d('📤 Emitting auth message...');
    _socket?.emit('auth', authMessage);

    // After auth: listen for workspace_restored with a grace period.
    // If server sends it, no manual re-subscribe needed.
    // Otherwise, fall back to re-subscribing the last pair.
    _scheduleWorkspaceFallback();
  }

  /// Waits [_workspaceRestoreGrace] for a workspace_restored event from the server.
  /// If it doesn't arrive, re-subscribes the last known pair manually.
  void _scheduleWorkspaceFallback() {
    Future.delayed(_workspaceRestoreGrace, () {
      if (_workspaceRestored) return; // Server handled restore — nothing to do
      final sub = _lastSubscription;
      if (sub == null || !isConnected) return;
      _logger.i('📤 No workspace_restored received — fallback re-subscribe: ${sub.pairId}');
      _socket?.emit('subscribe', {
        'type': 'subscribe',
        'data': {
          'pair_id': sub.pairId,
          'channels': sub.channels,
          if (sub.interval != null) 'interval': sub.interval,
        },
      });
    });
  }

  // =========================================================================
  // Subscription Methods (per BE spec)
  // =========================================================================

  @override
  void subscribeToPair(String pairId, List<String> channels,
      {String? interval}) {
    // Track last subscription for fallback restore after reconnect
    _lastSubscription = _PendingSubscription(
      pairId: pairId,
      channels: channels,
      interval: interval,
    );

    if (!isConnected) {
      _logger.w('⚠️ Not connected, cannot subscribe to pair $pairId');
      return;
    }

    final subscribeMessage = {
      'type': 'subscribe',
      'data': {
        'pair_id': pairId,
        'channels': channels,
        if (interval != null) 'interval': interval,
      },
    };

    _logger
        .i('📤 Emitting subscribe for pair $pairId with channels: $channels');
    _socket?.emit('subscribe', subscribeMessage);
  }

  @override
  void unsubscribeFromPair(String pairId) {
    if (!isConnected) {
      _logger.w('⚠️ Not connected, cannot unsubscribe from pair $pairId');
      return;
    }

    final unsubscribeMessage = {
      'type': 'unsubscribe',
      'data': {
        'pair_id': pairId,
      },
    };

    _logger.i('📤 Emitting unsubscribe for pair $pairId');
    _socket?.emit('unsubscribe', unsubscribeMessage);
  }

  // =========================================================================
  // Message Sending (legacy - use socket.emit() for Socket.IO)
  // =========================================================================

  @override
  void send(Map<String, dynamic> message) {
    try {
      final type = message['type'] ?? 'message';
      _logger.d('📤 Sending via emit: $type');
      _socket?.emit(type, message);
    } catch (e) {
      _logger.e('Error sending message: $e');
    }
  }

  // =========================================================================
  // Reconnection Logic (Socket.IO handles this automatically)
  // =========================================================================

  void _attemptReconnect() {
    if (_isManuallyDisconnected ||
        _currentUrl == null ||
        _currentToken == null) {
      return;
    }

    _reconnectAttempts++;
    final delaySeconds = min(
      5 * (1 << _reconnectAttempts),
      _maxReconnectDelay.inSeconds,
    );

    _logger
        .i('🔄 Reconnecting in ${delaySeconds}s (attempt $_reconnectAttempts)');

    // Socket.IO handles reconnection automatically, but we can trigger a fresh connection
    Future.delayed(Duration(seconds: delaySeconds), () {
      if (!_isManuallyDisconnected) {
        connect(_currentUrl!, _currentToken!);
      }
    });
  }

  // =========================================================================
  // Dashboard Room (Observer: server pushes batch tickers every 5s)
  // =========================================================================

  @override
  void joinDashboard() {
    if (!isConnected) {
      _logger.w('⚠️ Not connected, cannot join dashboard room');
      return;
    }
    _socket?.emit('join_dashboard', {'type': 'join_dashboard'});
    _logger.i('📊 Joined dashboard room');
  }

  @override
  void leaveDashboard() {
    if (!isConnected) return;
    _socket?.emit('leave_dashboard', {'type': 'leave_dashboard'});
    _logger.i('📊 Left dashboard room');
  }

  // =========================================================================
  // Cleanup
  // =========================================================================

  void dispose() {
    disconnect();
  }
}

/// Internal value object — last subscription issued by this client.
class _PendingSubscription {
  final String pairId;
  final List<String> channels;
  final String? interval;

  const _PendingSubscription({
    required this.pairId,
    required this.channels,
    this.interval,
  });
}
