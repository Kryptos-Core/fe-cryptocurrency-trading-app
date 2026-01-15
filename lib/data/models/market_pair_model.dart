import 'package:json_annotation/json_annotation.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/data/models/currency_model.dart';

part 'market_pair_model.g.dart';

/// Market Pair Model (DTO)
@JsonSerializable()
class MarketPairModel {
  @JsonKey(name: 'pair_id')
  final int pairId;
  final String symbol;
  @JsonKey(name: 'base_currency')
  final CurrencyModel baseCurrency;
  @JsonKey(name: 'quote_currency')
  final CurrencyModel quoteCurrency;
  @JsonKey(name: 'price_scale')
  final int priceScale;
  @JsonKey(name: 'amount_scale')
  final int amountScale;
  @JsonKey(name: 'min_order_amount')
  final String minOrderAmount;
  @JsonKey(name: 'maker_fee_rate')
  final String makerFeeRate;
  @JsonKey(name: 'taker_fee_rate')
  final String takerFeeRate;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const MarketPairModel({
    required this.pairId,
    required this.symbol,
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.priceScale,
    required this.amountScale,
    required this.minOrderAmount,
    required this.makerFeeRate,
    required this.takerFeeRate,
    required this.isActive,
    required this.createdAt,
  });

  factory MarketPairModel.fromJson(Map<String, dynamic> json) =>
      _$MarketPairModelFromJson(json);

  Map<String, dynamic> toJson() => _$MarketPairModelToJson(this);

  MarketPair toEntity() {
    return MarketPair(
      pairId: pairId,
      symbol: symbol,
      baseCurrency: baseCurrency.toEntity(),
      quoteCurrency: quoteCurrency.toEntity(),
      priceScale: priceScale,
      amountScale: amountScale,
      minOrderAmount: minOrderAmount,
      makerFeeRate: makerFeeRate,
      takerFeeRate: takerFeeRate,
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}

/// Market Ticker Model
@JsonSerializable()
class MarketTickerModel {
  @JsonKey(name: 'pair_id')
  final int pairId;
  final String symbol;
  @JsonKey(name: 'last_price')
  final String lastPrice;
  @JsonKey(name: 'open_price')
  final String openPrice;
  @JsonKey(name: 'high_price')
  final String highPrice;
  @JsonKey(name: 'low_price')
  final String lowPrice;
  final String volume;
  @JsonKey(name: 'change_24h')
  final String change24h;
  @JsonKey(name: 'change_percent_24h')
  final String changePercent24h;
  final DateTime timestamp;

  const MarketTickerModel({
    required this.pairId,
    required this.symbol,
    required this.lastPrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
    required this.change24h,
    required this.changePercent24h,
    required this.timestamp,
  });

  factory MarketTickerModel.fromJson(Map<String, dynamic> json) =>
      _$MarketTickerModelFromJson(json);

  Map<String, dynamic> toJson() => _$MarketTickerModelToJson(this);

  MarketTicker toEntity() {
    return MarketTicker(
      pairId: pairId,
      symbol: symbol,
      lastPrice: lastPrice,
      openPrice: openPrice,
      highPrice: highPrice,
      lowPrice: lowPrice,
      volume: volume,
      change24h: change24h,
      changePercent24h: changePercent24h,
      timestamp: timestamp,
    );
  }
}

/// Order Book Item Model
@JsonSerializable()
class OrderBookItemModel {
  final String price;
  final String amount;
  final String total;

  const OrderBookItemModel({
    required this.price,
    required this.amount,
    required this.total,
  });

  factory OrderBookItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderBookItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderBookItemModelToJson(this);

  OrderBookItem toEntity() {
    return OrderBookItem(
      price: price,
      amount: amount,
      total: total,
    );
  }
}

/// Order Book Model
@JsonSerializable()
class OrderBookModel {
  @JsonKey(name: 'pair_id')
  final int pairId;
  final String symbol;
  final List<OrderBookItemModel> bids;
  final List<OrderBookItemModel> asks;
  final DateTime timestamp;

  const OrderBookModel({
    required this.pairId,
    required this.symbol,
    required this.bids,
    required this.asks,
    required this.timestamp,
  });

  factory OrderBookModel.fromJson(Map<String, dynamic> json) =>
      _$OrderBookModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderBookModelToJson(this);

  OrderBook toEntity() {
    return OrderBook(
      pairId: pairId,
      symbol: symbol,
      bids: bids.map((b) => b.toEntity()).toList(),
      asks: asks.map((a) => a.toEntity()).toList(),
      timestamp: timestamp,
    );
  }
}

/// OHLCV Model
@JsonSerializable()
class OHLCVModel {
  @JsonKey(name: 'pair_id')
  final int pairId;
  @JsonKey(name: 'interval_sec')
  final int intervalSec;
  @JsonKey(name: 'open_time')
  final DateTime openTime;
  final String open;
  final String high;
  final String low;
  final String close;
  final String volume;

  const OHLCVModel({
    required this.pairId,
    required this.intervalSec,
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory OHLCVModel.fromJson(Map<String, dynamic> json) =>
      _$OHLCVModelFromJson(json);

  Map<String, dynamic> toJson() => _$OHLCVModelToJson(this);

  OHLCV toEntity() {
    return OHLCV(
      pairId: pairId,
      intervalSec: intervalSec,
      openTime: openTime,
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    );
  }
}
