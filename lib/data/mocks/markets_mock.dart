import 'package:crypto_trading_app/data/models/market_pair_model.dart';
import 'package:crypto_trading_app/data/models/currency_model.dart';
import 'currencies_mock.dart';

/// Mock data for Markets
class MarketsMock {
  static final List<MarketPairModel> mockMarketPairs = [
    MarketPairModel(
      pairId: 1,
      baseCurrencyId: 1,
      quoteCurrencyId: 3,
      symbol: "BTC/USDT",
      baseCurrency: CurrenciesMock.getBySymbol("BTC"),
      quoteCurrency: CurrenciesMock.getBySymbol("USDT"),
      priceScale: 2,
      amountScale: 6,
      minOrderAmount: "0.0001",
      makerFeeRate: "0.001",
      takerFeeRate: "0.001",
      isActive: true,
      createdAt: DateTime.parse("2024-01-01T00:00:00.000Z"),
    ),
    MarketPairModel(
      pairId: 2,
      baseCurrencyId: 2,
      quoteCurrencyId: 3,
      symbol: "ETH/USDT",
      baseCurrency: CurrenciesMock.getBySymbol("ETH"),
      quoteCurrency: CurrenciesMock.getBySymbol("USDT"),
      priceScale: 2,
      amountScale: 6,
      minOrderAmount: "0.01",
      makerFeeRate: "0.001",
      takerFeeRate: "0.001",
      isActive: true,
      createdAt: DateTime.parse("2024-01-01T00:00:00.000Z"),
    ),
    MarketPairModel(
      pairId: 3,
      baseCurrencyId: 3,
      quoteCurrencyId: 3,
      symbol: "BNB/USDT",
      baseCurrency: CurrenciesMock.getBySymbol("BNB"),
      quoteCurrency: CurrenciesMock.getBySymbol("USDT"),
      priceScale: 2,
      amountScale: 6,
      minOrderAmount: "0.1",
      makerFeeRate: "0.001",
      takerFeeRate: "0.001",
      isActive: true,
      createdAt: DateTime.parse("2024-01-01T00:00:00.000Z"),
    ),
    MarketPairModel(
      pairId: 4,
      baseCurrencyId: 6,
      quoteCurrencyId: 3,
      symbol: "ADA/USDT",
      baseCurrency: CurrenciesMock.getBySymbol("ADA"),
      quoteCurrency: CurrenciesMock.getBySymbol("USDT"),
      priceScale: 4,
      amountScale: 2,
      minOrderAmount: "10",
      makerFeeRate: "0.001",
      takerFeeRate: "0.001",
      isActive: true,
      createdAt: DateTime.parse("2024-01-01T00:00:00.000Z"),
    ),
    MarketPairModel(
      pairId: 5,
      baseCurrencyId: 7,
      quoteCurrencyId: 3,
      symbol: "DOT/USDT",
      baseCurrency: CurrenciesMock.getBySymbol("DOT"),
      quoteCurrency: CurrenciesMock.getBySymbol("USDT"),
      priceScale: 2,
      amountScale: 4,
      minOrderAmount: "1",
      makerFeeRate: "0.001",
      takerFeeRate: "0.001",
      isActive: true,
      createdAt: DateTime.parse("2024-01-01T00:00:00.000Z"),
    ),
  ];

  /// Get mock market by ID
  static MarketPairModel? getById(int pairId) {
    try {
      return mockMarketPairs.firstWhere((m) => m.pairId == pairId);
    } catch (e) {
      return null;
    }
  }

  /// Get mock market by symbol
  static MarketPairModel? getBySymbol(String symbol) {
    try {
      return mockMarketPairs.firstWhere((m) => m.symbol == symbol);
    } catch (e) {
      return null;
    }
  }

  /// Filter markets
  static List<MarketPairModel> filter({
    bool? isActive,
    String? baseCurrency,
    String? quoteCurrency,
  }) {
    var filtered = List<MarketPairModel>.from(mockMarketPairs);

    if (isActive != null) {
      filtered = filtered.where((m) => m.isActive == isActive).toList();
    }

    if (baseCurrency != null) {
      filtered = filtered.where((m) => m.baseCurrency?.symbol.toUpperCase() == baseCurrency.toUpperCase()).toList();
    }

    if (quoteCurrency != null) {
      filtered = filtered.where((m) => m.quoteCurrency?.symbol.toUpperCase() == quoteCurrency.toUpperCase()).toList();
    }

    return filtered;
  }

