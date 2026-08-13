import '../../domain/entities/conversation.dart';

/// JSON model for an AI conversation returned by the backend.
class ConversationModel {
  final String conversationId;
  final String userId;
  final String title;
  final String intent;
  final DateTime? lastMessageAt;
  final int messageCount;
  final int totalTokensIn;
  final int totalTokensOut;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ConversationModel({
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

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is String && v.isEmpty) return null;
      try {
        return DateTime.parse(v.toString()).toLocal();
      } catch (_) {
        return null;
      }
    }

    return ConversationModel(
      conversationId: json['conversation_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      intent: json['intent']?.toString() ?? 'general',
      lastMessageAt: parseDate(json['last_message_at']),
      messageCount: int.tryParse(json['message_count']?.toString() ?? '0') ?? 0,
      totalTokensIn: int.tryParse(json['total_tokens_in']?.toString() ?? '0') ?? 0,
      totalTokensOut: int.tryParse(json['total_tokens_out']?.toString() ?? '0') ?? 0,
      deletedAt: parseDate(json['deleted_at']),
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  Conversation toDomain() => Conversation(
        conversationId: conversationId,
        userId: userId,
        title: title,
        intent: aiIntentFromString(intent),
        lastMessageAt: lastMessageAt,
        messageCount: messageCount,
        totalTokensIn: totalTokensIn,
        totalTokensOut: totalTokensOut,
        deletedAt: deletedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
