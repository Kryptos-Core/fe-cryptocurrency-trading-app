import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/features/ai_assistant/application/providers/ai_assistant_provider.dart';
import 'package:crypto_trading_app/features/ai_assistant/application/services/ai_assistant_socket_service.dart';
import 'package:crypto_trading_app/features/ai_assistant/domain/entities/conversation.dart';
import 'package:crypto_trading_app/features/ai_assistant/domain/entities/message.dart';
import 'package:crypto_trading_app/features/ai_assistant/domain/repositories/ai_assistant_repository.dart';

class FakeTokenService implements TokenService {
  String? _token;
  @override
  String? getAccessToken() => _token;
  @override
  Future<void> setAccessToken(String token) async {
    _token = token;
  }

  @override
  Future<void> clear() async {
    _token = null;
  }

  @override
  String? getRefreshToken() => null;

  @override
  Future<void> setRefreshToken(String token) async {}

  @override
  Future<void> setTokens({String? accessToken, String? refreshToken}) async {
    if (accessToken != null) _token = accessToken;
  }

  @override
  Stream<String?> accessTokenStream() => const Stream.empty();

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Paged fake repository. Stores all messages per conversation and slices
/// them by `page`/`limit` so we can exercise pagination behaviour in tests.
class FakeRepository implements AiAssistantRepository {
  List<Conversation> conversations;
  Map<String, List<Message>> messages;

  /// Recorded page requests keyed by conversation id, in arrival order.
  /// Lets tests assert that the right `page` index was requested.
  final List<({String conversationId, int page, int limit})> pageCalls = [];

  FakeRepository({List<Conversation>? conversations, Map<String, List<Message>>? messages})
      : conversations = conversations ?? <Conversation>[],
        messages = messages ?? <String, List<Message>>{};

