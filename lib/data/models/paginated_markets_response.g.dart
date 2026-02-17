// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element

part of 'paginated_markets_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedMarketsData _$PaginatedMarketsDataFromJson(
        Map<String, dynamic> json) =>
    PaginatedMarketsData(
      data: (json['pairs'] as List<dynamic>)
          .map((e) => MarketPairModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PaginatedMarketsDataToJson(
        PaginatedMarketsData instance) =>
    <String, dynamic>{
      'pairs': instance.data,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
    };

PaginatedMarketsResponse _$PaginatedMarketsResponseFromJson(
        Map<String, dynamic> json) =>
    PaginatedMarketsResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: PaginatedMarketsData.fromJson(json['data'] as Map<String, dynamic>),
      timestamp: json['timestamp'] as String?,
    );

Map<String, dynamic> _$PaginatedMarketsResponseToJson(
        PaginatedMarketsResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'timestamp': instance.timestamp,
    };
