import 'package:intl/intl.dart';

/// Centralized formatting utilities for display values.
/// Uses the `intl` package (already in pubspec).
class FormatUtils {
  FormatUtils._();

  static final NumberFormat _compactFormat =
      NumberFormat.compact(locale: 'en_US');

  static final NumberFormat _usdFull =
      NumberFormat('#,##0.00', 'en_US');

  /// USDT/USDC-style totals: "10,000.40" (thousands separator, 2 decimals).
  static String formatQuoteAmount(double value) {
    return _usdFull.format(value);
  }

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

  static final NumberFormat _thousandsInt = NumberFormat('#,###');

  /// Fiat whole amounts (e.g. PayOS VND): strip fractional noise, thousands separator.
  /// Matches deposits input style (`#,###`).
  /// Uses the substring before `.` when present so long Decimal strings from the API
  /// never flow through [double] precision limits.
  static String formatFiatIntegerDisplay(String amountStr) {
    var s = amountStr.replaceAll(',', '').trim();
    if (s.isEmpty) return amountStr;
    final dot = s.indexOf('.');
    if (dot >= 0) {
      s = s.substring(0, dot);
    }
    if (s.isEmpty) return amountStr;
    final asInt = int.tryParse(s);
    if (asInt != null) {
      return _thousandsInt.format(asInt);
    }
    final n = double.tryParse(amountStr.replaceAll(',', '').trim());
    if (n == null) return amountStr;
    return _thousandsInt.format(n.round());
  }

  static final NumberFormat _decimalUpTo8 = NumberFormat('#,##0.########', 'en_US');

  /// Crypto / on-chain / order sizes: thousands separator, up to 8 decimals, trim trailing zeros.
  /// Aligns with [orders_screen] `_formatAmountDisplay` and wallet-style readability.
  static String formatDecimalAmountDisplay(String amountStr) {
    final v = double.tryParse(amountStr.replaceAll(',', '').trim());
    if (v == null) return amountStr;
    if (v == 0) return '0';
    var s = _decimalUpTo8.format(v);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  /// Formats a decimal string from the API for list/detail UI without showing
  /// long runs of trailing zeros. Caps fractional digits at [maxFractionDigits]
  /// (e.g. currency [precisionScale]) while keeping thousands separators via
  /// [formatDecimalAmountDisplay] when the value fits in double.
  static String formatDecimalAmountForScale(
    String amountStr,
    int maxFractionDigits,
  ) {
    var raw = amountStr.replaceAll(',', '').trim();
    if (raw.isEmpty) return amountStr;

    final negative = raw.startsWith('-');
    if (negative) raw = raw.substring(1);

    final dot = raw.indexOf('.');
    String intPart;
    String fracPart;
    if (dot < 0) {
      intPart = raw.isEmpty ? '0' : raw;
      fracPart = '';
    } else {
      intPart = raw.substring(0, dot);
      fracPart = raw.substring(dot + 1);
    }
    if (intPart.isEmpty) intPart = '0';

    if (maxFractionDigits >= 0 && fracPart.length > maxFractionDigits) {
      fracPart = fracPart.substring(0, maxFractionDigits);
    }
    fracPart = fracPart.replaceAll(RegExp(r'0+$'), '');

    final core = fracPart.isEmpty ? intPart : '$intPart.$fracPart';
    final signed = negative ? '-$core' : core;

    final v = double.tryParse(signed);
    if (v != null) {
      return formatDecimalAmountDisplay(signed);
    }
    return signed;
  }
}
