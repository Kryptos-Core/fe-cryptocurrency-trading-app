// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_currencies_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedCurrenciesData _$PaginatedCurrenciesDataFromJson(
        Map<String, dynamic> json) =>
    PaginatedCurrenciesData(
      currencies: (json['currencies'] as List<dynamic>?)
              ?.map((e) => CurrencyModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
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
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: PaginatedCurrenciesData.fromJson(
          (json['data'] as Map<String, dynamic>?) ?? <String, dynamic>{}),
      timestamp: json['timestamp'] as String? ?? '',
    );

Map<String, dynamic> _$PaginatedCurrenciesResponseToJson(
        PaginatedCurrenciesResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'timestamp': instance.timestamp,
    };
