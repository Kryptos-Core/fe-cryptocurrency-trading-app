/// Maps internal market pair symbols to TradingView exchange:symbol format.
///
/// TradingView widget expects symbols in the form `EXCHANGE:BASEQUOTE`,
/// e.g. `BINANCE:BTCUSDT`.
abstract final class TradingViewSymbolMapper {
  TradingViewSymbolMapper._();

  /// Convert an internal pair symbol to a TradingView `BINANCE:BASEQUOTE`
  /// string, or return `null` if the symbol cannot be reliably parsed.
  ///
  /// Handles common formats:
  /// - `BTCUSDT`   → `BINANCE:BTCUSDT`
  /// - `BTC/USDT`  → `BINANCE:BTCUSDT`
  /// - `BTC-USDT`  → `BINANCE:BTCUSDT`
  /// - `BTC_USDT`  → `BINANCE:BTCUSDT`
  static String? toTradingView(String symbol) {
    if (symbol.isEmpty) return null;

    // Normalise separators to nothing.
    final cleaned = symbol.toUpperCase().replaceAll(RegExp(r'[/_\-]'), '');
    if (cleaned.isEmpty) return null;

    // Validate: only letters and digits expected.
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(cleaned)) return null;

    // At least 4 characters needed (shortest: BNBBTC).
    if (cleaned.length < 4) return null;

    return 'BINANCE:$cleaned';
  }
}
