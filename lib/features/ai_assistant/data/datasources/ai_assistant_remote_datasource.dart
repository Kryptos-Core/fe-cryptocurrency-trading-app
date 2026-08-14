import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Paginated envelope returned by the remote `/messages` endpoint.
///
/// Mirrors the BE response `{items, page, limit, total}` so callers can
/// drive incremental scroll-based pagination without pulling the entire
/// message history into memory.
class MessagePage {
  final List<MessageModel> items;
  final int page;
  final int limit;
  final int total;

  const MessagePage({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  bool get hasMore => items.length == limit && (total <= 0 || page * limit < total);
}

/// REST datasource for AI Assistant.
abstract class AiAssistantRemoteDataSource {
  Future<List<ConversationModel>> listConversations({int page, int limit});
  Future<ConversationModel> createConversation({String? title, String? intent, String? firstMessage});
  Future<ConversationModel> getConversation(String conversationId);

  /// Paginated messages fetch — returns a [MessagePage] with envelope metadata.
  Future<MessagePage> listMessagesPaged(String conversationId, {int page, int limit});

  Future<void> deleteConversation(String conversationId);
  Future<Map<String, dynamic>> getStatus();
}

class AiAssistantRemoteDataSourceImpl implements AiAssistantRemoteDataSource {
  final DioClient dioClient;

  AiAssistantRemoteDataSourceImpl({required this.dioClient});

  List<T> _extractList<T>(dynamic raw, T Function(Map<String, dynamic>) fromJson) {
    if (raw is List) {
      return raw.whereType<Map>().map((e) => fromJson(Map<String, dynamic>.from(e))).toList();
    }
    if (raw is Map) {
      var map = Map<String, dynamic>.from(raw);
      // Unwrap `{success, data: {...}}` envelope first.
      final dataField = map['data'];
      if (dataField is Map) {
        map = Map<String, dynamic>.from(dataField);
      } else if (dataField is List) {
        map = <String, dynamic>{'items': dataField};
      }
      // Now look for the list under items/data/rows.
      for (final key in const ['items', 'data', 'rows', 'messages']) {
        final value = map[key];
        if (value is List) {
          return value
              .whereType<Map>()
              .map((e) => fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
    }
    return const [];
  }

  ({List<T> items, int page, int limit, int total}) _parsePagedEnvelope<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
    int fallbackPage,
    int fallbackLimit,
  ) {
    if (raw is List) {
      // Legacy shape — no envelope metadata available.
      final items = raw
          .whereType<Map>()
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return (items: items, page: fallbackPage, limit: fallbackLimit, total: items.length);
    }
    if (raw is Map) {
      var map = Map<String, dynamic>.from(raw);
      // Unwrap standard `{success, data: {...}}` envelope.
      final outer = map['data'];
      if (outer is Map) {
        map = Map<String, dynamic>.from(outer);
      }
      final items = _extractList(map, fromJson);
      final page = int.tryParse(map['page']?.toString() ?? '') ?? fallbackPage;
      final limit = int.tryParse(map['limit']?.toString() ?? '') ?? fallbackLimit;
      final total = int.tryParse(map['total']?.toString() ?? '') ?? items.length;
      return (items: items, page: page, limit: limit, total: total);
    }
    return (items: const [], page: fallbackPage, limit: fallbackLimit, total: 0);
  }

  @override
  Future<List<ConversationModel>> listConversations({int page = 1, int limit = 20}) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.aiAssistantConversations,
        queryParameters: {'page': page, 'limit': limit},
      );
      return _extractList(response.data, ConversationModel.fromJson);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? e.message ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ConversationModel> createConversation({
    String? title,
    String? intent,
    String? firstMessage,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (intent != null) body['intent'] = intent;
      if (firstMessage != null) body['firstMessage'] = firstMessage;
      final response = await dioClient.dio.post<dynamic>(
        ApiConstants.aiAssistantConversations,
        data: body,
      );
      var data = Map<String, dynamic>.from(response.data as Map? ?? const {});
      // Unwrap `{success, data}` envelope.
      final inner = data['data'];
      if (inner is Map) {
        data = Map<String, dynamic>.from(inner);
      }
      return ConversationModel.fromJson(data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? e.message ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ConversationModel> getConversation(String conversationId) async {
    try {
      final response = await dioClient.dio.get<dynamic>(
        ApiConstants.aiAssistantConversation(conversationId),
      );
      final raw = response.data;
      if (raw is! Map) {
        throw ServerException(message: 'Invalid response', statusCode: 500);
      }
      var map = Map<String, dynamic>.from(raw);
      // Unwrap standard `{success, data: {conversation, messages, ...}}` envelope.
      final inner = map['data'];
      if (inner is Map) {
        map = Map<String, dynamic>.from(inner);
      }
      final convSource = map['conversation'];
      final conv = convSource is Map
          ? Map<String, dynamic>.from(convSource)
          : map;
      return ConversationModel.fromJson(conv);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? e.message ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<MessagePage> listMessagesPaged(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await dioClient.dio.get<dynamic>(
        ApiConstants.aiAssistantMessages(conversationId),
        queryParameters: {'page': page, 'limit': limit},
      );
      final parsed = _parsePagedEnvelope(
        response.data,
        MessageModel.fromJson,
        page,
        limit,
      );
      return MessagePage(
        items: parsed.items,
        page: parsed.page,
        limit: parsed.limit,
        total: parsed.total,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? e.message ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      await dioClient.dio.delete<void>(ApiConstants.aiAssistantConversation(conversationId));
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? e.message ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getStatus() async {
    try {
      final response = await dioClient.dio.get<dynamic>(ApiConstants.aiAssistantStatus);
      final data = response.data;
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        // Unwrap standard {success, data} envelope so callers receive
        // {enabled, model, ...} directly.
        final inner = map['data'];
        if (inner is Map) {
          return Map<String, dynamic>.from(inner);
        }
        return map;
      }
      return <String, dynamic>{};
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message']?.toString() ?? e.message ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
