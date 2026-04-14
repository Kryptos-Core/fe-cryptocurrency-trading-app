/// Shared price and volume formatting utilities for market displays.
///
/// Centralises the decimal-tier logic used across [MarketRow] and
/// [MarketDetailScreen] so the same rules apply everywhere.
abstract final class PriceFormatter {
  PriceFormatter._();

  /// Format a price value with tier-based decimal precision.
  ///
  /// Tiers:
  /// - `>= 10 000` → 1 decimal  (e.g. BTC: 66 088.7)
  /// - `>= 1 000`  → 2 decimals (e.g. ETH: 3 412.50)
  /// - `>= 1`      → 2 decimals (e.g. LINK: 8.34)
  /// - `>= 0.01`   → 4 decimals (e.g. ADA: 0.2595)
  /// - `>= 0.0001` → 6 decimals (e.g. DOGE: 0.09208)
  /// - `< 0.0001`  → 8 decimals (e.g. meme coins: 0.00001234)
  ///
  /// Trailing zeros and a trailing decimal point are trimmed.
  static String formatPrice(double v) {
    if (v == 0) return '0';
    final int decimals;
    if (v >= 10000) {
      decimals = 1;
    } else if (v >= 1000) {
      decimals = 2;
    } else if (v >= 1) {
      decimals = 2;
    } else if (v >= 0.01) {
      decimals = 4;
    } else if (v >= 0.0001) {
      decimals = 6;
    } else {
      decimals = 8;
    }
    final formatted = v.toStringAsFixed(decimals);
    if (formatted.contains('.')) {
      return formatted
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
    return formatted;
  }

  /// Parse a price string and format it; returns the original string on
  /// parse failure (instead of crashing).
  static String formatPriceStr(String priceStr) {
    final v = double.tryParse(priceStr);
    if (v == null) return priceStr;
    return formatPrice(v);
  }

  /// Format a volume value with K / M / B suffix.
  ///
  /// - `>= 1 000 000 000` → `X.XXB`
  /// - `>= 1 000 000`     → `X.XXM`
  /// - `>= 1 000`         → `X.XXK`
  /// - `< 1 000`          → up to 4 significant decimals, trailing zeros trimmed
  static String formatVolume(double v) {
    if (v == 0) return '0';
    if (v >= 1e9) return '${(v / 1e9).toStringAsFixed(2)}B';
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(2)}M';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(2)}K';
    if (v >= 1) {
      return v
          .toStringAsFixed(2)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
    return v
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  /// Parse a volume string and format it; returns the original string on
  /// parse failure.
  static String formatVolumeStr(String volumeStr) {
    final v = double.tryParse(volumeStr);
    if (v == null) return volumeStr;
    return formatVolume(v);
  }
}
