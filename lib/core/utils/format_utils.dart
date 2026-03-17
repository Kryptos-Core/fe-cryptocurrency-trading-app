import 'package:intl/intl.dart';

/// Centralized formatting utilities for display values.
/// Uses the `intl` package (already in pubspec).
class FormatUtils {
  FormatUtils._();

  static final NumberFormat _compactFormat =
      NumberFormat.compact(locale: 'en_US');

  static final NumberFormat _usdFull =
      NumberFormat('#,##0.00', 'en_US');

  static final NumberFormat _percentFormat =
      NumberFormat('+#,##0.00;-#,##0.00', 'en_US');

  /// Portfolio total and large USD values: "$12,345.67"
  /// For very small prices (micro-cap), shows up to 6 decimal places.
  static String formatUsdValue(double value) {
    if (value == 0) return '\$0.00';
    if (value.abs() < 0.01 && value.abs() > 0) {
      // Micro-cap: show 6 significant decimals
      return '\$${value.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')}';
    }
    return '\$${_usdFull.format(value)}';
  }

  /// Compact volume: 1200000 → "1.2M", 45300 → "45.3K", 234 → "234"
  static String formatCompactVolume(double value) {
    if (value == 0) return '0';
    return _compactFormat.format(value);
  }

  /// Percentage change with sign: 2.5 → "+2.50%", -1.3 → "-1.30%"
  static String formatPriceChange(double pct) {
    return '${_percentFormat.format(pct)}%';
  }

  /// Format crypto balance respecting the currency's precision scale.
  /// Strips trailing zeros for clean display.
  static String formatCryptoBalance(double value, int scale) {
    if (value == 0) return '0';
    final formatted = value.toStringAsFixed(scale);
    return formatted
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  /// Format portfolio total with compact notation for large values.
  /// < 10K: "$1,234.56" — ≥ 10K: "$12.3K"
  static String formatPortfolioTotal(double value) {
    if (value >= 10000) {
      return '\$${_compactFormat.format(value)}';
    }
    return formatUsdValue(value);
  }
}
