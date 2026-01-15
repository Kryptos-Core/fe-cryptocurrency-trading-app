import 'package:flutter/material.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart' as market_entity;

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
    final changePercent = ticker?.changePercent24h ?? '0.00';
    final lastPrice = ticker?.lastPrice ?? '0.00';

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
                        'Vol: ${ticker!.volume}',
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
                    if (ticker != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        market.quoteCurrency.symbol,
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
                        ticker!.change24h,
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
