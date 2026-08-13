import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// REST datasource for AI Assistant.
abstract class AiAssistantRemoteDataSource {
  Future<List<ConversationModel>> listConversations({int page, int limit});
  Future<ConversationModel> createConversation({String? title, String? intent, String? firstMessage});
  Future<ConversationModel> getConversation(String conversationId);
  Future<List<MessageModel>> listMessages(String conversationId, {int page, int limit});
  Future<void> deleteConversation(String conversationId);
  Future<Map<String, dynamic>> getStatus();
}

class AiAssistantRemoteDataSourceImpl implements AiAssistantRemoteDataSource {
  final DioClient dioClient;

  AiAssistantRemoteDataSourceImpl({required this.dioClient});

  List<T> _extractList<T>(dynamic raw, T Function(Map<String, dynamic>) fromJson) {
    if (raw is List) {
      return raw.whereType<Map>().map((e) => fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }
    if (raw is Map) {
      var map = Map<String, dynamic>.from(raw as Map);
      // Unwrap `{success, data: {...}}` envelope first.
      final dataField = map['data'];
      if (dataField is Map) {
        map = Map<String, dynamic>.from(dataField as Map);
      } else if (dataField is List) {
        map = <String, dynamic>{'items': dataField};
      }
      // Now look for the list under items/data/rows.
      for (final key in const ['items', 'data', 'rows', 'messages']) {
        final value = map[key];
        if (value is List) {
          return value
              .whereType<Map>()
              .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
      }
    }
    return const [];
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
        data = Map<String, dynamic>.from(inner as Map);
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
      var map = Map<String, dynamic>.from(raw as Map);
      // Unwrap standard `{success, data: {conversation, messages, ...}}` envelope.
      final inner = map['data'];
      if (inner is Map) {
        map = Map<String, dynamic>.from(inner as Map);
      }
      final convSource = map['conversation'];
      final conv = convSource is Map
          ? Map<String, dynamic>.from(convSource as Map)
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
  Future<List<MessageModel>> listMessages(
    String conversationId, {
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.aiAssistantMessages(conversationId),
        queryParameters: {'page': page, 'limit': limit},
      );
      return _extractList(response.data, MessageModel.fromJson);
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
        final map = Map<String, dynamic>.from(data as Map);
        // Unwrap standard {success, data} envelope so callers receive
        // {enabled, model, ...} directly.
        final inner = map['data'];
        if (inner is Map) {
          return Map<String, dynamic>.from(inner as Map);
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
