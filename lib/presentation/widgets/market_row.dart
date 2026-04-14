import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/utils/price_formatter.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart' as market_entity;

/// Tách base / quote để hiển thị gọn (tránh lặp khối "…USDT" to trên list).
({String base, String? quote}) _parsePairSymbol(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return (base: '', quote: null);
  final slash = s.indexOf('/');
  if (slash > 0 && slash < s.length - 1) {
    return (base: s.substring(0, slash), quote: s.substring(slash + 1));
  }
  const quotes = ['FDUSD', 'USDT', 'USDC', 'BUSD', 'TUSD', 'EUR', 'USD'];
  final up = s.toUpperCase();
  for (final q in quotes) {
    if (up.endsWith(q) && s.length > q.length) {
      return (base: s.substring(0, s.length - q.length), quote: q);
    }
  }
  return (base: s, quote: null);
}

/// Format changeAmount24h – chuẩn crypto: tránh "-0.00" khi % ≠ 0 (coin rẻ).
/// |v| < 0.01: dùng thêm số lẻ để có ý nghĩa (e.g. -0.0012); ≥ 0.01: 2 số lẻ.
String _formatChangeAmount(String changeAmount24h, bool isPositive) {
  final v = double.tryParse(changeAmount24h);
  if (v == null) return changeAmount24h;
  final sign = isPositive && v > 0 ? '+' : '';
  if (v == 0) return '0.00';
  if (v.abs() < 0.01) {
    final s = v.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return '$sign$s';
  }
  return '$sign${v.toStringAsFixed(2)}';
}

Widget _favoriteButton(
  BuildContext context, {
  required VoidCallback onFavoriteTap,
  required bool isFavorite,
  String? tooltip,
}) {
  final btn = IconButton(
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    visualDensity: VisualDensity.compact,
    icon: Icon(
      isFavorite ? Icons.star : Icons.star_border,
      color: isFavorite
          ? Colors.amber.shade700
          : Theme.of(context).colorScheme.primary,
    ),
    onPressed: onFavoriteTap,
  );
  if (tooltip != null && tooltip.isNotEmpty) {
    return Tooltip(message: tooltip, child: btn);
  }
  return btn;
}

/// Market Row Widget
/// Displays market pair information in a list row
class MarketRow extends StatelessWidget {
  final MarketPair market;
  final market_entity.MarketTicker? ticker;
  final VoidCallback? onTap;

  /// When set, shows a trailing favorite control (does not overlap change %).
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;
  final String? favoriteTooltip;

  /// Tighter card margin/padding for dense grids (e.g. two-column markets on wide screens).
  final bool denseLayout;

  const MarketRow({
    super.key,
    required this.market,
    this.ticker,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
    this.favoriteTooltip,
    this.denseLayout = false,
  });

  /// When ticker is missing, show "—" so user knows data is loading/missing (not real 0).
  static const String _noData = '—';

  /// Ticker with all-zero/empty price and volume is treated as no data (e.g. BE stub or price feed not started).
  static bool _isTickerEmpty(market_entity.MarketTicker? t) {
    if (t == null) return true;
    final price = double.tryParse(t.lastPrice);
    final vol = double.tryParse(t.volume24h);
    return (price == null || price == 0) && (vol == null || vol == 0);
  }

  @override
  Widget build(BuildContext context) {
    final hasTicker = ticker != null && !_isTickerEmpty(ticker);
    final isPositive = ticker?.isPositive ?? false;
    // API: change24h is % (e.g. "0.52" = 0.52%)
    final changePercent = hasTicker
        ? (double.tryParse(ticker!.change24h) ?? 0.0).toStringAsFixed(2)
        : _noData;
    final lastPrice = hasTicker ? PriceFormatter.formatPriceStr(ticker!.lastPrice) : _noData;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hMargin = denseLayout ? 6.0 : 12.0;
    final vPad = denseLayout ? 6.0 : 10.0;
    final sym = _parsePairSymbol(market.symbol);
    final symSize = denseLayout ? 14.0 : 15.0;
    final priceSize = denseLayout ? 14.0 : 15.0;
    final sideSize = denseLayout ? 12.0 : 13.0;
    final volStr = hasTicker
        ? PriceFormatter.formatVolumeStr(ticker!.volume24h)
        : _noData;

    return Padding(
      padding: EdgeInsets.fromLTRB(hMargin, 2, hMargin, 2),
      child: Material(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          mouseCursor: onTap != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: vPad),
            child: Row(
              children: [
                // Symbol (base + quote nhỏ) — một dòng
                Expanded(
                  flex: 34,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          sym.base,
                          style: TextStyle(
                            fontSize: symSize,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (sym.quote != null) ...[
                        Text(
                          ' · ${sym.quote}',
                          style: TextStyle(
                            fontSize: symSize - 2,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Last
                Expanded(
                  flex: 26,
                  child: Tooltip(
                    message: market.quoteCurrency?.symbol ?? '',
                    child: Text(
                      lastPrice,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: priceSize,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // 24h %
                Expanded(
                  flex: 22,
                  child: Tooltip(
                    message: hasTicker
                        ? _formatChangeAmount(
                            ticker!.changeAmount24h, isPositive)
                        : '',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: denseLayout ? 13 : 14,
                          color: hasTicker
                              ? (isPositive ? Colors.green : Colors.red)
                              : Colors.grey,
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            hasTicker
                                ? '${isPositive ? '+' : ''}$changePercent%'
                                : '$_noData%',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: sideSize,
                              fontWeight: FontWeight.w600,
                              color: hasTicker
                                  ? (isPositive ? Colors.green : Colors.red)
                                  : Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Vol
                Expanded(
                  flex: 22,
                  child: Text(
                    volStr,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: sideSize - 1,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onFavoriteTap != null)
                  SizedBox(
                    width: 44,
                    child: _favoriteButton(
                      context,
                      onFavoriteTap: onFavoriteTap!,
                      isFavorite: isFavorite,
                      tooltip: favoriteTooltip,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