  /// Generate mock ticker
  static MarketTickerModel generateTicker(int pairId, {double basePrice = 45000.0}) {
    final pair = getById(pairId);
    if (pair == null) {
      throw Exception('Market pair not found');
    }

    final lastPrice = basePrice + (basePrice * (0.01 * (2 * (DateTime.now().millisecond % 100) / 100 - 1)));
    final open24h = basePrice;
    final high24h = lastPrice + 500;
    final low24h = lastPrice - 500;
    final change = lastPrice - open24h;
    final changePercent = (change / open24h);
    final changeAmount24h = change.toStringAsFixed(2);
    final volume24h = (1000 + DateTime.now().millisecond % 500).toStringAsFixed(2);
    final quoteVolume24h = (double.parse(volume24h) * lastPrice).toStringAsFixed(2);
    final bestBid = (lastPrice - 0.5).toStringAsFixed(2);
    final bestAsk = (lastPrice + 0.5).toStringAsFixed(2);

    return MarketTickerModel(
      pairId: pairId,
      symbol: pair.symbol,
      lastPrice: lastPrice.toStringAsFixed(2),
      open24h: open24h.toStringAsFixed(2),
      high24h: high24h.toStringAsFixed(2),
      low24h: low24h.toStringAsFixed(2),
      volume24h: volume24h,
      quoteVolume24h: quoteVolume24h,
      change24h: changePercent.toStringAsFixed(4),
      changeAmount24h: changeAmount24h,
      bestBid: bestBid,
      bestAsk: bestAsk,
      timestamp: DateTime.now(),
    );
  }

  /// Generate mock order book
  static OrderBookModel generateOrderBook(int pairId, {double basePrice = 45000.0}) {
    final pair = getById(pairId);
    if (pair == null) {
      throw Exception('Market pair not found');
    }

    final bids = List.generate(10, (index) {
      final price = basePrice - (index * 0.5);
      final amount = (0.5 + index * 0.1).toStringAsFixed(6);
      final total = (price * double.parse(amount)).toStringAsFixed(2);
      return OrderBookItemModel(
        price: price.toStringAsFixed(2),
        amount: amount,
        total: total,
      );
    });

    final asks = List.generate(10, (index) {
      final price = basePrice + ((index + 1) * 0.5);
      final amount = (0.5 + index * 0.1).toStringAsFixed(6);
      final total = (price * double.parse(amount)).toStringAsFixed(2);
      return OrderBookItemModel(
        price: price.toStringAsFixed(2),
        amount: amount,
        total: total,
      );
    });

    return OrderBookModel(
      pairId: pairId,
      symbol: pair.symbol,
      bids: bids,
      asks: asks,
      bidLevels: bids.length,
      askLevels: asks.length,
      timestamp: DateTime.now(),
    );
  }

  /// Generate mock OHLCV data
  static List<OHLCVModel> generateOHLCV(int pairId, {int count = 100, double basePrice = 45000.0}) {
    final pair = getById(pairId);
    if (pair == null) {
      throw Exception('Market pair not found');
    }

    final data = <OHLCVModel>[];
    final now = DateTime.now();

    for (int i = count - 1; i >= 0; i--) {
      final openTime = now.subtract(Duration(hours: i));
      final open = basePrice + (basePrice * 0.01 * (i % 20 - 10) / 10);
      final high = open + (open * 0.02 * (i % 10) / 10);
      final low = open - (open * 0.02 * (i % 10) / 10);
      final close = low + (high - low) * (i % 10) / 10;
      final volume = (100 + i % 100).toStringAsFixed(2);

      data.add(OHLCVModel(
        pairId: pairId,
        intervalSec: 3600,
        openTime: openTime,
        open: open.toStringAsFixed(2),
        high: high.toStringAsFixed(2),
        low: low.toStringAsFixed(2),
        close: close.toStringAsFixed(2),
        volume: volume,
      ));
    }

    return data;
  }
}
