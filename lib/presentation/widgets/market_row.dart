import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/utils/price_formatter.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart' as market_entity;
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';

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

    final hMargin = denseLayout ? 8.0 : 16.0;
    final innerPadding = denseLayout ? 12.0 : 16.0;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: hMargin, vertical: 4),
      child: InkWell(
        onTap: onTap,
        mouseCursor:
            onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(innerPadding),
          child: Row(
            children: [
              // Market Symbol
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      market.symbol,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppLocalizations.of(context).vol}: ${hasTicker ? PriceFormatter.formatVolumeStr(ticker!.volume24h) : _noData}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Last Price
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      lastPrice,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (market.quoteCurrency != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        market.quoteCurrency!.symbol,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Change Percent
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: onFavoriteTap != null ? 4 : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isPositive
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                hasTicker
                                    ? '${isPositive ? '+' : ''}$changePercent%'
                                    : '$_noData%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: hasTicker
                                      ? (isPositive ? Colors.green : Colors.red)
                                      : Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasTicker
                            ? _formatChangeAmount(
                                ticker!.changeAmount24h, isPositive)
                            : _noData,
                        style: TextStyle(
                          fontSize: 12,
                          color: hasTicker
                              ? (isPositive
                                  ? Colors.green.shade700
                                  : Colors.red.shade700)
                              : Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
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
    );
  }
}
