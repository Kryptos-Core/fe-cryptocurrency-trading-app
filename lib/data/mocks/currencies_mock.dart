import 'package:crypto_trading_app/data/models/currency_model.dart';

/// Mock data for Currencies
class CurrenciesMock {
  static final List<CurrencyModel> mockCurrencies = [
    CurrencyModel(
      currencyId: 1,
      symbol: "BTC",
      name: "Bitcoin",
      precisionScale: 8,
      minWithdraw: "0.001",
      isTradable: true,
      isActive: true,
    ),
    CurrencyModel(
      currencyId: 2,
      symbol: "ETH",
      name: "Ethereum",
      precisionScale: 8,
      minWithdraw: "0.01",
      isTradable: true,
      isActive: true,
    ),
    CurrencyModel(
      currencyId: 3,
      symbol: "USDT",
      name: "Tether",
      precisionScale: 6,
      minWithdraw: "10",
      isTradable: true,
      isActive: true,
    ),
    CurrencyModel(
      currencyId: 4,
      symbol: "BNB",
      name: "Binance Coin",
      precisionScale: 8,
      minWithdraw: "0.1",
      isTradable: true,
      isActive: true,
    ),
    CurrencyModel(
      currencyId: 5,
      symbol: "ADA",
      name: "Cardano",
      precisionScale: 8,
      minWithdraw: "1",
      isTradable: true,
      isActive: true,
    ),
    CurrencyModel(
      currencyId: 6,
      symbol: "DOT",
      name: "Polkadot",
      precisionScale: 8,
      minWithdraw: "1",
      isTradable: true,
      isActive: true,
    ),
    CurrencyModel(
      currencyId: 7,
      symbol: "SOL",
      name: "Solana",
      precisionScale: 8,
      minWithdraw: "0.1",
      isTradable: true,
      isActive: true,
    ),
    CurrencyModel(
      currencyId: 8,
      symbol: "XRP",
      name: "Ripple",
      precisionScale: 6,
      minWithdraw: "10",
      isTradable: true,
      isActive: true,
    ),
  ];

  /// Get mock currency by ID
  static CurrencyModel? getById(int currencyId) {
    try {
      return mockCurrencies.firstWhere((c) => c.currencyId == currencyId);
    } catch (e) {
      return null;
    }
  }

  /// Get mock currency by symbol
  static CurrencyModel? getBySymbol(String symbol) {
    try {
      return mockCurrencies.firstWhere((c) => c.symbol.toUpperCase() == symbol.toUpperCase());
    } catch (e) {
      return null;
    }
  }

  /// Filter currencies
  static List<CurrencyModel> filter({
    bool? isActive,
    bool? isTradable,
  }) {
    var filtered = List<CurrencyModel>.from(mockCurrencies);

    if (isActive != null) {
      filtered = filtered.where((c) => c.isActive == isActive).toList();
    }

    if (isTradable != null) {
      filtered = filtered.where((c) => c.isTradable == isTradable).toList();
    }

    return filtered;
  }
}
