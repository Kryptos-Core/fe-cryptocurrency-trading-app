// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_pair_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketPairModel _$MarketPairModelFromJson(Map<String, dynamic> json) =>
    MarketPairModel(
      pairId: (json['pair_id'] as num?)?.toInt() ?? 0,
      baseCurrencyId: (json['base_currency_id'] as num?)?.toInt() ?? 0,
      quoteCurrencyId: (json['quote_currency_id'] as num?)?.toInt() ?? 0,
      symbol: json['symbol'] as String? ?? '',
      baseCurrency: json['base_currency'] == null
          ? null
          : CurrencyModel.fromJson(
              json['base_currency'] as Map<String, dynamic>),
      quoteCurrency: json['quote_currency'] == null
          ? null
          : CurrencyModel.fromJson(
              json['quote_currency'] as Map<String, dynamic>),
      priceScale: (json['price_scale'] as num?)?.toInt() ?? 8,
      amountScale: (json['amount_scale'] as num?)?.toInt() ?? 8,
      minOrderAmount: json['min_order_amount'] as String? ?? '0',
      makerFeeRate: json['maker_fee_rate'] as String? ?? '0',
      takerFeeRate: json['taker_fee_rate'] as String? ?? '0',
      isActive: json['is_active'] as bool? ?? true,
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
      pairId: (json['pairId'] as num?)?.toInt() ?? 0,
      symbol: json['symbol'] as String? ?? '',
      lastPrice: json['lastPrice'] as String? ?? '0',
      open24h: json['open24h'] as String? ?? '0',
      high24h: json['high24h'] as String? ?? '0',
      low24h: json['low24h'] as String? ?? '0',
      volume24h: json['volume24h'] as String? ?? '0',
      quoteVolume24h: json['quoteVolume24h'] as String? ?? '0',
      change24h: json['change24h'] as String? ?? '0',
      changeAmount24h: json['changeAmount24h'] as String? ?? '0',
      bestBid: json['bestBid'] as String? ?? '0',
      bestAsk: json['bestAsk'] as String? ?? '0',
      timestamp: DateTime.parse(
          json['timestamp'] as String? ?? DateTime.now().toIso8601String()),
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
      price: json['price'] as String? ?? '0',
      amount: json['amount'] as String? ?? '0',
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
      pairId: (json['pairId'] as num?)?.toInt() ?? 0,
      symbol: json['symbol'] as String? ?? '',
      bids: (json['bids'] as List<dynamic>?)
              ?.map(
                  (e) => OrderBookItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      asks: (json['asks'] as List<dynamic>?)
              ?.map(
                  (e) => OrderBookItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bidLevels: (json['bidLevels'] as num?)?.toInt() ?? 0,
      askLevels: (json['askLevels'] as num?)?.toInt() ?? 0,
      timestamp: DateTime.parse(
          json['timestamp'] as String? ?? DateTime.now().toIso8601String()),
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
      pairId: (json['pair_id'] as num?)?.toInt() ?? 0,
      intervalSec: (json['interval_sec'] as num?)?.toInt() ?? 0,
      openTime: DateTime.parse(
          json['open_time'] as String? ?? DateTime.now().toIso8601String()),
      open: json['open'] as String? ?? '0',
      high: json['high'] as String? ?? '0',
      low: json['low'] as String? ?? '0',
      close: json['close'] as String? ?? '0',
      volume: json['volume'] as String? ?? '0',
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
