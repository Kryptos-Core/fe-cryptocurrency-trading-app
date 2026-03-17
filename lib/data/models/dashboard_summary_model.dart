import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/domain/entities/currency.dart';
import 'package:crypto_trading_app/domain/entities/wallet.dart';

/// Dashboard market item — combines MarketPair + MarketTicker fields
/// from the aggregated GET /api/v1/dashboard response.
class DashboardMarketItem {
  final String pairId;
  final String symbol;
  final int priceScale;
  final int amountScale;
  final String lastPrice;
  final String high24h;
  final String low24h;
  final String volume24h;
  final String quoteVolume24h;
  final String change24h;
  final String changeAmount24h;
  final String bestBid;
  final String bestAsk;
  final String open24h;
  final String timestamp;

  const DashboardMarketItem({
    required this.pairId,
    required this.symbol,
    required this.priceScale,
    required this.amountScale,
    required this.lastPrice,
    required this.high24h,
    required this.low24h,
    required this.volume24h,
    required this.quoteVolume24h,
    required this.change24h,
    required this.changeAmount24h,
    required this.bestBid,
    required this.bestAsk,
    required this.open24h,
    required this.timestamp,
  });

  factory DashboardMarketItem.fromJson(Map<String, dynamic> json) {
    return DashboardMarketItem(
      pairId: json['pairId']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      priceScale: (json['priceScale'] as num?)?.toInt() ?? 2,
      amountScale: (json['amountScale'] as num?)?.toInt() ?? 6,
      lastPrice: json['lastPrice']?.toString() ?? '0',
      high24h: json['high24h']?.toString() ?? '0',
      low24h: json['low24h']?.toString() ?? '0',
      volume24h: json['volume24h']?.toString() ?? '0',
      quoteVolume24h: json['quoteVolume24h']?.toString() ?? '0',
      change24h: json['change24h']?.toString() ?? '0',
      changeAmount24h: json['changeAmount24h']?.toString() ?? '0',
      bestBid: json['bestBid']?.toString() ?? '0',
      bestAsk: json['bestAsk']?.toString() ?? '0',
      open24h: json['open24h']?.toString() ?? '0',
      timestamp: json['timestamp']?.toString() ?? '',
    );
  }

  /// Convert to domain MarketPair (minimal, for use with MarketRow widget).
  /// Base/quote currencies are derived from symbol string (e.g. "BTC/USDT").
  MarketPair toMarketPair() {
    final parts = symbol.split('/');
    final baseSymbol = parts.isNotEmpty ? parts[0] : symbol;
    final quoteSymbol = parts.length > 1 ? parts[1] : '';

    final stubCurrency = Currency(
      currencyId: '',
      symbol: baseSymbol,
      name: baseSymbol,
      precisionScale: amountScale,
      minWithdraw: '0',
      isTradable: true,
      isActive: true,
    );

    final quoteCurrency = Currency(
      currencyId: '',
      symbol: quoteSymbol,
      name: quoteSymbol,
      precisionScale: priceScale,
      minWithdraw: '0',
      isTradable: true,
      isActive: true,
    );

    return MarketPair(
      pairId: pairId,
      baseCurrencyId: '',
      quoteCurrencyId: '',
      symbol: symbol,
      baseCurrency: stubCurrency,
      quoteCurrency: quoteCurrency,
      priceScale: priceScale,
      amountScale: amountScale,
      minOrderAmount: '0',
      makerFeeRate: '0',
      takerFeeRate: '0',
      isActive: true,
    );
  }

  /// Convert to domain MarketTicker (for use with MarketRow widget).
  MarketTicker toMarketTicker() {
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
      timestamp: DateTime.tryParse(timestamp) ?? DateTime.now(),
    );
  }
}

/// Dashboard wallet entry with estimated USD value.
class DashboardWalletItem {
  final String walletId;
  final String currencyId;
  final String currencySymbol;
  final String currencyName;
  final String available;
  final String frozen;
  final String total;
  final String usdValue;

  const DashboardWalletItem({
    required this.walletId,
    required this.currencyId,
    required this.currencySymbol,
    required this.currencyName,
    required this.available,
    required this.frozen,
    required this.total,
    required this.usdValue,
  });

  factory DashboardWalletItem.fromJson(Map<String, dynamic> json) {
    return DashboardWalletItem(
      walletId: json['walletId']?.toString() ?? '',
      currencyId: json['currencyId']?.toString() ?? '',
      currencySymbol: json['currencySymbol']?.toString() ?? '',
      currencyName: json['currencyName']?.toString() ?? '',
      available: json['available']?.toString() ?? '0',
      frozen: json['frozen']?.toString() ?? '0',
      total: json['total']?.toString() ?? '0',
      usdValue: json['usdValue']?.toString() ?? '0',
    );
  }

  /// Convert to domain Wallet for use with existing WalletCard widget.
  Wallet toWallet() {
    final currency = Currency(
      currencyId: currencyId,
      symbol: currencySymbol,
      name: currencyName,
      precisionScale: 8,
      minWithdraw: '0',
      isTradable: true,
      isActive: true,
    );

    return Wallet(
      walletId: walletId,
      userId: '',
      currency: currency,
      available: available,
      frozen: frozen,
      total: total,
      updatedAt: DateTime.now(),
    );
  }
}

/// Aggregated dashboard summary returned by GET /api/v1/dashboard.
class DashboardSummary {
  final String portfolioTotal;
  final int walletCount;
  final int activeWalletCount;
  final List<DashboardMarketItem> topMarkets;
  final List<DashboardWalletItem> wallets;

  const DashboardSummary({
    required this.portfolioTotal,
    required this.walletCount,
    required this.activeWalletCount,
    required this.topMarkets,
    required this.wallets,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final marketsJson = json['topMarkets'] as List<dynamic>? ?? [];
    final walletsJson = json['wallets'] as List<dynamic>? ?? [];
    return DashboardSummary(
      portfolioTotal: json['portfolioTotal']?.toString() ?? '0.00',
      walletCount: (json['walletCount'] as num?)?.toInt() ?? 0,
      activeWalletCount: (json['activeWalletCount'] as num?)?.toInt() ?? 0,
      topMarkets: marketsJson
          .map((e) => DashboardMarketItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      wallets: walletsJson
          .map((e) => DashboardWalletItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Empty state — no data loaded yet.
  static const DashboardSummary empty = DashboardSummary(
    portfolioTotal: '0.00',
    walletCount: 0,
    activeWalletCount: 0,
    topMarkets: [],
    wallets: [],
  );
}
