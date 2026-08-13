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

class FakeRepository implements AiAssistantRepository {
  List<Conversation> conversations;
  Map<String, List<Message>> messages;
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
  Future<({Conversation conversation, List<Message> messages})> getConversation(
    String conversationId, {
    int page = 1,
    int limit = 100,
  }) async {
    final list = messages[conversationId] ?? <Message>[];
    return (
      conversation: conversations.firstWhere(
        (c) => c.conversationId == conversationId,
        orElse: () => Conversation(
          conversationId: conversationId,
          userId: 'u1',
          title: 't',
          intent: AiConversationIntent.general,
          lastMessageAt: null,
          messageCount: list.length,
          totalTokensIn: 0,
          totalTokensOut: 0,
          deletedAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
      messages: list,
    );
  }

  @override
  Future<List<Conversation>> listConversations({int page = 1, int limit = 20}) async =>
      conversations;

  @override
  Future<List<Message>> listMessages(
    String conversationId, {
    int page = 1,
    int limit = 100,
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

    test('openConversation populates messages from repository', () async {
      final convId = 'c1';
      repo.conversations = [
        Conversation(
          conversationId: convId,
          userId: 'u1',
          title: 'title',
          intent: AiConversationIntent.general,
          lastMessageAt: null,
          messageCount: 1,
          totalTokensIn: 0,
          totalTokensOut: 0,
          deletedAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      repo.messages[convId] = [
        Message(
          messageId: 'm1',
          conversationId: convId,
          role: MessageRole.user,
          content: 'hi',
          model: null,
          tokensIn: 0,
          tokensOut: 0,
          toolCalls: null,
          contextRefs: null,
          parentMessageId: null,
          createdAt: DateTime.now(),
        ),
      ];

      final p = AiAssistantProvider(repository: repo, socketService: socket);
      await p.openConversation(convId);

      expect(p.activeConversation?.conversationId, convId);
      expect(p.messages, hasLength(1));
    });
  });
}