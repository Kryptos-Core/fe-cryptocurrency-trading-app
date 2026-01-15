import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

/// Generic API Response Model
/// Following Backend API Response Structure
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String timestamp;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    required this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}

/// Paginated API Response Model
@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final bool success;
  final String? message;
  final List<T> data;
  final int total;
  final int page;
  final int limit;
  final String timestamp;

  const PaginatedResponse({
    required this.success,
    this.message,
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.timestamp,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);
}
