import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/ai_assistant_repository.dart';
import '../datasources/ai_assistant_remote_datasource.dart';
import '../models/conversation_model.dart';

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
  Future<({Conversation conversation, List<Message> messages, int total, int page, int limit})>
      getConversation(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    // Fetch the conversation metadata + the requested page of messages in
    // parallel. The remote datasource exposes a paginated `/messages`
    // endpoint that already accepts page/limit and returns the envelope
    // {items, page, limit, total}, so we can drive scroll-based pagination
    // without ever pulling the full message history into memory.
    final results = await Future.wait<dynamic>([
      remote.getConversation(conversationId),
      remote.listMessagesPaged(conversationId, page: page, limit: limit),
    ]);
    final convModel = results[0] as ConversationModel;
    final paged = results[1] as MessagePage;

    return (
      conversation: convModel.toDomain(),
      messages: paged.items.map((m) => m.toDomain()).toList(),
      total: paged.total,
      page: paged.page,
      limit: paged.limit,
    );
  }

  @override
  Future<List<Message>> listMessages(String conversationId, {int page = 1, int limit = 50}) async {
    final paged = await remote.listMessagesPaged(conversationId, page: page, limit: limit);
    return paged.items.map((m) => m.toDomain()).toList();
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
