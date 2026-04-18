import 'package:json_annotation/json_annotation.dart';
import 'package:crypto_trading_app/features/markets/data/models/currency_model.dart';

part 'paginated_currencies_response.g.dart';

/// Paginated Currencies Response Data
/// Following the API response structure where currencies are nested in data object
@JsonSerializable()
class PaginatedCurrenciesData {
  final List<CurrencyModel> currencies;
  final int total;
  final int page;
  final int limit;

  const PaginatedCurrenciesData({
    required this.currencies,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PaginatedCurrenciesData.fromJson(Map<String, dynamic> json) =>
      _$PaginatedCurrenciesDataFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedCurrenciesDataToJson(this);
}

/// Paginated Currencies API Response
@JsonSerializable()
class PaginatedCurrenciesResponse {
  final bool success;
  final String? message;
  final PaginatedCurrenciesData data;
  final String timestamp;

  const PaginatedCurrenciesResponse({
    required this.success,
    this.message,
    required this.data,
    required this.timestamp,
  });

  factory PaginatedCurrenciesResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatedCurrenciesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedCurrenciesResponseToJson(this);
}
