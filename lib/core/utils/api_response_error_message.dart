/// Normalizes NestJS / class-validator error bodies where `message` may be
/// a [String], a [List] of strings, or a single nested value.
String? parseBackendErrorMessage(dynamic message) {
  if (message == null) return null;
  if (message is String) {
    final t = message.trim();
    return t.isEmpty ? null : t;
  }
  if (message is List) {
    final parts = <String>[];
    for (final e in message) {
      if (e == null) continue;
      final s = e is String ? e.trim() : e.toString().trim();
      if (s.isNotEmpty) parts.add(s);
    }
    if (parts.isEmpty) return null;
    return parts.join('\n');
  }
  final asString = message.toString().trim();
  return asString.isEmpty ? null : asString;
}

/// Uses [parseBackendErrorMessage] when present; otherwise [defaultMessage].
String backendErrorMessageOrDefault(dynamic message, String defaultMessage) {
  return parseBackendErrorMessage(message) ?? defaultMessage;
}
