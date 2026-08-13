import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../../app/di/injection_container.dart' as di;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/token_service.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/ai_assistant_repository.dart';
import '../services/ai_assistant_socket_service.dart';

/// State machine and stream consumer for the AI Assistant chat screen.
class AiAssistantProvider extends ChangeNotifier {
  final AiAssistantRepository repository;
  final AiAssistantSocketService socketService;

  AiAssistantProvider({
    required this.repository,
    required this.socketService,
  }) {
    _eventSubscription = socketService.eventStream.listen(_onEvent);
    _ensureSocketConnected();
  }

  Future<void> _ensureSocketConnected() async {
    if (socketService.isConnected) return;
    final tokenService = di.sl<TokenService>();
    final token = tokenService.getAccessToken();
    if (token == null || token.isEmpty) return;
    try {
      await socketService.connect(ApiConstants.aiAssistantSocketUrl, token);
      // Once authenticated, re-fetch status & conversations — the earlier
      // getStatus() / getConversations() may have failed during a backend
      // restart, leaving stale error banners in the UI.
      if (socketService.isAuthenticated) {
        _setError(null);
        await loadStatus();
        await loadConversations();
      }
    } catch (e) {
      debugPrint('AiAssistantProvider: failed to connect socket — $e');
    }
  }

  StreamSubscription<AiAssistantEvent>? _eventSubscription;

  // ── Conversations list ─────────────────────────────────────────────
  List<Conversation> _conversations = [];
  List<Conversation> get conversations => List.unmodifiable(_conversations);
  bool _loadingConversations = false;
  bool get isLoadingConversations => _loadingConversations;
  String? _conversationsError;
  String? get conversationsError => _conversationsError;

  // ── Active conversation ─────────────────────────────────────────────
  Conversation? _activeConversation;
  Conversation? get activeConversation => _activeConversation;

  List<Message> _messages = [];
  List<Message> get messages => List.unmodifiable(_messages);

  // ── Streaming state ────────────────────────────────────────────────
  String _streamingDelta = '';
  String get streamingDelta => _streamingDelta;
  bool _isStreaming = false;
  bool get isStreaming => _isStreaming;
  String? _streamingAssistantId;
  String? get streamingAssistantId => _streamingAssistantId;

  // ── Last error ─────────────────────────────────────────────────────
  String? _error;
  String? get error => _error;

  // ── Status ─────────────────────────────────────────────────────────
  AiAssistantStatus? _status;
  AiAssistantStatus? get status => _status;

  Future<void> loadConversations() async {
    _loadingConversations = true;
    _conversationsError = null;
    notifyListeners();
    try {
      final list = await repository.listConversations(page: 1, limit: 50);
      _conversations = list;
    } catch (e) {
      _conversationsError = e.toString();
    } finally {
      _loadingConversations = false;
      notifyListeners();
    }
  }

  Future<void> loadStatus() async {
    try {
      _status = await repository.getStatus();
      notifyListeners();
    } catch (_) {
      // status is optional; ignore failures
    }
  }

  Future<void> openConversation(String conversationId) async {
    _setError(null);
    _messages = [];
    _streamingDelta = '';
    _isStreaming = false;
    _streamingAssistantId = null;
    notifyListeners();
    try {
      final result = await repository.getConversation(conversationId);
      _activeConversation = result.conversation;
      _messages = result.messages;
    } catch (e) {
      _setError(e.toString());
    }
    notifyListeners();
  }

  Future<void> startNewConversation() async {
    _setError(null);
    _messages = [];
    _streamingDelta = '';
    _isStreaming = false;
    _streamingAssistantId = null;
    _activeConversation = null;
    notifyListeners();
  }

  /// Send a chat message. The provider routes through the socket service
  /// for streaming responses.
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    _setError(null);
    final userMessage = Message(
      messageId: 'local-${DateTime.now().microsecondsSinceEpoch}',
      conversationId: _activeConversation?.conversationId ?? '',
      role: MessageRole.user,
      content: content,
      model: null,
      tokensIn: 0,
      tokensOut: 0,
      toolCalls: null,
      contextRefs: null,
      parentMessageId: null,
      createdAt: DateTime.now(),
    );
    _messages = [..._messages, userMessage];
    _streamingDelta = '';
    _isStreaming = true;
    _streamingAssistantId = null;
    notifyListeners();
    // Make sure the socket is connected before emitting; if the user fired a
    // message immediately after navigating to the chat screen, the auto-connect
    // kicked off in the constructor may not have completed yet.
    if (!socketService.isConnected) {
      await _ensureSocketConnected();
    }
    socketService.sendMessage(
      conversationId: _activeConversation?.conversationId,
      content: content,
    );
  }

  void stopStream() {
    if (!_isStreaming) return;
    socketService.stopStream();
    _isStreaming = false;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    if (message != null) notifyListeners();
  }

  void _onEvent(AiAssistantEvent event) {
    if (event is AiChatStart) {
      _activeConversation = _activeConversation == null
          ? Conversation(
              conversationId: event.conversationId,
              userId: '',
              title: 'Cuộc hội thoại mới',
              intent: AiConversationIntent.general,
              lastMessageAt: DateTime.now(),
              messageCount: _messages.length,
              totalTokensIn: 0,
              totalTokensOut: 0,
              deletedAt: null,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
          : _activeConversation!.copyWith(
              conversationId: event.conversationId,
              lastMessageAt: DateTime.now(),
              messageCount: _messages.length,
            );
      notifyListeners();
    } else if (event is AiChatToken) {
      _streamingDelta = _streamingDelta + event.delta;
      notifyListeners();
    } else if (event is AiChatToolCall) {
      // Surface tool call as a transient system message bubble.
      final toolMessage = Message(
        messageId: 'tool-${DateTime.now().microsecondsSinceEpoch}',
        conversationId: _activeConversation?.conversationId ?? '',
        role: MessageRole.tool,
        content: '🔧 ${event.name}',
        model: null,
        tokensIn: 0,
        tokensOut: 0,
        toolCalls: null,
        contextRefs: null,
        parentMessageId: null,
        createdAt: DateTime.now(),
      );
      _messages = [..._messages, toolMessage];
      notifyListeners();
    } else if (event is AiChatDone) {
      if (_streamingDelta.isNotEmpty) {
        final assistantMessage = Message(
          messageId: event.assistantMessageId,
          conversationId: _activeConversation?.conversationId ?? '',
          role: MessageRole.assistant,
          content: _streamingDelta,
          model: event.model,
          tokensIn: event.tokensIn,
          tokensOut: event.tokensOut,
          toolCalls: null,
          contextRefs: null,
          parentMessageId: null,
          createdAt: DateTime.now(),
        );
        _messages = [..._messages, assistantMessage];
      }
      _streamingDelta = '';
      _isStreaming = false;
      _streamingAssistantId = event.assistantMessageId;
      // Refresh status to reflect token usage.
      loadStatus();
      notifyListeners();
    } else if (event is AiChatError) {
      _isStreaming = false;
      _streamingDelta = '';
      _setError('${event.code}: ${event.message}');
    } else if (event is AiChatAborted) {
      _isStreaming = false;
      _streamingDelta = '';
      notifyListeners();
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await repository.deleteConversation(conversationId);
      _conversations = _conversations
          .where((c) => c.conversationId != conversationId)
          .toList();
      if (_activeConversation?.conversationId == conversationId) {
        _activeConversation = null;
        _messages = [];
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
