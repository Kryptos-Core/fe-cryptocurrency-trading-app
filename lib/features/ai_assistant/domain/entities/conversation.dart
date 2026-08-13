/// Intent of an AI conversation; mirrors the backend enum.
enum AiConversationIntent { guide, market, trading, rag, general }

AiConversationIntent _intentFromString(String? value) {
  switch (value) {
    case 'guide':
      return AiConversationIntent.guide;
    case 'market':
      return AiConversationIntent.market;
    case 'trading':
      return AiConversationIntent.trading;
    case 'rag':
      return AiConversationIntent.rag;
    case 'general':
    default:
      return AiConversationIntent.general;
  }
}

String aiIntentToString(AiConversationIntent intent) {
  return intent.name;
}

AiConversationIntent aiIntentFromString(String? value) => _intentFromString(value);

/// A single AI chat conversation.
class Conversation {
  final String conversationId;
  final String userId;
  final String title;
  final AiConversationIntent intent;
  final DateTime? lastMessageAt;
  final int messageCount;
  final int totalTokensIn;
  final int totalTokensOut;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    required this.conversationId,
    required this.userId,
    required this.title,
    required this.intent,
    required this.lastMessageAt,
    required this.messageCount,
    required this.totalTokensIn,
    required this.totalTokensOut,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Conversation copyWith({
    String? conversationId,
    String? title,
    DateTime? lastMessageAt,
    int? messageCount,
    int? totalTokensIn,
    int? totalTokensOut,
  }) {
    return Conversation(
      conversationId: conversationId ?? this.conversationId,
      userId: userId,
      title: title ?? this.title,
      intent: intent,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      messageCount: messageCount ?? this.messageCount,
      totalTokensIn: totalTokensIn ?? this.totalTokensIn,
      totalTokensOut: totalTokensOut ?? this.totalTokensOut,
      deletedAt: deletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
