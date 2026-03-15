import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/presentation/providers/chart_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/lightweight_charts_widget.dart';
import 'package:crypto_trading_app/core/services/websocket_service.dart'
    show OHLCData;
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/core/services/chart_cache_service.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart' as di;
import 'package:logger/logger.dart';

int _intervalToSeconds(String interval) {
  switch (interval) {
    case '1m':
      return 60;
    case '5m':
      return 300;
    case '15m':
      return 900;
    case '1h':
      return 3600;
    case '4h':
      return 14400;
    case '1d':
      return 86400;
    default:
      return 60;
  }
}

double? _lastPriceFromTicker(MarketsProvider marketsProvider) {
  final t = marketsProvider.ticker;
  if (t == null) return null;
  return double.tryParse(t.lastPrice);
}

/// Format price for display: sensible decimals, trim trailing zeros.
String _formatDetailPrice(String priceStr) {
  final v = double.tryParse(priceStr);
  if (v == null) return priceStr;
  if (v == 0) return '0';
  int decimals;
  if (v >= 10000) {
    decimals = 1;
  } else if (v >= 1000) {
    decimals = 2;
  } else if (v >= 1) {
    decimals = 2;
  } else if (v >= 0.01) {
    decimals = 4;
  } else {
    decimals = 6;
  }
  final formatted = v.toStringAsFixed(decimals);
  if (formatted.contains('.')) {
    return formatted
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
  return formatted;
}

/// Format volume: K/M suffix, 2–4 decimals.
String _formatDetailVolume(String volumeStr) {
  final v = double.tryParse(volumeStr);
  if (v == null) return volumeStr;
  if (v == 0) return '0';
  if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(2)}M';
  if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(2)}K';
  if (v >= 1) {
    return v
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
  return v
      .toStringAsFixed(4)
      .replaceAll(RegExp(r'0+$'), '')
      .replaceAll(RegExp(r'\.$'), '');
}

