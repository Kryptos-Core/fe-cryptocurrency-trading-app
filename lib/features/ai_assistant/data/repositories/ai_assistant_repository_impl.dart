import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/ai_assistant_repository.dart';
import '../datasources/ai_assistant_remote_datasource.dart';

/// Repository implementation: bridges remote data sources to domain entities.
class AiAssistantRepositoryImpl implements AiAssistantRepository {
  final AiAssistantRemoteDataSource remote;

  AiAssistantRepositoryImpl({required this.remote});

  @override
  Future<List<Conversation>> listConversations({int page = 1, int limit = 20}) async {
    final models = await remote.listConversations(page: page, limit: limit);
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<Conversation> createConversation({String? title, String? firstMessage}) async {
    final model = await remote.createConversation(title: title, firstMessage: firstMessage);
    return model.toDomain();
  }

  @override
  Future<({Conversation conversation, List<Message> messages})> getConversation(
    String conversationId, {
    int page = 1,
    int limit = 100,
  }) async {
    final messages = await remote.listMessages(conversationId, page: page, limit: limit);
    final convModel = await remote.getConversation(conversationId);
    return (
      conversation: convModel.toDomain(),
      messages: messages.map((m) => m.toDomain()).toList(),
    );
  }

  @override
  Future<List<Message>> listMessages(String conversationId, {int page = 1, int limit = 100}) async {
    final models = await remote.listMessages(conversationId, page: page, limit: limit);
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<void> deleteConversation(String conversationId) {
    return remote.deleteConversation(conversationId);
  }

  @override
  Future<AiAssistantStatus> getStatus() async {
    final raw = await remote.getStatus();
    return AiAssistantStatus(
      enabled: raw['enabled'] == true,
      model: raw['model']?.toString(),
      dailyRemainingTokens: int.tryParse(raw['daily_remaining_tokens']?.toString() ?? '0') ?? 0,
      dailyUsedTokens: int.tryParse(raw['daily_used_tokens']?.toString() ?? '0') ?? 0,
    );
  }
}
