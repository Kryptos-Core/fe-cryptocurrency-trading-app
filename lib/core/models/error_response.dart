import 'package:json_annotation/json_annotation.dart';

part 'error_response.g.dart';

/// Error Response Model
/// Following Backend API Error Response Structure
@JsonSerializable()
class ErrorResponse {
  final int statusCode;
  final String message;
  final String? code; // Error code (optional)
  final String timestamp;
  final String path;
  final Map<String, dynamic>? context; // Additional error context

  const ErrorResponse({
    required this.statusCode,
    required this.message,
    this.code,
    required this.timestamp,
    required this.path,
    this.context,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);

  /// Get validation errors from context if available
  List<ValidationError>? get validationErrors {
    if (context == null) return null;
    final errors = context!['errors'];
    if (errors is List) {
      return errors
          .map((e) => ValidationError.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return null;
  }
}

/// Validation Error Model
@JsonSerializable()
class ValidationError {
  final String field;
  final String message;

  const ValidationError({
    required this.field,
    required this.message,
  });

  factory ValidationError.fromJson(Map<String, dynamic> json) =>
      _$ValidationErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ValidationErrorToJson(this);
}
