import '../entities/conversation.dart';
import '../entities/message.dart';

/// Typed socket events emitted by the AI Assistant gateway.
abstract class AiAssistantEvent {
  const AiAssistantEvent();
}

class AiChatStart extends AiAssistantEvent {
  final String conversationId;
  final String userMessageId;
  const AiChatStart({required this.conversationId, required this.userMessageId});
}

class AiChatToken extends AiAssistantEvent {
  final String delta;
  const AiChatToken(this.delta);
}

class AiChatToolCall extends AiAssistantEvent {
  final String name;
  final Map<String, dynamic> args;
  const AiChatToolCall({required this.name, required this.args});
}

class AiChatToolResult extends AiAssistantEvent {
  final String name;
  final dynamic result;
  const AiChatToolResult({required this.name, required this.result});
}

class AiChatDone extends AiAssistantEvent {
  final String assistantMessageId;
  final int tokensIn;
  final int tokensOut;
  final String model;
  const AiChatDone({
    required this.assistantMessageId,
    required this.tokensIn,
    required this.tokensOut,
    required this.model,
  });
}

class AiChatError extends AiAssistantEvent {
  final String code;
  final String message;
  const AiChatError({required this.code, required this.message});
}

class AiChatAborted extends AiAssistantEvent {
  const AiChatAborted();
}

/// Snapshot of the AI Assistant feature status from `/ai-assistant/status`.
class AiAssistantStatus {
  final bool enabled;
  final String? model;
  final int dailyRemainingTokens;
  final int dailyUsedTokens;

  const AiAssistantStatus({
    required this.enabled,
    required this.model,
    required this.dailyRemainingTokens,
    required this.dailyUsedTokens,
  });
}

/// Public surface for AI Assistant data access.
abstract class AiAssistantRepository {
  Future<List<Conversation>> listConversations({int page = 1, int limit = 20});
  Future<Conversation> createConversation({String? title, String? firstMessage});

  /// Fetch a conversation together with one page of its messages.
  /// Returns the conversation metadata plus the messages for the requested
  /// page, along with envelope metadata (total/page/limit) so callers can
  /// drive incremental (reverse / scroll) pagination.
  Future<({Conversation conversation, List<Message> messages, int total, int page, int limit})>
      getConversation(
    String conversationId, {
    int page = 1,
    int limit = 50,
  });

  Future<List<Message>> listMessages(String conversationId, {int page = 1, int limit = 50});
  Future<void> deleteConversation(String conversationId);

  Future<AiAssistantStatus> getStatus();
}
