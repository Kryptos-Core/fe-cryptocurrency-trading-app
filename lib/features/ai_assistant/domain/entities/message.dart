/// Role of a message in an AI conversation.
enum MessageRole { system, user, assistant, tool }

MessageRole _roleFromString(String? value) {
  switch (value) {
    case 'system':
      return MessageRole.system;
    case 'user':
      return MessageRole.user;
    case 'assistant':
      return MessageRole.assistant;
    case 'tool':
      return MessageRole.tool;
    default:
      return MessageRole.user;
  }
}

String messageRoleToString(MessageRole role) => role.name;
MessageRole messageRoleFromString(String? value) => _roleFromString(value);

/// A single message in an AI conversation.
class Message {
  final String messageId;
  final String conversationId;
  final MessageRole role;
  final String content;
  final String? model;
  final int tokensIn;
  final int tokensOut;
  final List<Map<String, dynamic>>? toolCalls;
  final List<Map<String, dynamic>>? contextRefs;
  final String? parentMessageId;
  final DateTime createdAt;

  const Message({
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

  Message copyWith({String? content}) {
    return Message(
      messageId: messageId,
      conversationId: conversationId,
      role: role,
      content: content ?? this.content,
      model: model,
      tokensIn: tokensIn,
      tokensOut: tokensOut,
      toolCalls: toolCalls,
      contextRefs: contextRefs,
      parentMessageId: parentMessageId,
      createdAt: createdAt,
    );
  }
}
