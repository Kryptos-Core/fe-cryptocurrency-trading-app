import 'package:json_annotation/json_annotation.dart';
import 'package:crypto_trading_app/data/models/market_pair_model.dart';

part 'paginated_markets_response.g.dart';

/// Paginated Markets Response Data
/// GET /markets: data is OBJECT { pairs, total, page, limit, tickers? }.
/// When includeTickers=true, data.tickers is present (same format as GET /markets/tickers/all).
@JsonSerializable()
class PaginatedMarketsData {
  @JsonKey(name: 'pairs') // API uses "pairs" field
  final List<MarketPairModel> data;
  final int total;
  final int page;
  final int limit;
  @JsonKey(name: 'totalPages')
  final int? totalPages; // Optional - may not be in response
  /// Present when GET /markets was called with includeTickers=true.
  final List<MarketTickerModel>? tickers;

  const PaginatedMarketsData({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    this.totalPages,
    this.tickers,
  });

  factory PaginatedMarketsData.fromJson(Map<String, dynamic> json) {
    // Handle null pairs - return empty list if null
    final pairsJson = json['pairs'];
    final pairsList = pairsJson != null
        ? (pairsJson as List<dynamic>)
            .map((e) => MarketPairModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <MarketPairModel>[];

    final tickersJson = json['tickers'];
    final tickersList = tickersJson != null && tickersJson is List
        ? tickersJson
            .map((e) => MarketTickerModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : null;

    return PaginatedMarketsData(
      data: pairsList,
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      totalPages: (json['totalPages'] as num?)?.toInt(),
      tickers: tickersList,
    );
  }

  Map<String, dynamic> toJson() => _$PaginatedMarketsDataToJson(this);
}

/// Paginated Markets API Response
@JsonSerializable()
class PaginatedMarketsResponse {
  final bool success;
  final String? message;
  final PaginatedMarketsData data;
  final String? timestamp;

  const PaginatedMarketsResponse({
    required this.success,
    this.message,
    required this.data,
    this.timestamp,
  });

  factory PaginatedMarketsResponse.fromJson(Map<String, dynamic> json) {
    // Handle null data field
    final dataJson = json['data'];
    if (dataJson == null) {
      throw FormatException('Response data field is null');
    }

    return PaginatedMarketsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: PaginatedMarketsData.fromJson(dataJson as Map<String, dynamic>),
      timestamp: json['timestamp'] as String?,
    );
  }

  Map<String, dynamic> toJson() => _$PaginatedMarketsResponseToJson(this);
}
