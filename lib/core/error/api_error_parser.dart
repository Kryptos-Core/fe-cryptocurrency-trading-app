import 'exceptions.dart';

/// Extract a structured `code` and human `message` from a Dio response body.
/// The BE NestJS `AllExceptionsFilter` returns:
/// ```json
/// { "statusCode": 422, "code": "INVALID_EMAIL", "message": "Email invalid", "context": {…} }
/// ```
/// `code` is the canonical stable identifier — UI layers must dispatch on
/// `code` via `localizeApiError(...)`, never on the localized `message` text.
class ApiErrorParser {
  const ApiErrorParser._();

  static ApiErrorPayload extract({
    required dynamic data,
    required String fallbackMessage,
  }) {
    if (data is! Map) {
      return ApiErrorPayload(message: fallbackMessage);
    }

    final code = _stringFromMap(data, 'code');
    final message = _firstNonEmpty([
      _stringFromMap(data, 'message'),
      _stringFromMap(data, 'error'),
    ]);
    final context = data['context'];
    return ApiErrorPayload(
      code: code,
      message: (message != null && message.trim().isNotEmpty)
          ? message.trim()
          : fallbackMessage,
      context: context is Map
          ? Map<String, dynamic>.from(context)
          : null,
    );
  }

  static String? _stringFromMap(Map data, String key) {
    final value = data[key];
    if (value is String) return value;
    if (value == null) return null;
    return value.toString();
  }

  static String? _firstNonEmpty(List<String?> candidates) {
    for (final c in candidates) {
      if (c != null && c.trim().isNotEmpty) return c;
    }
    return null;
  }
}

class ApiErrorPayload {
  const ApiErrorPayload({
    required this.message,
    this.code,
    this.context,
  });

  final String message;
  final String? code;
  final Map<String, dynamic>? context;
}

/// Convenience: build a [ServerException] directly from a Dio response body.
ServerException buildServerException({
  required dynamic responseData,
  required int? statusCode,
  required String fallbackMessage,
}) {
  final payload = ApiErrorParser.extract(
    data: responseData,
    fallbackMessage: fallbackMessage,
  );
  return ServerException(
    message: payload.message,
    statusCode: statusCode,
    code: payload.code,
    context: payload.context,
  );
}