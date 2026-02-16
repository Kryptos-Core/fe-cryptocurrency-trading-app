import 'package:json_annotation/json_annotation.dart';
import 'package:crypto_trading_app/data/models/market_pair_model.dart';

part 'ohlcv_response.g.dart';

/// OHLCV Response Data
/// Following API response structure where candles are nested in data object
@JsonSerializable()
class OHLCVResponseData {
  @JsonKey(name: 'pair_id')
  final String pairId;
  final String interval; // "1h", "1d", etc.
  @JsonKey(name: 'interval_sec')
  final int intervalSec; // 3600 for 1h, 86400 for 1d, etc.
  final List<OHLCVModel> candles;

  const OHLCVResponseData({
    required this.pairId,
    required this.interval,
    required this.intervalSec,
    required this.candles,
  });

  factory OHLCVResponseData.fromJson(Map<String, dynamic> json) =>
      _$OHLCVResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$OHLCVResponseDataToJson(this);
}

/// OHLCV API Response
@JsonSerializable()
class OHLCVResponse {
  final bool success;
  final String? message;
  final OHLCVResponseData data;
  final String? timestamp;

  const OHLCVResponse({
    required this.success,
    this.message,
    required this.data,
    this.timestamp,
  });

  factory OHLCVResponse.fromJson(Map<String, dynamic> json) =>
      _$OHLCVResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OHLCVResponseToJson(this);
}
