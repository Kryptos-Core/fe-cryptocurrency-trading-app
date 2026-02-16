// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_pair_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketPairModel _$MarketPairModelFromJson(Map<String, dynamic> json) =>
    MarketPairModel(
      pairId: json['pair_id'] as String,
      baseCurrencyId: json['base_currency_id'] as String,
      quoteCurrencyId: json['quote_currency_id'] as String,
      symbol: json['symbol'] as String,
      baseCurrency: json['base_currency'] == null
          ? null
          : CurrencyModel.fromJson(
              json['base_currency'] as Map<String, dynamic>),
      quoteCurrency: json['quote_currency'] == null
          ? null
          : CurrencyModel.fromJson(
              json['quote_currency'] as Map<String, dynamic>),
      priceScale: (json['price_scale'] as num).toInt(),
      amountScale: (json['amount_scale'] as num).toInt(),
      minOrderAmount: json['min_order_amount'] as String,
      makerFeeRate: json['maker_fee_rate'] as String,
      takerFeeRate: json['taker_fee_rate'] as String,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$MarketPairModelToJson(MarketPairModel instance) =>
    <String, dynamic>{
      'pair_id': instance.pairId,
      'base_currency_id': instance.baseCurrencyId,
      'quote_currency_id': instance.quoteCurrencyId,
      'symbol': instance.symbol,
      'base_currency': instance.baseCurrency,
      'quote_currency': instance.quoteCurrency,
      'price_scale': instance.priceScale,
      'amount_scale': instance.amountScale,
      'min_order_amount': instance.minOrderAmount,
      'maker_fee_rate': instance.makerFeeRate,
      'taker_fee_rate': instance.takerFeeRate,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
    };

MarketTickerModel _$MarketTickerModelFromJson(Map<String, dynamic> json) =>
    MarketTickerModel(
      pairId: json['pairId'] as String,
      symbol: json['symbol'] as String,
      lastPrice: json['lastPrice'] as String,
      open24h: json['open24h'] as String,
      high24h: json['high24h'] as String,
      low24h: json['low24h'] as String,
      volume24h: json['volume24h'] as String,
      quoteVolume24h: json['quoteVolume24h'] as String,
      change24h: json['change24h'] as String,
      changeAmount24h: json['changeAmount24h'] as String,
      bestBid: json['bestBid'] as String,
      bestAsk: json['bestAsk'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$MarketTickerModelToJson(MarketTickerModel instance) =>
    <String, dynamic>{
      'pairId': instance.pairId,
      'symbol': instance.symbol,
      'lastPrice': instance.lastPrice,
      'open24h': instance.open24h,
      'high24h': instance.high24h,
      'low24h': instance.low24h,
      'volume24h': instance.volume24h,
      'quoteVolume24h': instance.quoteVolume24h,
      'change24h': instance.change24h,
      'changeAmount24h': instance.changeAmount24h,
      'bestBid': instance.bestBid,
      'bestAsk': instance.bestAsk,
      'timestamp': instance.timestamp.toIso8601String(),
    };

OrderBookItemModel _$OrderBookItemModelFromJson(Map<String, dynamic> json) =>
    OrderBookItemModel(
      price: json['price'] as String,
      amount: json['amount'] as String,
      total: json['total'] as String?,
      orders: (json['orders'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OrderBookItemModelToJson(OrderBookItemModel instance) =>
    <String, dynamic>{
      'price': instance.price,
      'amount': instance.amount,
      'total': instance.total,
      'orders': instance.orders,
    };

OrderBookModel _$OrderBookModelFromJson(Map<String, dynamic> json) =>
    OrderBookModel(
      pairId: json['pairId'] as String,
      symbol: json['symbol'] as String,
      bids: (json['bids'] as List<dynamic>)
          .map((e) => OrderBookItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      asks: (json['asks'] as List<dynamic>)
          .map((e) => OrderBookItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      bidLevels: (json['bidLevels'] as num).toInt(),
      askLevels: (json['askLevels'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$OrderBookModelToJson(OrderBookModel instance) =>
    <String, dynamic>{
      'pairId': instance.pairId,
      'symbol': instance.symbol,
      'bids': instance.bids,
      'asks': instance.asks,
      'bidLevels': instance.bidLevels,
      'askLevels': instance.askLevels,
      'timestamp': instance.timestamp.toIso8601String(),
    };

OHLCVModel _$OHLCVModelFromJson(Map<String, dynamic> json) => OHLCVModel(
      pairId: json['pair_id'] as String,
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
