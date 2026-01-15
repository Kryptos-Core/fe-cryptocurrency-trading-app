import 'currency.dart';

/// Market Pair entity representing a trading pair
/// Following Clean Architecture - Domain Layer
class MarketPair {
  final int pairId;
  final String symbol;
  final Currency baseCurrency;
  final Currency quoteCurrency;
  final int priceScale;
  final int amountScale;
  final String minOrderAmount;
  final String makerFeeRate;
  final String takerFeeRate;
  final bool isActive;
  final DateTime createdAt;

  const MarketPair({
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

  MarketPair copyWith({
    int? pairId,
    String? symbol,
    Currency? baseCurrency,
    Currency? quoteCurrency,
    int? priceScale,
    int? amountScale,
    String? minOrderAmount,
    String? makerFeeRate,
    String? takerFeeRate,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return MarketPair(
      pairId: pairId ?? this.pairId,
      symbol: symbol ?? this.symbol,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      quoteCurrency: quoteCurrency ?? this.quoteCurrency,
      priceScale: priceScale ?? this.priceScale,
      amountScale: amountScale ?? this.amountScale,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      makerFeeRate: makerFeeRate ?? this.makerFeeRate,
      takerFeeRate: takerFeeRate ?? this.takerFeeRate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketPair &&
          runtimeType == other.runtimeType &&
          pairId == other.pairId;

  @override
  int get hashCode => pairId.hashCode;

  @override
  String toString() {
    return 'MarketPair(pairId: $pairId, symbol: $symbol, isActive: $isActive)';
  }
}

/// Market Ticker entity representing real-time market data
class MarketTicker {
  final int pairId;
  final String symbol;
  final String lastPrice;
  final String openPrice;
  final String highPrice;
  final String lowPrice;
  final String volume;
  final String change24h;
  final String changePercent24h;
  final DateTime timestamp;

  const MarketTicker({
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

  /// Check if price increased (positive change)
  bool get isPositive {
    final change = double.tryParse(changePercent24h) ?? 0.0;
    return change >= 0;
  }

  MarketTicker copyWith({
    int? pairId,
    String? symbol,
    String? lastPrice,
    String? openPrice,
    String? highPrice,
    String? lowPrice,
    String? volume,
    String? change24h,
    String? changePercent24h,
    DateTime? timestamp,
  }) {
    return MarketTicker(
      pairId: pairId ?? this.pairId,
      symbol: symbol ?? this.symbol,
      lastPrice: lastPrice ?? this.lastPrice,
      openPrice: openPrice ?? this.openPrice,
      highPrice: highPrice ?? this.highPrice,
      lowPrice: lowPrice ?? this.lowPrice,
      volume: volume ?? this.volume,
      change24h: change24h ?? this.change24h,
      changePercent24h: changePercent24h ?? this.changePercent24h,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'MarketTicker(symbol: $symbol, lastPrice: $lastPrice, changePercent24h: $changePercent24h%)';
  }
}

/// Order Book Item entity
class OrderBookItem {
  final String price;
  final String amount;
  final String total;

  const OrderBookItem({
    required this.price,
    required this.amount,
    required this.total,
  });

  OrderBookItem copyWith({
    String? price,
    String? amount,
    String? total,
  }) {
    return OrderBookItem(
      price: price ?? this.price,
      amount: amount ?? this.amount,
      total: total ?? this.total,
    );
  }

  @override
  String toString() {
    return 'OrderBookItem(price: $price, amount: $amount, total: $total)';
  }
}

/// Order Book entity
class OrderBook {
  final int pairId;
  final String symbol;
  final List<OrderBookItem> bids;
  final List<OrderBookItem> asks;
  final DateTime timestamp;

  const OrderBook({
    required this.pairId,
    required this.symbol,
    required this.bids,
    required this.asks,
    required this.timestamp,
  });

  OrderBook copyWith({
    int? pairId,
    String? symbol,
    List<OrderBookItem>? bids,
    List<OrderBookItem>? asks,
    DateTime? timestamp,
  }) {
    return OrderBook(
      pairId: pairId ?? this.pairId,
      symbol: symbol ?? this.symbol,
      bids: bids ?? this.bids,
      asks: asks ?? this.asks,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'OrderBook(symbol: $symbol, bids: ${bids.length}, asks: ${asks.length})';
  }
}

/// OHLCV (Open, High, Low, Close, Volume) entity for candlestick charts
class OHLCV {
  final int pairId;
  final int intervalSec;
  final DateTime openTime;
  final String open;
  final String high;
  final String low;
  final String close;
  final String volume;

  const OHLCV({
    required this.pairId,
    required this.intervalSec,
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  /// Check if candle is bullish (close > open)
  bool get isBullish {
    final closeValue = double.tryParse(close) ?? 0;
    final openValue = double.tryParse(open) ?? 0;
    return closeValue > openValue;
  }

  OHLCV copyWith({
    int? pairId,
    int? intervalSec,
    DateTime? openTime,
    String? open,
    String? high,
    String? low,
    String? close,
    String? volume,
  }) {
    return OHLCV(
      pairId: pairId ?? this.pairId,
      intervalSec: intervalSec ?? this.intervalSec,
      openTime: openTime ?? this.openTime,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
    );
  }

  @override
  String toString() {
    return 'OHLCV(pairId: $pairId, open: $open, high: $high, low: $low, close: $close, volume: $volume)';
  }
}
