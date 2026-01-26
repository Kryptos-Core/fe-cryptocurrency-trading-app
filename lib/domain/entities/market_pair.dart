import 'currency.dart';

/// Market Pair entity representing a trading pair
/// Following Clean Architecture - Domain Layer
class MarketPair {
  final int pairId;
  final int baseCurrencyId;
  final int quoteCurrencyId;
  final String symbol;
  final Currency? baseCurrency; // Optional - may not be included in all responses
  final Currency? quoteCurrency; // Optional - may not be included in all responses
  final int priceScale;
  final int amountScale;
  final String minOrderAmount;
  final String makerFeeRate;
  final String takerFeeRate;
  final bool isActive;
  final DateTime? createdAt; // Optional

  const MarketPair({
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

  MarketPair copyWith({
    int? pairId,
    int? baseCurrencyId,
    int? quoteCurrencyId,
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
      baseCurrencyId: baseCurrencyId ?? this.baseCurrencyId,
      quoteCurrencyId: quoteCurrencyId ?? this.quoteCurrencyId,
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
/// Following API documentation structure
class MarketTicker {
  final int pairId;
  final String symbol;
  final String lastPrice;
  final String open24h; // Opening price 24h ago
  final String high24h; // Highest price in 24h
  final String low24h; // Lowest price in 24h
  final String volume24h; // 24h volume in base currency
  final String quoteVolume24h; // 24h volume in quote currency
  final String change24h; // 24h price change percentage (e.g., "0.02" = 2%)
  final String changeAmount24h; // 24h price change amount
  final String bestBid; // Best bid price
  final String bestAsk; // Best ask price
  final DateTime timestamp;

  const MarketTicker({
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

  /// Check if price increased (positive change)
  bool get isPositive {
    final change = double.tryParse(change24h) ?? 0.0;
    return change >= 0;
  }

  /// Get change percentage as formatted string (e.g., "+2.5%" or "-1.2%")
  String get changePercentFormatted {
    final change = double.tryParse(change24h) ?? 0.0;
    final sign = change >= 0 ? '+' : '';
    return '$sign${(change * 100).toStringAsFixed(2)}%';
  }

  MarketTicker copyWith({
    int? pairId,
    String? symbol,
    String? lastPrice,
    String? open24h,
    String? high24h,
    String? low24h,
    String? volume24h,
    String? quoteVolume24h,
    String? change24h,
    String? changeAmount24h,
    String? bestBid,
    String? bestAsk,
    DateTime? timestamp,
  }) {
    return MarketTicker(
      pairId: pairId ?? this.pairId,
      symbol: symbol ?? this.symbol,
      lastPrice: lastPrice ?? this.lastPrice,
      open24h: open24h ?? this.open24h,
      high24h: high24h ?? this.high24h,
      low24h: low24h ?? this.low24h,
      volume24h: volume24h ?? this.volume24h,
      quoteVolume24h: quoteVolume24h ?? this.quoteVolume24h,
      change24h: change24h ?? this.change24h,
      changeAmount24h: changeAmount24h ?? this.changeAmount24h,
      bestBid: bestBid ?? this.bestBid,
      bestAsk: bestAsk ?? this.bestAsk,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'MarketTicker(symbol: $symbol, lastPrice: $lastPrice, change24h: $change24h)';
  }
}

/// Order Book Item entity
class OrderBookItem {
  final String price;
  final String amount;
  final String? total; // Optional - may not be in API response
  final int? orders; // Number of orders at this price level

  const OrderBookItem({
    required this.price,
    required this.amount,
    this.total,
    this.orders,
  });

  OrderBookItem copyWith({
    String? price,
    String? amount,
    String? total,
    int? orders,
  }) {
    return OrderBookItem(
      price: price ?? this.price,
      amount: amount ?? this.amount,
      total: total ?? this.total,
      orders: orders ?? this.orders,
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
  final List<OrderBookItem> bids; // Buy orders (sorted DESC by price)
  final List<OrderBookItem> asks; // Sell orders (sorted ASC by price)
  final int bidLevels; // Number of bid price levels
  final int askLevels; // Number of ask price levels
  final DateTime timestamp;

  const OrderBook({
    required this.pairId,
    required this.symbol,
    required this.bids,
    required this.asks,
    required this.bidLevels,
    required this.askLevels,
    required this.timestamp,
  });

  OrderBook copyWith({
    int? pairId,
    String? symbol,
    List<OrderBookItem>? bids,
    List<OrderBookItem>? asks,
    int? bidLevels,
    int? askLevels,
    DateTime? timestamp,
  }) {
    return OrderBook(
      pairId: pairId ?? this.pairId,
      symbol: symbol ?? this.symbol,
      bids: bids ?? this.bids,
      asks: asks ?? this.asks,
      bidLevels: bidLevels ?? this.bidLevels,
      askLevels: askLevels ?? this.askLevels,
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

/// Trade entity representing a recent trade
/// Following Clean Architecture - Domain Layer
class Trade {
  final int tradeId;
  final int pairId;
  final String price;
  final String amount;
  final TradeSide side; // BUY or SELL
  final DateTime createdAt;

  const Trade({
    required this.tradeId,
    required this.pairId,
    required this.price,
    required this.amount,
    required this.side,
    required this.createdAt,
  });

  /// Check if trade is a buy order
  bool get isBuy => side == TradeSide.buy;

  /// Check if trade is a sell order
  bool get isSell => side == TradeSide.sell;

  Trade copyWith({
    int? tradeId,
    int? pairId,
    String? price,
    String? amount,
    TradeSide? side,
    DateTime? createdAt,
  }) {
    return Trade(
      tradeId: tradeId ?? this.tradeId,
      pairId: pairId ?? this.pairId,
      price: price ?? this.price,
      amount: amount ?? this.amount,
      side: side ?? this.side,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Trade(tradeId: $tradeId, pairId: $pairId, price: $price, amount: $amount, side: $side)';
  }
}

/// Trade Side enum
enum TradeSide {
  buy,
  sell;

  static TradeSide fromString(String value) {
    switch (value.toUpperCase()) {
      case 'BUY':
        return TradeSide.buy;
      case 'SELL':
        return TradeSide.sell;
      default:
        throw ArgumentError('Invalid trade side: $value');
    }
  }

  String toApiString() {
    switch (this) {
      case TradeSide.buy:
        return 'BUY';
      case TradeSide.sell:
        return 'SELL';
    }
  }
}
