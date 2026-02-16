// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_currencies_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedCurrenciesData _$PaginatedCurrenciesDataFromJson(
        Map<String, dynamic> json) =>
    PaginatedCurrenciesData(
      currencies: (json['currencies'] as List<dynamic>)
          .map((e) => CurrencyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
    );

Map<String, dynamic> _$PaginatedCurrenciesDataToJson(
        PaginatedCurrenciesData instance) =>
    <String, dynamic>{
      'currencies': instance.currencies,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
    };

PaginatedCurrenciesResponse _$PaginatedCurrenciesResponseFromJson(
        Map<String, dynamic> json) =>
    PaginatedCurrenciesResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: PaginatedCurrenciesData.fromJson(
          json['data'] as Map<String, dynamic>),
      timestamp: json['timestamp'] as String,
    );

Map<String, dynamic> _$PaginatedCurrenciesResponseToJson(
        PaginatedCurrenciesResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'timestamp': instance.timestamp,
    };
