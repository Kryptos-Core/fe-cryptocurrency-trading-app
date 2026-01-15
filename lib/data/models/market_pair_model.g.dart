// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_pair_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketPairModel _$MarketPairModelFromJson(Map<String, dynamic> json) =>
    MarketPairModel(
      pairId: (json['pair_id'] as num).toInt(),
      symbol: json['symbol'] as String,
      baseCurrency:
          CurrencyModel.fromJson(json['base_currency'] as Map<String, dynamic>),
      quoteCurrency: CurrencyModel.fromJson(
          json['quote_currency'] as Map<String, dynamic>),
      priceScale: (json['price_scale'] as num).toInt(),
      amountScale: (json['amount_scale'] as num).toInt(),
      minOrderAmount: json['min_order_amount'] as String,
      makerFeeRate: json['maker_fee_rate'] as String,
      takerFeeRate: json['taker_fee_rate'] as String,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$MarketPairModelToJson(MarketPairModel instance) =>
    <String, dynamic>{
      'pair_id': instance.pairId,
      'symbol': instance.symbol,
      'base_currency': instance.baseCurrency,
      'quote_currency': instance.quoteCurrency,
      'price_scale': instance.priceScale,
      'amount_scale': instance.amountScale,
      'min_order_amount': instance.minOrderAmount,
      'maker_fee_rate': instance.makerFeeRate,
      'taker_fee_rate': instance.takerFeeRate,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
    };

MarketTickerModel _$MarketTickerModelFromJson(Map<String, dynamic> json) =>
    MarketTickerModel(
      pairId: (json['pair_id'] as num).toInt(),
      symbol: json['symbol'] as String,
      lastPrice: json['last_price'] as String,
      openPrice: json['open_price'] as String,
      highPrice: json['high_price'] as String,
      lowPrice: json['low_price'] as String,
      volume: json['volume'] as String,
      change24h: json['change_24h'] as String,
      changePercent24h: json['change_percent_24h'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$MarketTickerModelToJson(MarketTickerModel instance) =>
    <String, dynamic>{
      'pair_id': instance.pairId,
      'symbol': instance.symbol,
      'last_price': instance.lastPrice,
      'open_price': instance.openPrice,
      'high_price': instance.highPrice,
      'low_price': instance.lowPrice,
      'volume': instance.volume,
      'change_24h': instance.change24h,
      'change_percent_24h': instance.changePercent24h,
      'timestamp': instance.timestamp.toIso8601String(),
    };

OrderBookItemModel _$OrderBookItemModelFromJson(Map<String, dynamic> json) =>
    OrderBookItemModel(
      price: json['price'] as String,
      amount: json['amount'] as String,
      total: json['total'] as String,
    );

Map<String, dynamic> _$OrderBookItemModelToJson(OrderBookItemModel instance) =>
    <String, dynamic>{
      'price': instance.price,
      'amount': instance.amount,
      'total': instance.total,
    };

OrderBookModel _$OrderBookModelFromJson(Map<String, dynamic> json) =>
    OrderBookModel(
      pairId: (json['pair_id'] as num).toInt(),
      symbol: json['symbol'] as String,
      bids: (json['bids'] as List<dynamic>)
          .map((e) => OrderBookItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      asks: (json['asks'] as List<dynamic>)
          .map((e) => OrderBookItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$OrderBookModelToJson(OrderBookModel instance) =>
    <String, dynamic>{
      'pair_id': instance.pairId,
      'symbol': instance.symbol,
      'bids': instance.bids,
      'asks': instance.asks,
      'timestamp': instance.timestamp.toIso8601String(),
    };

OHLCVModel _$OHLCVModelFromJson(Map<String, dynamic> json) => OHLCVModel(
      pairId: (json['pair_id'] as num).toInt(),
      intervalSec: (json['interval_sec'] as num).toInt(),
      openTime: DateTime.parse(json['open_time'] as String),
      open: json['open'] as String,
      high: json['high'] as String,
      low: json['low'] as String,
      close: json['close'] as String,
      volume: json['volume'] as String,
    );

Map<String, dynamic> _$OHLCVModelToJson(OHLCVModel instance) =>
    <String, dynamic>{
      'pair_id': instance.pairId,
      'interval_sec': instance.intervalSec,
      'open_time': instance.openTime.toIso8601String(),
      'open': instance.open,
      'high': instance.high,
      'low': instance.low,
      'close': instance.close,
      'volume': instance.volume,
    };
