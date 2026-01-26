import 'package:json_annotation/json_annotation.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/data/models/currency_model.dart';

part 'market_pair_model.g.dart';

/// Market Pair Model (DTO)
@JsonSerializable()
class MarketPairModel {
  @JsonKey(name: 'pair_id')
  final int pairId;
  @JsonKey(name: 'base_currency_id')
  final int baseCurrencyId;
  @JsonKey(name: 'quote_currency_id')
  final int quoteCurrencyId;
  final String symbol;
  @JsonKey(name: 'base_currency')
  final CurrencyModel? baseCurrency; // Optional - may not be included
  @JsonKey(name: 'quote_currency')
  final CurrencyModel? quoteCurrency; // Optional - may not be included
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
  final DateTime? createdAt; // Optional

  const MarketPairModel({
    required this.pairId,
    required this.baseCurrencyId,
    required this.quoteCurrencyId,
    required this.symbol,
    this.baseCurrency,
    this.quoteCurrency,
    required this.priceScale,
    required this.amountScale,
    required this.minOrderAmount,
    required this.makerFeeRate,
    required this.takerFeeRate,
    required this.isActive,
    this.createdAt,
  });

  factory MarketPairModel.fromJson(Map<String, dynamic> json) =>
      _$MarketPairModelFromJson(json);

  Map<String, dynamic> toJson() => _$MarketPairModelToJson(this);

  MarketPair toEntity() {
    return MarketPair(
      pairId: pairId,
      baseCurrencyId: baseCurrencyId,
      quoteCurrencyId: quoteCurrencyId,
      symbol: symbol,
      baseCurrency: baseCurrency?.toEntity(),
      quoteCurrency: quoteCurrency?.toEntity(),
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
/// Following API documentation structure
@JsonSerializable()
class MarketTickerModel {
  @JsonKey(name: 'pairId')
  final int pairId;
  final String symbol;
  @JsonKey(name: 'lastPrice')
  final String lastPrice;
  @JsonKey(name: 'open24h')
  final String open24h;
  @JsonKey(name: 'high24h')
  final String high24h;
  @JsonKey(name: 'low24h')
  final String low24h;
  @JsonKey(name: 'volume24h')
  final String volume24h;
  @JsonKey(name: 'quoteVolume24h')
  final String quoteVolume24h;
  @JsonKey(name: 'change24h')
  final String change24h;
  @JsonKey(name: 'changeAmount24h')
  final String changeAmount24h;
  @JsonKey(name: 'bestBid')
  final String bestBid;
  @JsonKey(name: 'bestAsk')
  final String bestAsk;
  final DateTime timestamp;

  const MarketTickerModel({
    required this.pairId,
    required this.symbol,
    required this.lastPrice,
    required this.open24h,
    required this.high24h,
    required this.low24h,
    required this.volume24h,
    required this.quoteVolume24h,
    required this.change24h,
    required this.changeAmount24h,
    required this.bestBid,
    required this.bestAsk,
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
      open24h: open24h,
      high24h: high24h,
      low24h: low24h,
      volume24h: volume24h,
      quoteVolume24h: quoteVolume24h,
      change24h: change24h,
      changeAmount24h: changeAmount24h,
      bestBid: bestBid,
      bestAsk: bestAsk,
      timestamp: timestamp,
    );
  }
}

/// Order Book Item Model
@JsonSerializable()
class OrderBookItemModel {
  final String price;
  final String amount;
  final String? total; // Optional - may not be in API response
  final int? orders; // Number of orders at this price level

  const OrderBookItemModel({
    required this.price,
    required this.amount,
    this.total,
    this.orders,
  });

  factory OrderBookItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderBookItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderBookItemModelToJson(this);

  OrderBookItem toEntity() {
    return OrderBookItem(
      price: price,
      amount: amount,
      total: total,
      orders: orders,
    );
  }
}

/// Order Book Model
@JsonSerializable()
class OrderBookModel {
  @JsonKey(name: 'pairId')
  final int pairId;
  final String symbol;
  final List<OrderBookItemModel> bids; // Buy orders (sorted DESC by price)
  final List<OrderBookItemModel> asks; // Sell orders (sorted ASC by price)
  @JsonKey(name: 'bidLevels')
  final int bidLevels;
  @JsonKey(name: 'askLevels')
  final int askLevels;
  final DateTime timestamp;

  const OrderBookModel({
    required this.pairId,
    required this.symbol,
    required this.bids,
    required this.asks,
    required this.bidLevels,
    required this.askLevels,
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
      bidLevels: bidLevels,
      askLevels: askLevels,
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
