import 'package:flutter/material.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart' as market_entity;

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

/// Market Row Widget
/// Displays market pair information in a list row
class MarketRow extends StatelessWidget {
  final MarketPair market;
  final market_entity.MarketTicker? ticker;
  final VoidCallback? onTap;
  final bool showFavorite;

  const MarketRow({
    super.key,
    required this.market,
    this.ticker,
    this.onTap,
    this.showFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = ticker?.isPositive ?? false;
    // API: change24h is % (e.g. "0.52" = 0.52%)
    final changePercent = ticker != null
        ? (double.tryParse(ticker!.change24h) ?? 0.0).toStringAsFixed(2)
        : '0.00';
    final lastPrice = _formatPrice(ticker?.lastPrice ?? '0');

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
                    if (ticker != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Vol: ${_formatVolume(ticker!.volume24h)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
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
                    if (ticker != null && market.quoteCurrency != null) ...[
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 16,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isPositive ? '+' : ''}$changePercent%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    if (ticker != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatChangeAmount(ticker!.changeAmount24h, isPositive),
                        style: TextStyle(
                          fontSize: 12,
                          color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Favorite Icon
              if (showFavorite)
                IconButton(
                  icon: const Icon(Icons.star_border),
                  onPressed: () {},
                  color: Colors.amber,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