  @override
  Future<Conversation> createConversation({String? title, String? firstMessage}) async {
    return Conversation(
      conversationId: 'new-conv',
      userId: 'u1',
      title: title ?? 'Mới',
      intent: AiConversationIntent.general,
      lastMessageAt: DateTime.now(),
      messageCount: 0,
      totalTokensIn: 0,
      totalTokensOut: 0,
      deletedAt: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteConversation(String conversationId) async {}

  @override
  Future<
      ({
        Conversation conversation,
        List<Message> messages,
        int total,
        int page,
        int limit,
      })> getConversation(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    pageCalls.add((conversationId: conversationId, page: page, limit: limit));
    final all = messages[conversationId] ?? <Message>[];
    final total = all.length;
    final start = (page - 1) * limit;
    final end = (start + limit).clamp(0, total);
    final slice = (start >= total) ? <Message>[] : all.sublist(start, end);
    return (
      conversation: conversations.firstWhere(
        (c) => c.conversationId == conversationId,
        orElse: () => Conversation(
          conversationId: conversationId,
          userId: 'u1',
          title: 't',
          intent: AiConversationIntent.general,
          lastMessageAt: null,
          messageCount: total,
          totalTokensIn: 0,
          totalTokensOut: 0,
          deletedAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
      messages: slice,
      total: total,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<List<Conversation>> listConversations({int page = 1, int limit = 20}) async =>
      conversations;

  @override
  Future<List<Message>> listMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async =>
      messages[conversationId] ?? <Message>[];

  @override
  Future<AiAssistantStatus> getStatus() async => const AiAssistantStatus(
        enabled: true,
        model: 'gx/gpt-5.4',
        dailyRemainingTokens: 99000,
        dailyUsedTokens: 1000,
      );
}

class FakeSocketService extends AiAssistantSocketService {
  final StreamController<AiAssistantEvent> _controller =
      StreamController<AiAssistantEvent>.broadcast();
  String? lastSentContent;
  String? lastSentConversationId;
  bool stopCalled = false;

  @override
  Stream<AiAssistantEvent> get eventStream => _controller.stream;

  void emit(AiAssistantEvent event) => _controller.add(event);

  @override
  void sendMessage({String? conversationId, required String content}) {
    lastSentContent = content;
    lastSentConversationId = conversationId;
  }

  @override
  void stopStream() {
    stopCalled = true;
  }
}

List<Message> _makeMessages(String convId, int count) {
  final base = DateTime(2026, 1, 1, 9);
  return List<Message>.generate(count, (i) {
    return Message(
      messageId: 'm-${convId}-${i.toString().padLeft(4, '0')}',
      conversationId: convId,
      role: i.isEven ? MessageRole.user : MessageRole.assistant,
      content: 'msg $i',
      model: null,
      tokensIn: 0,
      tokensOut: 0,
      toolCalls: null,
      contextRefs: null,
      parentMessageId: null,
      createdAt: base.add(Duration(minutes: i)),
    );
  });
}

void main() {
  group('AiAssistantProvider', () {
    late FakeRepository repo;
    late FakeSocketService socket;

    setUp(() {
      repo = FakeRepository();
      socket = FakeSocketService();
      // Register a fake TokenService so the provider can be instantiated.
      // Use tryRegister to avoid issues when running multiple test files.
      if (!GetIt.instance.isRegistered<TokenService>()) {
        GetIt.instance.registerSingleton<TokenService>(FakeTokenService());
      }
    });

    test('loadConversations populates list and clears errors', () async {
      repo.conversations = [
        Conversation(
          conversationId: 'c1',
          userId: 'u1',
          title: 't1',
          intent: AiConversationIntent.market,
          lastMessageAt: null,
          messageCount: 0,
          totalTokensIn: 0,
          totalTokensOut: 0,
          deletedAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final p = AiAssistantProvider(repository: repo, socketService: socket);
      await p.loadConversations();

      expect(p.conversations, hasLength(1));
      expect(p.isLoadingConversations, isFalse);
      expect(p.conversationsError, isNull);
    });

    test('sendMessage routes through socket service and toggles streaming flag', () async {
      final p = AiAssistantProvider(repository: repo, socketService: socket);
      await p.sendMessage('Giá BTC?');

      expect(socket.lastSentContent, 'Giá BTC?');
      expect(socket.lastSentConversationId, isNull);
      expect(p.isStreaming, isTrue);
      expect(p.messages, hasLength(1));
      expect(p.messages.first.role, MessageRole.user);
    });

    test('chat:start updates active conversation and triggers tool_call bubble', () async {
      final p = AiAssistantProvider(repository: repo, socketService: socket);

      socket.emit(const AiChatStart(conversationId: 'c1', userMessageId: 'm1'));
      await Future<void>.delayed(Duration.zero);
      expect(p.activeConversation?.conversationId, 'c1');

      socket.emit(const AiChatToolCall(name: 'get_ticker', args: {'symbol': 'BTC/USDT'}));
      await Future<void>.delayed(Duration.zero);
      final toolMsg = p.messages.firstWhere((m) => m.role == MessageRole.tool);
      expect(toolMsg.content, contains('get_ticker'));
    });

    test('chat:done finalises streaming and loads status', () async {
      final p = AiAssistantProvider(repository: repo, socketService: socket);
      await p.sendMessage('hi');

      socket.emit(const AiChatToken('Xin '));
      socket.emit(const AiChatToken('chào'));
      await Future<void>.delayed(Duration.zero);
      expect(p.streamingDelta, 'Xin chào');

      socket.emit(const AiChatDone(
        assistantMessageId: 'a1',
        tokensIn: 10,
        tokensOut: 5,
        model: 'gx/gpt-5.4',
      ));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(p.isStreaming, isFalse);
      expect(p.streamingDelta, isEmpty);
      expect(p.messages.last.role, MessageRole.assistant);
      expect(p.messages.last.content, 'Xin chào');
      expect(p.status, isNotNull);
    });

    test('chat:error sets error and stops streaming', () async {
      final p = AiAssistantProvider(repository: repo, socketService: socket);
      await p.sendMessage('hi');
      socket.emit(const AiChatError(code: 'RATE_LIMITED', message: 'spam'));
      await Future<void>.delayed(Duration.zero);
      expect(p.isStreaming, isFalse);
      expect(p.error, contains('RATE_LIMITED'));
    });

    test('stopStream sends chat:stop and clears streaming', () async {
      final p = AiAssistantProvider(repository: repo, socketService: socket);
      await p.sendMessage('hi');
      p.stopStream();
      expect(socket.stopCalled, isTrue);
      expect(p.isStreaming, isFalse);
    });

    test('openConversation loads only the last page (newest messages) of a long history', () async {
      const convId = 'c1';
      final all = _makeMessages(convId, 120);
      repo.conversations = [
        Conversation(
          conversationId: convId,
          userId: 'u1',
          title: 'title',
          intent: AiConversationIntent.general,
          lastMessageAt: null,
          messageCount: all.length,
          totalTokensIn: 0,
          totalTokensOut: 0,
          deletedAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      repo.messages[convId] = all;

      final p = AiAssistantProvider(repository: repo, socketService: socket);
      await p.openConversation(convId);

      // First call probes page 1 to read the envelope total (so the provider
      // can locate the last page). The second call fetches that last page.
      expect(repo.pageCalls, hasLength(2));
      expect(repo.pageCalls.first.page, 1);
      expect(repo.pageCalls.last.page, 3);
      expect(repo.pageCalls.last.limit, kAiAssistantMessagesPageSize);
      // Should render the most recent 20 messages (120 - 100).
      expect(p.messages, hasLength(20));
      expect(p.messages.first.messageId, 'm-c1-0100');
      expect(p.messages.last.messageId, 'm-c1-0119');
      expect(p.hasMoreOlder, isTrue);
      expect(p.messagesTotal, 120);
    });

    test('openConversation on a short conversation marks hasMoreOlder=false', () async {
      const convId = 'c1';
      final all = _makeMessages(convId, 5);
      repo.messages[convId] = all;
      repo.conversations = [
        Conversation(
          conversationId: convId,
          userId: 'u1',
          title: 'short',
          intent: AiConversationIntent.general,
          lastMessageAt: null,
          messageCount: all.length,
          totalTokensIn: 0,
          totalTokensOut: 0,
          deletedAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final p = AiAssistantProvider(repository: repo, socketService: socket);
      await p.openConversation(convId);

      expect(p.messages, hasLength(5));
      expect(p.hasMoreOlder, isFalse);
      // Probe page 1 → reveals total = 5 (= last page), no follow-up call.
      expect(repo.pageCalls, hasLength(1));
      expect(repo.pageCalls.first.page, 1);
    });

    test('loadOlderMessages fetches the previous page and prepends in order', () async {
      const convId = 'c1';
      final all = _makeMessages(convId, 120);
      repo.conversations = [
        Conversation(
          conversationId: convId,
          userId: 'u1',
          title: 't',
          intent: AiConversationIntent.general,
          lastMessageAt: null,
          messageCount: all.length,
          totalTokensIn: 0,
          totalTokensOut: 0,
          deletedAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      repo.messages[convId] = all;

      final p = AiAssistantProvider(repository: repo, socketService: socket);
      await p.openConversation(convId);
      expect(p.messages, hasLength(20));
      expect(p.hasMoreOlder, isTrue);

      await p.loadOlderMessages();

      // openConversation probes page 1 + fetches last page (3); the load
      // older call fetches page 2. Total = 3 calls.
      expect(repo.pageCalls, hasLength(3));
      expect(repo.pageCalls.last.page, 2);
      expect(repo.pageCalls.last.limit, kAiAssistantMessagesPageSize);

      // Page 2 covers indices 50..99. Combined with page 3 (100..119), the
      // list is now 70 messages, sorted ASC by createdAt.
      expect(p.messages, hasLength(70));
      expect(p.messages.first.messageId, 'm-c1-0050');
      expect(p.messages.last.messageId, 'm-c1-0119');
      expect(p.hasMoreOlder, isTrue);
    });

    test('loadOlderMessages stops fetching once a short page comes back', () async {
      const convId = 'c1';
      // Exactly 60 messages = 1 full page (50) + 1 short page (10). After
      // opening (page 2, 10 messages) and one loadOlder (page 1, 50), the
      // provider must set hasMoreOlder=false.
      final all = _makeMessages(convId, 60);
      repo.conversations = [
        Conversation(
          conversationId: convId,
          userId: 'u1',
          title: 't',
          intent: AiConversationIntent.general,
          lastMessageAt: null,
          messageCount: all.length,
          totalTokensIn: 0,
          totalTokensOut: 0,
          deletedAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      repo.messages[convId] = all;

      final p = AiAssistantProvider(repository: repo, socketService: socket);
      await p.openConversation(convId);
      // Opened the last page (page 2) → 10 messages.
      expect(p.messages, hasLength(10));
      expect(p.hasMoreOlder, isTrue);

      await p.loadOlderMessages();
      expect(p.messages, hasLength(60));
      expect(p.hasMoreOlder, isFalse);
    });

    test('loadOlderMessages is a no-op while a previous load is in flight', () async {
      const convId = 'c1';
      final all = _makeMessages(convId, 200);
      repo.conversations = [
        Conversation(
          conversationId: convId,
          userId: 'u1',
          title: 't',
          intent: AiConversationIntent.general,
          lastMessageAt: null,
          messageCount: all.length,
          totalTokensIn: 0,
          totalTokensOut: 0,
          deletedAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      repo.messages[convId] = all;

      final p = AiAssistantProvider(repository: repo, socketService: socket);
      await p.openConversation(convId);

      // Fire two concurrent loadOlder calls without awaiting. Only the
      // first one should produce an extra request — openConversation already
      // made 2 calls (probe + last), so the expected total is 3.
      final f1 = p.loadOlderMessages();
      final f2 = p.loadOlderMessages();
      await Future.wait([f1, f2]);

      expect(repo.pageCalls, hasLength(3));
    });

    test('openConversation after a streaming chat:done keeps the final message', () async {
      const convId = 'c1';
      final all = _makeMessages(convId, 4);
      repo.conversations = [
        Conversation(
          conversationId: convId,
          userId: 'u1',
          title: 't',
          intent: AiConversationIntent.general,
          lastMessageAt: null,
          messageCount: all.length,
          totalTokensIn: 0,
          totalTokensOut: 0,
          deletedAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      repo.messages[convId] = all;

      final p = AiAssistantProvider(repository: repo, socketService: socket);
      await p.openConversation(convId);

      expect(p.messages.last.messageId, 'm-c1-0003');
      expect(p.activeConversation?.conversationId, convId);
    });
  });
}