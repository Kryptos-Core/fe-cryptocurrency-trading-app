/// Example: How to use Advanced Trading Screen with WebSocket realtime data
///
/// This demonstrates best practices for:
/// - Dependency Injection (DI)
/// - Repository Pattern
/// - Observer Pattern
/// - State Management (Provider)
/// - Clean Architecture
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/presentation/providers/chart_provider.dart';
import 'package:crypto_trading_app/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/screens/advanced_trading_screen.dart';
import 'package:crypto_trading_app/core/services/indicator_service.dart';
import 'package:crypto_trading_app/core/services/websocket_service.dart';
import 'package:logger/logger.dart';

// ============================================
// EXAMPLE 1: Using Advanced Trading Screen
// ============================================

Future<void> navigateToAdvancedTrading(BuildContext context, String pairId) async {
  // Ensure DI is initialized
  if (!sl.isRegistered<ChartProvider>()) {
    await initializeDependencies();
  }

  // Navigate with MultiProvider for state management
  if (context.mounted) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiProvider(
          providers: [
            ChangeNotifierProvider<ChartProvider>(
              create: (_) => sl<ChartProvider>(),
            ),
            ChangeNotifierProvider<MarketsProvider>(
              create: (_) => sl<MarketsProvider>(),
            ),
          ],
          child: AdvancedTradingScreen(pairId: pairId),
        ),
      ),
    );
  }
}

// ============================================
// EXAMPLE 2: Direct ChartProvider Usage
// ============================================

class TradingDashboard extends StatefulWidget {
  final String pairId;

  const TradingDashboard({super.key, required this.pairId});

  @override
  State<TradingDashboard> createState() => _TradingDashboardState();
}

class _TradingDashboardState extends State<TradingDashboard> {
  @override
  void initState() {
    super.initState();
    _setupChart();
  }

  void _setupChart() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chartProvider = context.read<ChartProvider>();

      // Initialize WebSocket connection
      // In production, use your actual WebSocket URL and token from config
      const wsUrl = 'wss://your-api.com/ws/markets';
      const jwtToken = 'your-jwt-token';

      await chartProvider.initializeWebSocket(wsUrl, jwtToken);

      // Subscribe to specific pair with ticker and ohlc channels
      chartProvider.subscribeToPair(
        widget.pairId,
        ['ticker', 'ohlc'],
        interval: '1h',
      );

