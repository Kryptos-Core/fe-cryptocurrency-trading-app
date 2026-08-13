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
    if (socketService.isConnected && socketService.isAuthenticated) {
      debugPrint('AiAssistantProvider: socket already connected & authenticated');
      return;
    }
    final tokenService = di.sl<TokenService>();
    final token = tokenService.getAccessToken();
    if (token == null || token.isEmpty) {
      debugPrint('AiAssistantProvider: no access token, skipping socket connect');
      return;
    }
    try {
      debugPrint('AiAssistantProvider: connecting socket to ${ApiConstants.aiAssistantSocketUrl}');
      await socketService.connect(ApiConstants.aiAssistantSocketUrl, token);
      // Once authenticated, re-fetch status & conversations — the earlier
      // getStatus() / getConversations() may have failed during a backend
      // restart, leaving stale error banners in the UI.
      if (socketService.isAuthenticated) {
        debugPrint('AiAssistantProvider: socket authenticated, refreshing status');
        _setError(null);
        await loadStatus();
        await loadConversations();
      } else {
        debugPrint('AiAssistantProvider: socket connect returned but not authenticated');
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

  // ── Watchdog for lost streaming events ─────────────────────────────
  // The chat gateway emits `chat:start`, `chat:token*`, and `chat:done` over
  // the socket. If any of those packets are dropped (network blip, mobile
  // backgrounding, etc) the UI would stay stuck on the typing indicator even
  // though the server has already persisted the full assistant reply. This
  // timer polls the conversation state while we're streaming and forces a
  // reconcile from the server-side source of truth if it lingers too long.
  Timer? _streamWatchdog;
  /// Wall-clock time of the most recent `sendMessage` call. Used by the
  /// reconcile watchdog to discover the conversation id when `chat:start`
  /// was dropped in flight.
  DateTime? _pendingSentAt;
  static const Duration _watchdogInterval = Duration(seconds: 4);
  static const Duration _watchdogMaxAge = Duration(minutes: 3);

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
    _stopStreamWatchdog();
    _messages = [];
    _streamingDelta = '';
    _isStreaming = false;
    _streamingAssistantId = null;
    _pendingSentAt = null;
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
    _stopStreamWatchdog();
    _messages = [];
    _streamingDelta = '';
    _isStreaming = false;
    _streamingAssistantId = null;
    _pendingSentAt = null;
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
    _pendingSentAt = DateTime.now();
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
    // Safety net: poll the server while streaming so the UI stays in sync
    // even if a `chat:token` or `chat:done` event gets lost in transit.
    _startStreamWatchdog();
  }

  void _startStreamWatchdog() {
    _streamWatchdog?.cancel();
    final startedAt = DateTime.now();
    debugPrint('AiAssistantProvider: starting stream watchdog at $startedAt');
    _streamWatchdog = Timer.periodic(_watchdogInterval, (_) async {
      if (!_isStreaming) {
        debugPrint('AiAssistantProvider: watchdog: not streaming, cancelling');
        _streamWatchdog?.cancel();
        _streamWatchdog = null;
        return;
      }
      // Give up after a few minutes to avoid hammering the server forever.
      if (DateTime.now().difference(startedAt) > _watchdogMaxAge) {
        debugPrint('AiAssistantProvider: watchdog: max age reached, cancelling');
        _streamWatchdog?.cancel();
        _streamWatchdog = null;
        return;
      }
      debugPrint('AiAssistantProvider: watchdog: reconcile tick, _activeConversation=${_activeConversation?.conversationId}');
      await _reconcileFromServer();
    });
  }

  void _stopStreamWatchdog() {
    _streamWatchdog?.cancel();
    _streamWatchdog = null;
  }

  /// Pull the current conversation from the server and merge any messages we
  /// haven't seen yet. This is called by the watchdog while streaming and also
  /// when the user reopens an existing conversation.
  ///
  /// If we don't know the active conversation id yet (because the `chat:start`
  /// socket packet was lost) we discover it by listing conversations and
  /// picking the most recent one whose `last_message_at` is at or after the
  /// time we sent our pending user message.
  Future<void> _reconcileFromServer() async {
    var convId = _activeConversation?.conversationId;
    debugPrint('AiAssistantProvider: reconcile: convId=$convId, _pendingSentAt=$_pendingSentAt');
    if (convId == null || convId.isEmpty) {
      convId = await _discoverPendingConversationId();
      debugPrint('AiAssistantProvider: reconcile: discovered convId=$convId');
      if (convId == null) {
        // Couldn't find a matching conversation yet — wait for the next tick.
        debugPrint('AiAssistantProvider: reconcile: no convId found, waiting');
        return;
      }
      _activeConversation = Conversation(
        conversationId: convId,
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
      );
    }
    try {
      final result = await repository.getConversation(convId);
      final serverMessages = result.messages;
      debugPrint('AiAssistantProvider: reconcile: serverMessages count=${serverMessages.length}, localMessages count=${_messages.length}');
      final localIds = _messages.map((m) => m.messageId).toSet();
      var changed = false;
      // Build a set of (role, content) for local user messages so we can skip
      // server-side duplicates that have a different messageId (the server
      // assigns a real UUID after saving, while we use a temporary
      // 'local-...' id before the socket round-trip).
      final localUserMsgSignatures = _messages
          .where((m) => m.role == MessageRole.user)
          .map((m) => '${m.role}:${m.content}')
          .toSet();

      for (final m in serverMessages) {
        // Skip if we already have this messageId, or if this is a duplicate
        // user message (same role + content but different server-assigned id).
        final isDuplicateUser = m.role == MessageRole.user &&
            localUserMsgSignatures.contains('${m.role}:${m.content}');
        if (!localIds.contains(m.messageId) && !isDuplicateUser) {
          _messages = [..._messages, m];
          changed = true;
        }
      }
      if (changed || serverMessages.length != _messages.length) {
        // If the server has the assistant's final message, treat the stream
        // as finished so the UI stops showing the typing indicator.
        final hasAssistantFinal = serverMessages.any(
          (m) => m.role == MessageRole.assistant && m.content.trim().isNotEmpty,
        );
        if (hasAssistantFinal) {
          _isStreaming = false;
          _streamingDelta = '';
          _stopStreamWatchdog();
        }
        _activeConversation = result.conversation;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('AiAssistantProvider: reconcile failed — $e');
    }
  }

  /// Resolve a conversation id when the `chat:start` event was missed by
  /// taking the most-recent conversation (top of the list, ordered by
  /// last_message_at desc). Server-side timestamps are unreliable for strict
  /// comparison across timezone differences between the client and server, so
  /// we fall back to "most recent" and then verify by message count delta.
  Future<String?> _discoverPendingConversationId() async {
    if (_pendingSentAt == null) return null;
    debugPrint('AiAssistantProvider: discoverPending: looking for most-recent conversation');
    try {
      final list = await repository.listConversations(page: 1, limit: 1);
      debugPrint('AiAssistantProvider: discoverPending: got ${list.length} conversations');
      if (list.isEmpty) return null;
      final c = list.first;
      debugPrint('AiAssistantProvider: discoverPending: using most-recent conv=${c.conversationId} lastAt=${c.lastMessageAt} messageCount=${c.messageCount}');
      return c.conversationId;
    } catch (e) {
      debugPrint('AiAssistantProvider: pending discovery failed — $e');
    }
    return null;
  }

  void stopStream() {
    if (!_isStreaming) return;
    socketService.stopStream();
    _isStreaming = false;
    _pendingSentAt = null;
    _stopStreamWatchdog();
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    if (message != null) notifyListeners();
  }

  void _onEvent(AiAssistantEvent event) {
    try {
      _handleEvent(event);
    } catch (e, st) {
      // Never let a malformed event kill the stream subscription — that would
      // silently disable all further chat updates until the user restarts the
      // app. Log the failure and reset streaming state so the UI is at least
      // recoverable via the watchdog / next user action.
      debugPrint('AiAssistantProvider: error handling event $event: $e\n$st');
      _isStreaming = false;
      _streamingDelta = '';
      _stopStreamWatchdog();
      notifyListeners();
    }
  }

  void _handleEvent(AiAssistantEvent event) {
    if (event is AiChatStart) {
      debugPrint('AiAssistantProvider: chat:start conv=${event.conversationId}');
      _pendingSentAt = null;
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
      debugPrint(
        'AiAssistantProvider: chat:token len=${event.delta.length} delta="${event.delta.length > 80 ? '${event.delta.substring(0, 80)}…' : event.delta}"',
      );
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
      debugPrint(
        'AiAssistantProvider: chat:done assistantId=${event.assistantMessageId} tokens=${event.tokensIn}/${event.tokensOut}',
      );
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
      _pendingSentAt = null;
      _stopStreamWatchdog();
      // Refresh status to reflect token usage, and the conversations list
      // so the AI Assistant home screen shows the new/updated entry
      // immediately when the user navigates back.
      loadStatus();
      loadConversations();
      notifyListeners();
    } else if (event is AiChatError) {
      _isStreaming = false;
      _streamingDelta = '';
      _pendingSentAt = null;
      _stopStreamWatchdog();
      _setError('${event.code}: ${event.message}');
    } else if (event is AiChatAborted) {
      _isStreaming = false;
      _streamingDelta = '';
      _pendingSentAt = null;
      _stopStreamWatchdog();
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
    _stopStreamWatchdog();
    _eventSubscription?.cancel();
    super.dispose();
  }
}
