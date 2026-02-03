import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/presentation/providers/chart_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/lightweight_charts_widget.dart';
import 'package:crypto_trading_app/core/services/websocket_service.dart'
    show OHLCData;
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart' as di;
import 'package:logger/logger.dart';

// ============================================================================
// STRATEGY PATTERN: Data Initialization Strategy
// ============================================================================

/// Abstract strategy for initializing chart data
abstract class ChartInitializationStrategy {
  Future<void> initialize(
    int pairId,
    ChartProvider chartProvider,
    MarketsProvider marketsProvider,
  );
}

/// Concrete strategy: Initialize chart with OHLCV data
class OHLCVChartInitialization implements ChartInitializationStrategy {
  final Logger _logger = Logger();

  @override
  Future<void> initialize(
    int pairId,
    ChartProvider chartProvider,
    MarketsProvider marketsProvider,
  ) async {
    try {
      // Get WebSocket URL and JWT token at runtime (more flexible than compile-time const)
      String wsUrl = 'ws://localhost:3000/trading'; // Default URL

      // Try to get from environment if available
      final envUrl = String.fromEnvironment('WS_URL', defaultValue: '');
      if (envUrl.isNotEmpty) {
        wsUrl = envUrl;
      }

      final TokenService tokenService = di.sl<TokenService>();
      final token = tokenService.getAccessToken() ?? '';

      if (token.isEmpty) {
        _logger.w('⚠️ No authentication token available for WebSocket');
      } else {
        _logger.i('🔗 Initializing WebSocket with URL: $wsUrl');
        await chartProvider.initializeWebSocket(wsUrl, token);
      }

      // Load historical OHLCV data
      final candles = marketsProvider.ohlcv.isEmpty
          ? <OHLCData>[] // Empty list for empty data
          : marketsProvider.ohlcv
              .map((o) => OHLCData(
                    pairId: pairId,
                    interval: chartProvider.selectedInterval,
                    openTime: o.openTime.millisecondsSinceEpoch,
                    closeTime: o.openTime
                        .add(Duration(seconds: o.intervalSec))
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

      // Load historical data into the chart provider
      await chartProvider.loadHistoricalCandles(candles);

      _logger.i(candles.isEmpty
          ? '⚠️ Chart initialized with no data (empty candles)'
          : '✅ Chart initialized with ${candles.length} candles');

      // Wait for WebSocket authentication to complete BEFORE subscribing
      try {
        await chartProvider.waitForAuthCompletion();
        _logger.i('✅ Auth completed, subscribing to real-time updates...');
      } catch (e) {
        _logger.e('⚠️ Auth timeout: $e');
      }

      // Subscribe to realtime updates AFTER auth is confirmed
      chartProvider.subscribeToPair(
        pairId,
        ['ticker', 'ohlc'],
      );
    } catch (e) {
      _logger.e('Failed to initialize chart: $e');
    }
  }
}

// ============================================================================
// Market Detail Screen
// ============================================================================

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
  ChartProvider? _chartProvider;
  late MarketsProvider _marketsProvider;
  late ChartInitializationStrategy _chartStrategy;

  @override
  void initState() {
    super.initState();
    _chartStrategy = OHLCVChartInitialization();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeProviders();
      }
    });
  }

  Future<void> _initializeProviders() async {
    if (!mounted) return;

    _marketsProvider = context.read<MarketsProvider>();
    _chartProvider = context.read<ChartProvider>();

    // Load market data and wait for OHLCV data
    _marketsProvider.getMarketById(widget.pairId);
    _marketsProvider.fetchTicker(widget.pairId);
    _marketsProvider.fetchOrderBook(widget.pairId);

    // Wait for OHLCV data to load before initializing chart
    await _marketsProvider.fetchOHLCV(
      pairId: widget.pairId,
      interval: _chartProvider?.selectedInterval,
    );

    if (!mounted) return;

    // Initialize chart using strategy pattern AFTER data is ready
    await _chartStrategy.initialize(
      widget.pairId,
      _chartProvider!,
      _marketsProvider,
    );
  }

  @override
  void dispose() {
    // Don't dispose _chartProvider - it's managed by Provider package
    super.dispose();
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
        builder: (context, marketsProvider, child) {
          if (marketsProvider.isLoading &&
              marketsProvider.selectedMarket == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final market = marketsProvider.selectedMarket;
          if (market == null) {
            return const Center(child: Text('Market not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ticker Info
                if (marketsProvider.ticker != null)
                  _TickerCardWidget(ticker: marketsProvider.ticker!),
                const SizedBox(height: 16),

                // Market Info
                _MarketInfoCardWidget(market: market),
                const SizedBox(height: 16),

                // Order Book
                if (marketsProvider.orderBook != null)
                  _OrderBookCardWidget(orderBook: marketsProvider.orderBook!),
                const SizedBox(height: 16),

                // Trading Chart
                _TradingChartWidget(pairId: widget.pairId),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// SINGLE RESPONSIBILITY PRINCIPLE: Separate Widgets for Each Card
// ============================================================================

/// Ticker Card Widget - Displays last price and 24h change
class _TickerCardWidget extends StatelessWidget {
  final dynamic ticker;

  const _TickerCardWidget({required this.ticker});

  @override
  Widget build(BuildContext context) {
    final isPositive = ticker.isPositive;
    return Card(
      elevation: 2,
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
                fontWeight: FontWeight.w500,
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
                _PriceChangeWidget(
                  label: '24h Change',
                  value: ticker.changePercentFormatted,
                  isPositive: isPositive,
                ),
                _VolumeWidget(
                  label: 'Volume (24h)',
                  value: ticker.volume24h,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Market Info Card Widget - Displays market details
class _MarketInfoCardWidget extends StatelessWidget {
  final dynamic market;

  const _MarketInfoCardWidget({required this.market});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
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
            _InfoRow(
              label: 'Base Currency',
              value: market.baseCurrency?.symbol ?? 'N/A',
            ),
            _InfoRow(
              label: 'Quote Currency',
              value: market.quoteCurrency?.symbol ?? 'N/A',
            ),
            _InfoRow(
              label: 'Min Order Amount',
              value: market.minOrderAmount,
            ),
            _InfoRow(
              label: 'Maker Fee',
              value: '${market.makerFeeRate}%',
            ),
            _InfoRow(
              label: 'Taker Fee',
              value: '${market.takerFeeRate}%',
            ),
            _InfoRow(
              label: 'Status',
              value: market.isActive ? 'Active' : 'Inactive',
              statusColor: market.isActive ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

/// Order Book Card Widget - Displays buy/sell orders
class _OrderBookCardWidget extends StatelessWidget {
  final dynamic orderBook;

  const _OrderBookCardWidget({required this.orderBook});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
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
            _OrderSideSection(
              title: 'ASKS (Sell)',
              orders: orderBook.asks.take(5).toList(),
              color: Colors.red,
            ),
            const Divider(height: 24),
            _OrderSideSection(
              title: 'BIDS (Buy)',
              orders: orderBook.bids.take(5).toList(),
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

/// Trading Chart Widget - Displays candlestick chart with controls
class _TradingChartWidget extends StatelessWidget {
  final int pairId;

  const _TradingChartWidget({required this.pairId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChartProvider>(
      builder: (context, chartProvider, child) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with interval selector
                _ChartHeaderWidget(
                  chartProvider: chartProvider,
                  pairId: pairId,
                ),
                const SizedBox(height: 16),

                // Chart content
                Consumer<MarketsProvider>(
                  builder: (context, marketsProvider, child) {
                    return _ChartContentWidget(
                      chartProvider: chartProvider,
                      market: marketsProvider.selectedMarket,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // WebSocket status indicator
                _WebSocketStatusWidget(
                  isConnected: chartProvider.isWebSocketConnected,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// COMPOSITE WIDGETS - Reusable Components
// ============================================================================

/// Price change display component
class _PriceChangeWidget extends StatelessWidget {
  final String label;
  final String value;
  final bool isPositive;

  const _PriceChangeWidget({
    required this.label,
    required this.value,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isPositive ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}

/// Volume display component
class _VolumeWidget extends StatelessWidget {
  final String label;
  final String value;

  const _VolumeWidget({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Info row component
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? statusColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Order side section (ASKS/BIDS)
class _OrderSideSection extends StatelessWidget {
  final String title;
  final List<dynamic> orders;
  final Color color;

  const _OrderSideSection({
    required this.title,
    required this.orders,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ...orders.map((order) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.price,
                    style: TextStyle(color: color),
                  ),
                  Text(order.amount),
                  Text(order.total),
                ],
              ),
            )),
      ],
    );
  }
}

/// Chart header with interval selector
class _ChartHeaderWidget extends StatelessWidget {
  final ChartProvider chartProvider;
  final int pairId;

  const _ChartHeaderWidget({
    required this.chartProvider,
    required this.pairId,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Trading Chart',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        DropdownButton<String>(
          value: chartProvider.selectedInterval,
          items: ['1m', '5m', '15m', '1h', '4h', '1d']
              .map((interval) => DropdownMenuItem(
                    value: interval,
                    child: Text(
                      interval,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              chartProvider.setInterval(value);
              chartProvider.subscribeToPair(
                pairId,
                ['ticker', 'ohlc'],
                interval: value,
              );
            }
          },
        ),
      ],
    );
  }
}

/// Chart content or empty state
class _ChartContentWidget extends StatelessWidget {
  final ChartProvider chartProvider;
  final dynamic market;

  const _ChartContentWidget({
    required this.chartProvider,
    this.market,
  });

  @override
  Widget build(BuildContext context) {
    if (chartProvider.candles.isEmpty) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hourglass_empty,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'Waiting for chart data...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              if (chartProvider.isWebSocketConnected)
                const Text(
                  '(Connected to real-time updates)',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                )
              else
                const Text(
                  '(Connecting...)',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 400,
      child: LightweightChartsWidget(
        candles: chartProvider.candles,
        pairSymbol: market?.symbol ?? 'UNKNOWN',
        interval: chartProvider.selectedInterval,
        onCandleTap: (index) {
          // TODO: Show candle details in bottom sheet
        },
      ),
    );
  }
}

/// WebSocket connection status indicator
class _WebSocketStatusWidget extends StatelessWidget {
  final bool isConnected;

  const _WebSocketStatusWidget({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isConnected ? Icons.circle : Icons.circle_outlined,
          size: 12,
          color: isConnected ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          isConnected ? 'Real-time updates active' : 'Offline',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
