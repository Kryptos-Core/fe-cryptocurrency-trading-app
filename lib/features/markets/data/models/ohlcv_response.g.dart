// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ohlcv_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OHLCVResponseData _$OHLCVResponseDataFromJson(Map<String, dynamic> json) =>
    OHLCVResponseData(
      pairId: json['pair_id'] as String,
      interval: json['interval'] as String,
      intervalSec: (json['interval_sec'] as num).toInt(),
      candles: (json['candles'] as List<dynamic>)
          .map((e) => OHLCVModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OHLCVResponseDataToJson(OHLCVResponseData instance) =>
    <String, dynamic>{
      'pair_id': instance.pairId,
      'interval': instance.interval,
      'interval_sec': instance.intervalSec,
      'candles': instance.candles,
    };

OHLCVResponse _$OHLCVResponseFromJson(Map<String, dynamic> json) =>
    OHLCVResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: OHLCVResponseData.fromJson(json['data'] as Map<String, dynamic>),
      timestamp: json['timestamp'] as String?,
    );

Map<String, dynamic> _$OHLCVResponseToJson(OHLCVResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'timestamp': instance.timestamp,
    };
