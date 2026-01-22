// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    ErrorResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      message: json['message'] as String,
      code: json['code'] as String?,
      timestamp: json['timestamp'] as String,
      path: json['path'] as String,
      context: json['context'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ErrorResponseToJson(ErrorResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'message': instance.message,
      'code': instance.code,
      'timestamp': instance.timestamp,
      'path': instance.path,
      'context': instance.context,
    };

ValidationError _$ValidationErrorFromJson(Map<String, dynamic> json) =>
    ValidationError(
      field: json['field'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$ValidationErrorToJson(ValidationError instance) =>
    <String, dynamic>{
      'field': instance.field,
      'message': instance.message,
    };