/// Format min order amount / small decimal: trim trailing zeros, max 8 decimals.
String _formatDetailAmount(String amountStr) {
  final v = double.tryParse(amountStr);
  if (v == null) return amountStr;
  if (v == 0) return '0';
  final s = v.toStringAsFixed(8);
  if (s.contains('.')) {
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
  return s;
}

/// Format fee rate for display. API: maker_fee_rate/taker_fee_rate are decimal rate (e.g. "0.00100000" = 0.1%).
/// Display as percentage: (parseFloat(rate) * 100).toFixed(2) + '%' → "0.10%".
String _formatDetailFee(String feeStr) {
  final v = double.tryParse(feeStr);
  if (v == null) return feeStr;
  final percent = v * 100;
  if (percent == 0) return '0%';
  if (percent.abs() >= 100) return '${percent.toStringAsFixed(1)}%';
  if (percent.abs() >= 1) return '${percent.toStringAsFixed(2)}%';
  if (percent.abs() >= 0.01) return '${percent.toStringAsFixed(2)}%';
  return '${percent.toStringAsFixed(2)}%';
}

// ============================================================================
// Market Detail Screen
// ============================================================================

/// Market Detail Screen
/// Displays detailed market information with ticker, order book, and chart
class MarketDetailScreen extends StatefulWidget {
  final String pairId;

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
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();

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

    _marketsProvider.getMarketById(widget.pairId);
    _marketsProvider.fetchTicker(widget.pairId);
    _marketsProvider.fetchOrderBook(widget.pairId);

    if (!mounted) return;

    // Default: 1D range with 1m candles (best practice: nhiều nến trong 1 ngày, overlay Interval khớp với selector)
    _chartProvider!.setInterval('1m');

    // Chart init: loads from cache first, then fetches OHLCV (range 1d for initial load)
    await _initializeChart(
      widget.pairId,
      _chartProvider!,
      _marketsProvider,
    );
  }

  Future<void> _initializeChart(
    String pairId,
    ChartProvider chartProvider,
    MarketsProvider marketsProvider,
  ) async {
    try {
      final wsUrl = ApiConstants.webSocketUrl;
      final TokenService tokenService = di.sl<TokenService>();
      final token = tokenService.getAccessToken() ?? '';

      if (token.isEmpty) {
        _logger.w('⚠️ No authentication token available for WebSocket');
      } else {
        _logger.i('🔗 Initializing WebSocket with URL: $wsUrl');
        await chartProvider.initializeWebSocket(wsUrl, token);
        try {
          await chartProvider.waitForAuthCompletion();
          _logger.i('✅ Auth completed, subscribing to pair $pairId');
        } catch (e) {
          _logger.e('⚠️ Auth timeout: $e');
        }
      }

      chartProvider.subscribeToPair(
        pairId,
        ['ticker', 'ohlc'],
        interval: chartProvider.selectedInterval,
      );

      await marketsProvider.fetchOHLCV(
        pairId: pairId,
        range: '1d',
        limit: 500,
      );

      final interval = marketsProvider.selectedInterval;
      final cacheService = di.sl<ChartCacheService>();
      final cached = cacheService.getCandles(pairId, interval);

      final apiCandles = marketsProvider.ohlcv.isEmpty
          ? <OHLCData>[]
          : marketsProvider.ohlcv
              .map((o) => OHLCData(
                    pairId: pairId,
                    interval: interval,
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

      final byTime = <int, OHLCData>{};
      for (final c in cached) {
        byTime[c.openTime] = c;
      }
      for (final c in apiCandles) {
        byTime[c.openTime] = c;
      }
      var merged = byTime.values.toList()
        ..sort((a, b) => a.openTime.compareTo(b.openTime));

      if (merged.isEmpty) {
        final now = DateTime.now();
        final intervalSec = _intervalToSeconds(interval);
        final openTime = now.millisecondsSinceEpoch -
            (now.millisecondsSinceEpoch % (intervalSec * 1000));
        final closeTime = openTime + intervalSec * 1000;
        final price = _lastPriceFromTicker(marketsProvider) ?? 0.0;
        merged = [
          OHLCData(
            pairId: pairId,
            interval: interval,
            openTime: openTime,
            closeTime: closeTime,
            open: price,
            high: price,
            low: price,
            close: price,
            volume: 0,
            quoteVolume: 0,
            tradesCount: 0,
            isClosed: false,
          ),
        ];
        _logger.w(
            '📊 No OHLCV from API/cache – showing placeholder; chart will update when realtime data arrives');
      }

      cacheService.putCandles(pairId, interval, merged);
      await chartProvider.loadHistoricalCandles(merged);

      _logger.i(merged.length == 1 && merged.first.volume == 0
          ? '✅ Chart initialized with placeholder (waiting for realtime)'
          : '✅ Chart initialized with ${merged.length} candles (cache + API)');
    } catch (e) {
      _logger.e('Failed to initialize chart: $e');
    }
  }

  @override
  void dispose() {
    // Don't dispose _chartProvider - it's managed by Provider package
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Consumer<MarketsProvider>(
          builder: (context, provider, child) {
            return Text(provider.selectedMarket?.symbol ?? l10n.marketDetails);
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
            return Center(child: Text(l10n.marketNotFound));
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
    final l10n = AppLocalizations.of(context);
    final isPositive = ticker.isPositive;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.lastPrice,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDetailPrice(ticker.lastPrice),
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
                  label: l10n.change24h,
                  value: ticker.changePercentFormatted,
                  isPositive: isPositive,
                ),
                _VolumeWidget(
                  label: l10n.volume24h,
                  value: _formatDetailVolume(ticker.volume24h),
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
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.marketInformation,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: l10n.baseCurrency,
              value: market.baseCurrency?.symbol ?? l10n.na,
            ),
            _InfoRow(
              label: l10n.quoteCurrency,
              value: market.quoteCurrency?.symbol ?? l10n.na,
            ),
            _InfoRow(
              label: l10n.minOrderAmount,
              value: _formatDetailAmount(market.minOrderAmount),
            ),
            _InfoRow(
              label: l10n.makerFee,
              value: _formatDetailFee(market.makerFeeRate),
            ),
            _InfoRow(
              label: l10n.takerFee,
              value: _formatDetailFee(market.takerFeeRate),
            ),
            _InfoRow(
              label: l10n.status,
              value: market.isActive ? l10n.active : l10n.inactive,
              statusColor: market.isActive ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

/// Order Book Card Widget - Displays buy/sell orders
/// Khi bids và asks đều rỗng: hiển thị "Chưa có lệnh" theo tài liệu API
class _OrderBookCardWidget extends StatelessWidget {
  final dynamic orderBook;

  const _OrderBookCardWidget({required this.orderBook});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bids = orderBook.bids as List;
    final asks = orderBook.asks as List;
    final isEmpty = bids.isEmpty && asks.isEmpty;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.orderBook,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    l10n.orderBookEmpty,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else ...[
              _OrderSideSection(
                title: l10n.asksSell,
                orders: asks.take(5).toList(),
                color: Colors.red,
              ),
              const Divider(height: 24),
              _OrderSideSection(
                title: l10n.bidsBuy,
                orders: bids.take(5).toList(),
                color: Colors.green,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Trading Chart Widget - Displays candlestick chart with controls
class _TradingChartWidget extends StatelessWidget {
  final String pairId;

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
                const _ChartHeaderWidget(),
                const SizedBox(height: 8),
                _ChartRangeRow(pairId: pairId),
                const SizedBox(height: 16),

                // Chart content
                Consumer<MarketsProvider>(
                  builder: (context, marketsProvider, child) {
                    return _ChartContentWidget(
                      pairId: pairId,
                      chartProvider: chartProvider,
                      market: marketsProvider.selectedMarket,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // WebSocket status indicator (connected vs receiving data; hint if no updates)
                _WebSocketStatusWidget(
                  chartProvider: chartProvider,
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

/// Chart header
class _ChartHeaderWidget extends StatelessWidget {
  const _ChartHeaderWidget();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      l10n.tradingChart,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        letterSpacing: 0.2,
      ),
    );
  }
}

/// Range filter row: 1D, 1M, 3M, 1Y, 5Y – gọi API /ohlcv?range=...
class _ChartRangeRow extends StatelessWidget {
  final String pairId;

  const _ChartRangeRow({required this.pairId});

  static const List<MapEntry<String, String>> _ranges = [
    MapEntry('1d', '1D'),
    MapEntry('1M', '1M'),
    MapEntry('3M', '3M'),
    MapEntry('1y', '1Y'),
    MapEntry('5y', '5Y'),
  ];

  Future<void> _onRangeTap(
    BuildContext context,
    String range,
  ) async {
    final marketsProvider = context.read<MarketsProvider>();
    final chartProvider = context.read<ChartProvider>();
    final interval = ApiConstants.intervalForRange(range);

    await marketsProvider.fetchOHLCV(
      pairId: pairId,
      range: range,
      limit: 500,
    );

    final ohlcv = marketsProvider.ohlcv;
    if (ohlcv.isEmpty) return;

    chartProvider.setInterval(interval);
    final list = ohlcv
        .map((o) => OHLCData(
              pairId: pairId,
              interval: interval,
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
    await chartProvider.loadHistoricalCandles(list);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: _ranges
          .map((e) => ActionChip(
                label: Text(e.value),
                onPressed: () => _onRangeTap(context, e.key),
                backgroundColor: colorScheme.surfaceContainerHighest,
                side: BorderSide(color: colorScheme.outlineVariant),
              ))
          .toList(),
    );
  }
}

/// Chart content or empty state
class _ChartContentWidget extends StatelessWidget {
  final String pairId;
  final ChartProvider chartProvider;
  final dynamic market;

  const _ChartContentWidget({
    required this.pairId,
    required this.chartProvider,
    this.market,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              Text(
                l10n.waitingForChartData,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              if (chartProvider.isWebSocketConnected)
                Text(
                  chartProvider.hasReceivedRealtimeDataRecently
                      ? '(${l10n.connectedRealtime})'
                      : '(${l10n.connectedNoUpdates})',
                  style: TextStyle(
                    color: chartProvider.hasReceivedRealtimeDataRecently
                        ? Colors.green
                        : Colors.orange,
                    fontSize: 12,
                  ),
                )
              else
                Text(
                  '(${l10n.connecting})',
                  style: const TextStyle(
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
        key: ValueKey(pairId),
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
  final ChartProvider chartProvider;

  const _WebSocketStatusWidget({required this.chartProvider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isConnected = chartProvider.isWebSocketConnected;
    final receiving = chartProvider.hasReceivedRealtimeDataRecently;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              isConnected ? Icons.circle : Icons.circle_outlined,
              size: 12,
              color: isConnected
                  ? (receiving ? Colors.green : Colors.orange)
                  : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              isConnected
                  ? (receiving ? l10n.realtimeActive : l10n.connectedNoUpdates)
                  : l10n.offline,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (isConnected && !receiving) ...[
          const SizedBox(height: 6),
          Text(
            l10n.noRealtimeUpdatesHint,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
