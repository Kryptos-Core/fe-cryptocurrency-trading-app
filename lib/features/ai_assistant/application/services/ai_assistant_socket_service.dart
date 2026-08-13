import 'dart:async';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../domain/repositories/ai_assistant_repository.dart';

/// Manages the Socket.IO connection to the `/ai-assistant` namespace.
///
/// Lifecycle: singleton, connect on login, disconnect on logout.
/// Auth: JWT token forwarded in `socket.handshake.auth.token`.
class AiAssistantSocketService {
  final Logger _logger = Logger();

  io.Socket? _socket;
  StreamController<AiAssistantEvent>? _controller;
  bool _authenticated = false;

  bool get isConnected => _socket?.connected ?? false;
  bool get isAuthenticated => _authenticated;

  Stream<AiAssistantEvent> get eventStream =>
      _controller?.stream ?? const Stream.empty();

  /// Connect to the `/ai-assistant` namespace and authenticate.
  Future<void> connect(String socketUrl, String token) async {
    if (isConnected) return;
    _controller ??= StreamController<AiAssistantEvent>.broadcast();

    _logger.i('AiAssistantSocket: connecting to $socketUrl');

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(10000)
          .setReconnectionAttempts(10)
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      _logger.i('AiAssistantSocket: connected');
      _authenticated = false;
      _socket!.emit('auth', {
        'type': 'auth',
        'data': {'token': token},
      });
    });

    _socket!.on('auth_response', (raw) {
      final payload = raw is Map ? Map<String, dynamic>.from(raw as Map) : {};
      final data = payload['data'] is Map
          ? Map<String, dynamic>.from(payload['data'] as Map)
          : payload;
      if (data['success'] == true) {
        _authenticated = true;
        _logger.i('AiAssistantSocket: authenticated as ${data['user_id']}');
      } else {
        _logger.e('AiAssistantSocket: auth failed — ${data['message']}');
      }
    });

    _socket!.on('chat:start', (raw) => _emit(_parseChatStart(raw)));
    _socket!.on('chat:token', (raw) => _emit(_parseChatToken(raw)));
    _socket!.on('chat:tool_call', (raw) => _emit(_parseToolCall(raw)));
    _socket!.on('chat:tool_result', (raw) => _emit(_parseToolResult(raw)));
    _socket!.on('chat:done', (raw) => _emit(_parseChatDone(raw)));
    _socket!.on('chat:error', (raw) => _emit(_parseChatError(raw)));

    _socket!.onDisconnect((_) {
      _logger.w('AiAssistantSocket: disconnected');
      _authenticated = false;
    });

    _socket!.onError((err) {
      _logger.e('AiAssistantSocket error: $err');
    });

    _socket!.connect();
  }

  /// Send a chat message. Optionally pass `conversationId` to continue an existing conversation.
  void sendMessage({String? conversationId, required String content}) {
    if (!isConnected) {
      _logger.w('AiAssistantSocket: not connected, cannot send message');
      return;
    }
    _socket!.emit('chat:send', {
      'data': {
        if (conversationId != null) 'conversationId': conversationId,
        'content': content,
      },
    });
  }

  /// Abort the current streaming response.
  void stopStream() {
    if (!isConnected) return;
    _socket!.emit('chat:stop');
  }

  Future<void> disconnect() async {
    _socket?.disconnect();
    _socket = null;
    _authenticated = false;
    _logger.i('AiAssistantSocket: disconnected');
  }

  void dispose() {
    disconnect();
    _controller?.close();
    _controller = null;
  }

  void _emit(AiAssistantEvent event) {
    _controller?.add(event);
  }

  AiChatStart _parseChatStart(dynamic raw) {
    final payload = raw is Map ? Map<String, dynamic>.from(raw as Map) : {};
    final data = payload['data'] is Map
        ? Map<String, dynamic>.from(payload['data'] as Map)
        : payload;
    return AiChatStart(
      conversationId: data['conversationId']?.toString() ?? '',
      userMessageId: data['userMessageId']?.toString() ?? '',
    );
  }

  AiChatToken _parseChatToken(dynamic raw) {
    final delta = raw is Map
        ? (raw['delta']?.toString() ?? '')
        : (raw?.toString() ?? '');
    return AiChatToken(delta);
  }

  AiChatToolCall _parseToolCall(dynamic raw) {
    final payload = raw is Map ? Map<String, dynamic>.from(raw as Map) : {};
    final data = payload['data'] is Map
        ? Map<String, dynamic>.from(payload['data'] as Map)
        : payload;
    final args = data['args'] is Map
        ? Map<String, dynamic>.from(data['args'] as Map)
        : <String, dynamic>{};
    return AiChatToolCall(
      name: data['name']?.toString() ?? '',
      args: args,
    );
  }

  AiChatToolResult _parseToolResult(dynamic raw) {
    final payload = raw is Map ? Map<String, dynamic>.from(raw as Map) : {};
    final data = payload['data'] is Map
        ? Map<String, dynamic>.from(payload['data'] as Map)
        : payload;
    return AiChatToolResult(
      name: data['name']?.toString() ?? '',
      result: data['result'],
    );
  }

  AiChatDone _parseChatDone(dynamic raw) {
    final payload = raw is Map ? Map<String, dynamic>.from(raw as Map) : {};
    final data = payload['data'] is Map
        ? Map<String, dynamic>.from(payload['data'] as Map)
        : payload;
    return AiChatDone(
      assistantMessageId: data['assistantMessageId']?.toString() ?? '',
      tokensIn: int.tryParse(data['tokensIn']?.toString() ?? '0') ?? 0,
      tokensOut: int.tryParse(data['tokensOut']?.toString() ?? '0') ?? 0,
      model: data['model']?.toString() ?? '',
    );
  }

  AiChatError _parseChatError(dynamic raw) {
    final payload = raw is Map ? Map<String, dynamic>.from(raw as Map) : {};
    final data = payload['data'] is Map
        ? Map<String, dynamic>.from(payload['data'] as Map)
        : payload;
    return AiChatError(
      code: data['code']?.toString() ?? 'UNKNOWN',
      message: data['message']?.toString() ?? 'Unknown error',
    );
  }
}
