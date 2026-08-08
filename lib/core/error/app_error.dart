/// Base sealed class for all app errors.
///
/// Mirrors the BE DomainError pattern. Properties are immutable.
/// Use [userMessageKey] for i18n resolution — never embed raw text.
library;

import 'package:equatable/equatable.dart';

/// Base class for all app errors.
///
/// All error subclasses must extend this. Use [Result] from `core/network/result.dart`
/// to bubble errors without throwing.
sealed class AppError extends Equatable implements Exception {
  final String code;
  final String userMessageKey;
  final Map<String, Object> metadata;
  final Object? cause;

  const AppError({
    required this.code,
    required this.userMessageKey,
    this.metadata = const {},
    this.cause,
  });

  /// Convert to a log-safe JSON map. NEVER send to client.
  Map<String, Object> toLogMap() => {
    'name': runtimeType.toString(),
    'code': code,
    'userMessageKey': userMessageKey,
    'metadata': metadata,
    if (cause != null) 'cause': cause.toString(),
  };

  @override
  List<Object?> get props => [code, userMessageKey, metadata, cause];
}
