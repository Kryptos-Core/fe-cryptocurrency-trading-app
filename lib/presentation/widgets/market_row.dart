import 'package:flutter/material.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart' as market_entity;
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';

/// Format price (lastPrice) – chuẩn crypto: bậc theo magnitude, bỏ 0 thừa.
/// BTC/ETH: 1–2 số lẻ; coin nhỏ (ADA, DOGE): 4–6 số lẻ.
String _formatPrice(String priceStr) {
  final v = double.tryParse(priceStr);
  if (v == null) return priceStr;
  if (v == 0) return '0';
  int decimals;
  if (v >= 10000) {
    decimals = 1;  // BTC: 66088.7
  } else if (v >= 1000) {
    decimals = 2;
  } else if (v >= 1) {
    decimals = 2;   // LINK, DOT: 8.34, 1.26
  } else if (v >= 0.01) {
    decimals = 4;   // ADA: 0.2595
  } else {
    decimals = 6;   // DOGE nhỏ: 0.09208
  }
  final formatted = v.toStringAsFixed(decimals);
  if (formatted.contains('.')) {
    return formatted.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
  return formatted;
}

/// Format volume for display; tránh hiển thị 0.0000... dài.
String _formatVolume(String volumeStr) {
  final v = double.tryParse(volumeStr);
  if (v == null) return volumeStr;
  if (v == 0) return '0';
  if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(2)}M';
  if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(2)}K';
  if (v >= 1) return v.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  return v.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
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

  const MarketRow({
    super.key,
    required this.market,
    this.ticker,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
    this.favoriteTooltip,
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
    final lastPrice = hasTicker ? _formatPrice(ticker!.lastPrice) : _noData;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                      '${AppLocalizations.of(context).vol}: ${hasTicker ? _formatVolume(ticker!.volume24h) : _noData}',
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
