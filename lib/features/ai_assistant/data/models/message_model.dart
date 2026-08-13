import '../../domain/entities/message.dart';

/// JSON model for an AI message returned by the backend.
class MessageModel {
  final String messageId;
  final String conversationId;
  final String role;
  final String content;
  final String? model;
  final int tokensIn;
  final int tokensOut;
  final List<Map<String, dynamic>>? toolCalls;
  final List<Map<String, dynamic>>? contextRefs;
  final String? parentMessageId;
  final DateTime createdAt;

  const MessageModel({
    required this.messageId,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.model,
    required this.tokensIn,
    required this.tokensOut,
    required this.toolCalls,
    required this.contextRefs,
    required this.parentMessageId,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) {
      try {
        return DateTime.parse(v.toString()).toLocal();
      } catch (_) {
        return DateTime.now();
      }
    }

    return MessageModel(
      messageId: json['message_id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      content: json['content']?.toString() ?? '',
      model: json['model']?.toString(),
      tokensIn: int.tryParse(json['tokens_in']?.toString() ?? '0') ?? 0,
      tokensOut: int.tryParse(json['tokens_out']?.toString() ?? '0') ?? 0,
      toolCalls: (json['tool_calls'] is List)
          ? (json['tool_calls'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList()
          : null,
      contextRefs: (json['context_refs'] is List)
          ? (json['context_refs'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList()
          : null,
      parentMessageId: json['parent_message_id']?.toString(),
      createdAt: parseDate(json['created_at']),
    );
  }

  Message toDomain() => Message(
        messageId: messageId,
        conversationId: conversationId,
        role: messageRoleFromString(role),
        content: content,
        model: model,
        tokensIn: tokensIn,
        tokensOut: tokensOut,
        toolCalls: toolCalls,
        contextRefs: contextRefs,
        parentMessageId: parentMessageId,
        createdAt: createdAt,
      );
}
