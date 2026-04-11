import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/presentation/providers/chart_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/lightweight_charts_widget.dart';
import 'package:crypto_trading_app/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/core/services/indicator_service.dart';
import 'package:crypto_trading_app/core/services/websocket_service.dart'
    show OHLCData;

/// Advanced Trading Screen
/// Features:
/// - Professional candlestick chart with OHLC
/// - Realtime WebSocket updates
/// - Multiple technical indicators (MA, RSI, MACD, Volume)
/// - Smooth zoom/pan interactions
/// - Professional UX for traders
class AdvancedTradingScreen extends StatefulWidget {
  final String pairId;

  const AdvancedTradingScreen({
    super.key,
    required this.pairId,
  });

  @override
  State<AdvancedTradingScreen> createState() => _AdvancedTradingScreenState();
}

class _AdvancedTradingScreenState extends State<AdvancedTradingScreen> {
  late ChartProvider _chartProvider;
  int? _selectedCandleIndex;

  @override
  void initState() {
    super.initState();
    _initializeChart();
  }

  void _initializeChart() {
    _chartProvider = Provider.of<ChartProvider>(context, listen: false);

    // Load historical data from markets provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;
      final marketsProvider = context.read<MarketsProvider>();
      final ohlcvLocale = Localizations.localeOf(context).toLanguageTag();

      // Fetch historical OHLCV data
      await marketsProvider.fetchOHLCV(pairId: widget.pairId, locale: ohlcvLocale);

      // Load into chart
      if (marketsProvider.ohlcv.isNotEmpty) {
        final candles = marketsProvider.ohlcv
            .map((o) => OHLCData(
                  pairId: widget.pairId,
                  interval: '1h',
                  openTime: o.openTime.millisecondsSinceEpoch,
                  closeTime: o.openTime
                      .add(const Duration(hours: 1))
                      .millisecondsSinceEpoch,
                  open: double.tryParse(o.open) ?? 0,
                  high: double.tryParse(o.high) ?? 0,
                  low: double.tryParse(o.low) ?? 0,
                  close: double.tryParse(o.close) ?? 0,
                  volume: double.tryParse(o.volume) ?? 0,
                  quoteVolume: 0,
                  tradesCount: 0,
                  isClosed: true,
                ))
            .toList();

        _chartProvider.loadHistoricalCandles(candles);
      }

      // Subscribe to realtime updates (if WebSocket available)
      _chartProvider.subscribeToPair(
        widget.pairId,
        ['ticker', 'ohlc'],
        interval: '1h',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<ChartProvider>(
        builder: (context, chartProvider, _) {
          return CustomScrollView(
            slivers: [
              // Market Info & Ticker
              SliverToBoxAdapter(child: _buildTickerInfo(chartProvider)),

              // Chart
              SliverToBoxAdapter(child: _buildChart(chartProvider)),

              // Indicators
              SliverToBoxAdapter(child: _buildIndicators(chartProvider)),

              // Interval Selector
              SliverToBoxAdapter(child: _buildIntervalSelector(chartProvider)),

              // Candle Details
              SliverToBoxAdapter(child: _buildCandleDetails(chartProvider)),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Consumer<MarketsProvider>(
        builder: (context, marketsProvider, _) {
          final market = marketsProvider.selectedMarket;
          return Text(market?.symbol ?? 'Trading Chart');
        },
      ),
      elevation: 2,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _chartProvider.clear(),
          tooltip: 'Refresh Chart',
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: _showMoreOptions,
        ),
      ],
    );
  }

  Widget _buildTickerInfo(ChartProvider chartProvider) {
    return Consumer<MarketsProvider>(
      builder: (context, marketsProvider, _) {
        final ticker = marketsProvider.ticker;
        if (ticker == null) {
          return const SizedBox(height: 80);
        }

        final isPositive = ticker.isPositive;
        final changeColor = isPositive ? Colors.green : Colors.red;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last: \$${ticker.lastPrice}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bid: \$${ticker.bestBid} | Ask: \$${ticker.bestAsk}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isPositive ? '+' : ''}${ticker.changeAmount24h}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: changeColor,
                    ),
                  ),
                  Text(
                    '${isPositive ? '+' : ''}${ticker.change24h}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: changeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChart(ChartProvider chartProvider) {
    return Builder(
      builder: (context) {
        return Container(
          height: 400,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: chartProvider.isLoading && chartProvider.candles.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : LightweightChartsWidget(
                  candles: chartProvider.candles,
                  pairSymbol: 'Pair ${chartProvider.selectedPairId ?? 0}',
                  interval: chartProvider.selectedInterval,
                  localeTag: Localizations.localeOf(context).toLanguageTag(),
                  onCandleTap: (index) {
                    setState(() => _selectedCandleIndex = index);
                  },
                ),
        );
      },
    );
  }

  Widget _buildIndicators(ChartProvider chartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Indicators',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildIndicatorRow('RSI', chartProvider.rsiValues),
          const SizedBox(height: 8),
          _buildIndicatorRow('Volume', chartProvider.volumeValues),
          const SizedBox(height: 8),
          _buildMACDIndicator(chartProvider.macdValues),
        ],
      ),
    );
  }

  Widget _buildIndicatorRow(String label, List<IndicatorValue>? values) {
    if (values == null || values.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            const Text('No data', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final lastValue = values.last.value;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            lastValue.toStringAsFixed(2),
            style: TextStyle(
              color: label == 'RSI'
                  ? (lastValue > 70
                      ? Colors.red
                      : lastValue < 30
                          ? Colors.green
                          : Colors.blue)
                  : Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMACDIndicator(List<MACDValue>? macdValues) {
    if (macdValues == null || macdValues.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('MACD', style: TextStyle(fontWeight: FontWeight.w500)),
            Text('No data', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final lastMACD = macdValues.last;
    final histogramColor = lastMACD.histogram > 0 ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('MACD', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                lastMACD.macd.toStringAsFixed(4),
                style: const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text('Signal',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              Text(
                lastMACD.signal.toStringAsFixed(4),
                style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text('Histogram',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              Text(
                lastMACD.histogram.toStringAsFixed(4),
                style: TextStyle(
                  color: histogramColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalSelector(ChartProvider chartProvider) {
    final intervals = ['1m', '5m', '15m', '1h', '4h', '1d'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: intervals.map((interval) {
            final isSelected = chartProvider.selectedInterval == interval;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(interval),
                selected: isSelected,
                onSelected: (_) => chartProvider.setInterval(interval),
                backgroundColor: Colors.white,
                selectedColor: Colors.blue[100],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCandleDetails(ChartProvider chartProvider) {
    if (_selectedCandleIndex == null ||
        _selectedCandleIndex! >= chartProvider.candles.length) {
      return const SizedBox(height: 0);
    }

    final candle = chartProvider.candles[_selectedCandleIndex!];

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Candle at ${DateTime.fromMillisecondsSinceEpoch(candle.openTime).toString().split('.')[0]}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Open', candle.open),
          _buildDetailRow('High', candle.high),
          _buildDetailRow('Low', candle.low),
          _buildDetailRow('Close', candle.close),
          _buildDetailRow('Volume', candle.volume),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value.toStringAsFixed(8),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.zoom_in),
              title: const Text('Zoom In'),
              mouseCursor: SystemMouseCursors.click,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.zoom_out),
              title: const Text('Zoom Out'),
              mouseCursor: SystemMouseCursors.click,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text('Show Indicators'),
              mouseCursor: SystemMouseCursors.click,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
