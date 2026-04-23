import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/app/di/injection_container.dart' as di;
import 'package:crypto_trading_app/core/services/indicator_service.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/chart_websocket_policy.dart';
import 'package:crypto_trading_app/core/utils/ohlcv_to_chart.dart';
import 'package:crypto_trading_app/features/trading/presentation/providers/chart_provider.dart';
import 'package:crypto_trading_app/features/trading/presentation/widgets/lightweight_charts_widget.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/markets_provider.dart';

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
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _chartProvider = Provider.of<ChartProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadChartForInterval(_chartProvider.selectedInterval);
    });
  }

  /// Mirrors [MarketDetailScreen] / trading chart: connect + auth before subscriptions.
  Future<void> _ensureTradingWebSocket() async {
    final token = di.sl<TokenService>().getAccessToken() ?? '';
    if (!chartWebSocketNeedsInitialize(
      providerReportsConnected: _chartProvider.isWebSocketConnected,
      hasNonEmptyToken: token.isNotEmpty,
    )) {
      if (token.isEmpty) {
        _logger.w(
            '⚠️ AdvancedTrading: no JWT — realtime ticker/OHLC via WebSocket disabled');
      }
      return;
    }

    final wsUrl = ApiConstants.webSocketUrl;
    _logger.i('🔗 AdvancedTrading: initializing WebSocket $wsUrl');
    await _chartProvider.initializeWebSocket(wsUrl, token);
    try {
      await _chartProvider.waitForAuthCompletion();
      _logger.i('✅ AdvancedTrading: WebSocket authenticated');
    } catch (e) {
      _logger.e('⚠️ AdvancedTrading: WebSocket auth wait failed: $e');
    }
  }

  /// Same flow as [MarketDetailScreen] interval changes: REST `interval` + WS subscribe + candles.
  Future<void> _loadChartForInterval(String interval) async {
    if (!mounted) return;
    await _ensureTradingWebSocket();
    if (!mounted) return;

    final marketsProvider = context.read<MarketsProvider>();
    final locale = Localizations.localeOf(context).toLanguageTag();

    await marketsProvider.fetchOHLCV(
      pairId: widget.pairId,
      interval: interval,
      locale: locale,
    );
    if (!mounted) return;

    _chartProvider.setInterval(interval);

    if (marketsProvider.ohlcv.isNotEmpty) {
      final candles = ohlcvRowsToChartCandles(
        pairId: widget.pairId,
        intervalLabel: interval,
        rows: marketsProvider.ohlcv,
      );
      await _chartProvider.loadHistoricalCandles(candles);
    } else {
      await _chartProvider.loadHistoricalCandles([]);
    }
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
          onPressed: () =>
              _loadChartForInterval(_chartProvider.selectedInterval),
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
    final l10n = AppLocalizations.of(context);
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
          _buildIndicatorRow(context, l10n.chartRsi, chartProvider.rsiValues),
          const SizedBox(height: 8),
          _buildIndicatorRow(
              context, l10n.chartVolume, chartProvider.volumeValues),
          const SizedBox(height: 8),
          _buildMACDIndicator(context, chartProvider.macdValues),
        ],
      ),
    );
  }

  Widget _buildIndicatorRow(
      BuildContext context, String label, List<IndicatorValue>? values) {
    final l10n = AppLocalizations.of(context);
    if (values == null || values.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(l10n.chartNoData, style: const TextStyle(color: Colors.grey)),
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
              color: label == l10n.chartRsi
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

  Widget _buildMACDIndicator(
      BuildContext context, List<MACDValue>? macdValues) {
    final l10n = AppLocalizations.of(context);
    if (macdValues == null || macdValues.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.chartMacd,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(l10n.chartNoData, style: const TextStyle(color: Colors.grey)),
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
              Text(l10n.chartMacd,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
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
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  l10n.chartSignal,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
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
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  l10n.chartHistogram,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ApiConstants.ohlcvIntervals.map((e) {
            final apiInterval = e.value;
            final isSelected = chartProvider.selectedInterval == apiInterval;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(e.key),
                selected: isSelected,
                onSelected: (_) => _loadChartForInterval(apiInterval),
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
    final l10n = AppLocalizations.of(context);
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
            l10n.chartCandleAt(
              DateTime.fromMillisecondsSinceEpoch(candle.openTime)
                  .toString()
                  .split('.')[0],
            ),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(context, l10n.chartOpen, candle.open),
          _buildDetailRow(context, l10n.chartHigh, candle.high),
          _buildDetailRow(context, l10n.chartLow, candle.low),
          _buildDetailRow(context, l10n.chartClose, candle.close),
          _buildDetailRow(context, l10n.chartVolume, candle.volume),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, double value) {
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
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.zoom_in),
              title: Text(l10n.chartZoomIn),
              mouseCursor: SystemMouseCursors.click,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.zoom_out),
              title: Text(l10n.chartZoomOut),
              mouseCursor: SystemMouseCursors.click,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: Text(l10n.chartShowIndicators),
              mouseCursor: SystemMouseCursors.click,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
