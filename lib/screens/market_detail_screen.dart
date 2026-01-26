import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/presentation/providers/markets_provider.dart';

/// Market Detail Screen
/// Displays detailed market information with ticker, order book, and chart
class MarketDetailScreen extends StatefulWidget {
  final int pairId;

  const MarketDetailScreen({
    super.key,
    required this.pairId,
  });

  @override
  State<MarketDetailScreen> createState() => _MarketDetailScreenState();
}

class _MarketDetailScreenState extends State<MarketDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MarketsProvider>();
      provider.getMarketById(widget.pairId);
      provider.fetchTicker(widget.pairId);
      provider.fetchOrderBook(widget.pairId);
      provider.fetchOHLCV(pairId: widget.pairId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<MarketsProvider>(
          builder: (context, provider, child) {
            return Text(provider.selectedMarket?.symbol ?? 'Market Details');
          },
        ),
      ),
      body: Consumer<MarketsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.selectedMarket == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final market = provider.selectedMarket;
          if (market == null) {
            return const Center(child: Text('Market not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ticker Info
                if (provider.ticker != null) _buildTickerCard(provider.ticker!),
                const SizedBox(height: 16),
                // Market Info
                _buildMarketInfoCard(market),
                const SizedBox(height: 16),
                // Order Book
                if (provider.orderBook != null) _buildOrderBookCard(provider.orderBook!),
                const SizedBox(height: 16),
                // Chart placeholder
                _buildChartPlaceholder(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTickerCard(ticker) {
    final isPositive = ticker.isPositive;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last Price',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ticker.lastPrice,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '24h Change',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      ticker.changePercentFormatted,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Volume',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      ticker.volume24h,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketInfoCard(market) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Market Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Base Currency', market.baseCurrency?.symbol ?? 'N/A'),
            _buildInfoRow('Quote Currency', market.quoteCurrency?.symbol ?? 'N/A'),
            _buildInfoRow('Min Order Amount', market.minOrderAmount),
            _buildInfoRow('Maker Fee', '${market.makerFeeRate}%'),
            _buildInfoRow('Taker Fee', '${market.takerFeeRate}%'),
            _buildInfoRow('Status', market.isActive ? 'Active' : 'Inactive'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderBookCard(orderBook) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Book',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // ASKS
            const Text(
              'ASKS (Sell)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            ...orderBook.asks.take(5).map((ask) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(ask.price, style: const TextStyle(color: Colors.red)),
                      Text(ask.amount),
                      Text(ask.total),
                    ],
                  ),
                )),
            const Divider(),
            // BIDS
            const Text(
              'BIDS (Buy)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            ...orderBook.bids.take(5).map((bid) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(bid.price, style: const TextStyle(color: Colors.green)),
                      Text(bid.amount),
                      Text(bid.total),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    return Card(
      child: Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text(
            'Chart Placeholder\n(Implement with fl_chart)',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
