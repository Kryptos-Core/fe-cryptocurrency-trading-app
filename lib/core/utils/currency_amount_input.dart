import 'package:flutter/material.dart';

/// Chuẩn hóa hiển thị đơn vị tiền tệ trên các ô nhập số tiền / khối lượng.
///
/// Dùng [withCurrencySuffix] để thêm [InputDecoration.suffixText] + style nổi bật,
/// giúp người dùng luôn thấy rõ đang nhập theo đơn vị nào (USDT, BTC, TRX, …).
class CurrencyAmountInput {
  CurrencyAmountInput._();

  /// Style mặc định cho hậu tố đơn vị (khớp Material 3 / theme hiện tại).
  static TextStyle? suffixStyle(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return theme.textTheme.titleSmall?.copyWith(
      color: cs.primary,
      fontWeight: FontWeight.w600,
    );
  }

  /// Gộp [suffixText] đơn vị vào decoration sẵn có (không xóa prefixIcon, label, …).
  static InputDecoration withCurrencySuffix(
    BuildContext context,
    InputDecoration decoration, {
    required String currencySymbol,
  }) {
    final sym = currencySymbol.trim();
    if (sym.isEmpty) return decoration;
    return decoration.copyWith(
      suffixText: sym.toUpperCase(),
      suffixStyle: suffixStyle(context),
    );
  }

  /// Tách phần base (ví dụ `BTC/USDT` → `BTC`) để hiển thị đơn vị khối lượng lệnh.
  static String baseSymbolFromPairDisplay(String pairSymbol) {
    final s = pairSymbol.trim();
    if (s.isEmpty) return '';
    final idx = s.indexOf('/');
    if (idx <= 0) return s.toUpperCase();
    return s.substring(0, idx).trim().toUpperCase();
  }

  /// Tách phần quote (ví dụ `BTC/USDT` → `USDT`) cho ô giá.
  static String quoteSymbolFromPairDisplay(String pairSymbol) {
    final s = pairSymbol.trim();
    if (s.isEmpty) return '';
    final idx = s.indexOf('/');
    if (idx < 0 || idx >= s.length - 1) return '';
    return s.substring(idx + 1).trim().toUpperCase();
  }
}