      // Set initial interval
      chartProvider.setInterval('1h');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trading Dashboard')),
      body: Consumer<ChartProvider>(
        builder: (context, chartProvider, _) {
          return Column(
            children: [
              // Display connection status
              Container(
                color: chartProvider.isWebSocketConnected
                    ? Colors.green
                    : Colors.grey,
                padding: const EdgeInsets.all(8),
                child: Text(
                  chartProvider.isWebSocketConnected
                      ? '🟢 Connected to WebSocket'
                      : '🔴 Disconnected',
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              // Display latest tick
              if (chartProvider.latestTicker != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Last Price'),
                          Text(
                            '\$${chartProvider.latestTicker?.lastPrice.toStringAsFixed(8)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Change 24h'),
                          Text(
                            '${chartProvider.latestTicker?.changePercent24h.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 16,
                              color: (chartProvider
                                              .latestTicker?.changePercent24h ??
                                          0) >=
                                      0
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Candles count
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Candles: ${chartProvider.candles.length}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================
// EXAMPLE 3: Indicator Calculation (Offline)
// ============================================

void calculateIndicatorsExample() {
  final indicatorService = sl<IndicatorService>();
  final logger = Logger();

  // Mock OHLC data
  final closePrices = [100.0, 102.0, 101.5, 103.0, 102.5, 104.0, 103.5];
  final volumes = [1000.0, 1200.0, 950.0, 1100.0, 1050.0, 1300.0, 1150.0];

  // Calculate all indicators
  final indicators =
      indicatorService.calculateAllIndicators(closePrices, volumes);

  // Use SMA
  final smaValues = indicators['sma'] as List<IndicatorValue>;
  logger.d(
      '🔵 SMA: ${smaValues.map((v) => v.value.toStringAsFixed(2)).toList()}');

  // Use EMA
  final emaValues = indicators['ema'] as List<IndicatorValue>;
  logger.d(
      '🟠 EMA: ${emaValues.map((v) => v.value.toStringAsFixed(2)).toList()}');

  // Use RSI
  final rsiValues = indicators['rsi'] as List<IndicatorValue>;
  logger.d('RSI: ${rsiValues.map((v) => v.value.toStringAsFixed(2)).toList()}');

  // Use MACD
  final macdValues = indicators['macd'] as List<MACDValue>;
  for (final macd in macdValues) {
    logger.d(
        'MACD: ${macd.macd.toStringAsFixed(4)}, Signal: ${macd.signal.toStringAsFixed(4)}, Histogram: ${macd.histogram.toStringAsFixed(4)}');
  }
}

// ============================================
// EXAMPLE 4: WebSocket Service (Direct Usage)
// ============================================

Future<void> webSocketDirectUsageExample() async {
  final webSocketService = sl<IWebSocketService>();
  final logger = Logger();

  // Connect to WebSocket server with JWT token
  const wsUrl = 'wss://your-api.com/ws/markets';
  const jwtToken = 'your-jwt-token';

  await webSocketService.connect(wsUrl, jwtToken);

  // Listen to messages
  webSocketService.messageStream.listen((message) {
    switch (message.type) {
      case 'auth_response':
        logger.i('✅ Authenticated!');
        break;
      case 'ticker':
        final ticker = TickerData.fromJson(message.data);
        logger.d('📊 Ticker: ${ticker.symbol} @ \$${ticker.lastPrice}');
        break;
      case 'ohlc':
        final candle = OHLCData.fromJson(message.data);
        logger.d(
            '📈 Candle: O:${candle.open} H:${candle.high} L:${candle.low} C:${candle.close}');
        break;
      case 'error':
        logger
            .e('❌ Error: ${message.data['code']} - ${message.data['message']}');
        break;
      default:
        break;
    }
  });

  // Subscribe to specific pair with multiple channels
  webSocketService.subscribeToPair('1', ['ticker', 'ohlc'], interval: '1h');

  // ... do something ...

  // Unsubscribe and disconnect
  webSocketService.unsubscribeFromPair('1');
  await webSocketService.disconnect();
}

// ============================================
// DESIGN PATTERNS APPLIED IN THIS PROJECT
// ============================================

/*
1. **Repository Pattern**
   - IChartRepository (interface) defines contracts
   - ChartRepository (concrete) implements data access
   - Benefits: Decoupling, testability, data source flexibility

2. **Dependency Injection (DI)**
   - GetIt service locator manages all dependencies
   - initializeDependencies() bootstraps the app
   - Lazy singleton registration for performance
   - Benefits: Loose coupling, testability, global access

3. **Strategy Pattern**
   - Indicator<T> interface defines indicator calculation strategy
   - MovingAverageIndicator, RSIIndicator, etc implement strategies
   - IndicatorService acts as context
   - Benefits: Flexibility to swap algorithms, extensibility

4. **Observer Pattern**
   - Provider (ChangeNotifier) observes WebSocket messages
   - UI widgets listen to provider changes
   - Benefits: Decoupled state management, reactive UI updates

5. **Adapter Pattern**
   - ChartRepository adapts WebSocket and HTTP data sources
   - Converts API responses to domain models
   - Benefits: Unified interface for multiple data sources

6. **Facade Pattern**
   - IndicatorService provides single interface for all indicators
   - Benefits: Simplified API, hides complexity

7. **Factory Pattern**
   - WebSocketService creates WebSocketChannel instances
   - Benefits: Encapsulation, easy to modify creation logic

8. **Single Responsibility Principle (SRP)**
   - Each class has ONE reason to change
   - WebSocketService: manage connections
   - IndicatorService: calculate indicators
   - ChartProvider: manage UI state
   - ChartRepository: manage data access

9. **Open/Closed Principle (OCP)**
   - Open for extension (add new indicators by implementing IIndicator)
   - Closed for modification (don't change existing code)
   - Example: Add BollingerBandsIndicator without changing IndicatorService

10. **Liskov Substitution Principle (LSP)**
    - Any IChartRepository implementation can replace another
    - Any IIndicator implementation can replace another
    - Polymorphism ensures correct behavior

11. **Interface Segregation Principle (ISP)**
    - IWebSocketService has focused interface
    - IChartRepository has specific contracts
    - Clients not forced to depend on unused methods

12. **Dependency Inversion Principle (DIP)**
    - High-level modules depend on abstractions (interfaces)
    - Low-level modules implement abstractions
    - Example: ChartProvider depends on IWebSocketService, not WebSocketService

*/

// ============================================
// PERFORMANCE OPTIMIZATION TIPS
// ============================================

/*
1. **Candle Caching**
   - ChartProvider keeps only last 500 candles in memory
   - Older data can be archived or fetched on demand
   - Reduces memory footprint for long trading sessions

2. **Batched Updates**
   - Provider.notifyListeners() batched for multiple updates
   - Use Consumer or Selector widgets for granular updates
   - Prevents excessive rebuilds

3. **Lazy Calculation**
   - Indicators calculated only when candles change
   - Use _recalculateIndicators() strategically
   - Avoid redundant calculations

4. **Stream Throttling**
   - WebSocket messages can be throttled (future enhancement)
   - Debounce rapid tick updates for UI rendering
   - Use rxdart for advanced stream operations

5. **Custom Paint Optimization**
   - CandlestickChartPainter uses shouldRepaint() to prevent redraws
   - shouldRebuildSemantics() returns false for performance
   - Canvas transformations (translate, scale) efficient for zoom/pan

6. **Memory Management**
   - Dispose stream subscriptions in ChartProvider.dispose()
   - Close StreamControllers in ChartRepository
   - Unsubscribe from WebSocket on screen exit

7. **Async/Await Best Practices**
   - Historical data loaded asynchronously
   - WebSocket initialization non-blocking
   - UI remains responsive during data operations
*/
