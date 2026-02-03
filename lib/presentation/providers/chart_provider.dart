import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:crypto_trading_app/core/services/indicator_service.dart';
import 'package:crypto_trading_app/core/services/websocket_service.dart';
import 'package:logger/logger.dart';

/// Chart Provider - Observer Pattern + State Management
/// Manages chart data, indicators, and realtime updates
/// Integration with Backend WebSocket specification
class ChartProvider extends ChangeNotifier {
  final IWebSocketService webSocketService;
  final IndicatorService indicatorService;
  final Logger _logger = Logger();

  // State
  List<OHLCData> _candles = [];
  Map<String, dynamic> _indicators = {};
  TickerData? _latestTicker;
  bool _isLoading = false;
  String? _error;
  String _selectedInterval = '1m';
  int? _selectedPairId;

  // Realtime state
  bool _isWebSocketConnected = false;
  bool _isAuthenticating = false;
  StreamSubscription? _webSocketSubscription;
  bool _isDisposed = false;

  // Getters
  List<OHLCData> get candles => List.unmodifiable(_candles);
  Map<String, dynamic> get indicators => Map.unmodifiable(_indicators);
  TickerData? get latestTicker => _latestTicker;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedInterval => _selectedInterval;
  int? get selectedPairId => _selectedPairId;
  bool get isWebSocketConnected => _isWebSocketConnected;

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  // Indicator getters
  List<IndicatorValue>? get smaValues => _indicators['sma'];
  List<IndicatorValue>? get emaValues => _indicators['ema'];
  List<IndicatorValue>? get rsiValues => _indicators['rsi'];
  List<MACDValue>? get macdValues => _indicators['macd'];
  List<IndicatorValue>? get volumeValues => _indicators['volume'];

  ChartProvider({
    required this.webSocketService,
    required this.indicatorService,
  });

  /// Initialize WebSocket connection and authenticate
  /// Called with: initializeWebSocket(url, jwtToken)
  Future<void> initializeWebSocket(String url, String token) async {
    try {
      _isLoading = true;
      _isAuthenticating = true;
      _error = null;
      notifyListeners();

      // Connect to WebSocket with token
      await webSocketService.connect(url, token);

      // Listen to WebSocket messages
      _webSocketSubscription = webSocketService.messageStream.listen(
        _handleWebSocketMessage,
        onError: (error) {
          _logger.e('WebSocket error: $error');
          _error = error.toString();
          notifyListeners();
        },
      );

      _logger.i('✅ WebSocket initialized');
    } catch (e) {
      _logger.e('Failed to initialize WebSocket: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Handle incoming WebSocket messages (per BE spec)
  void _handleWebSocketMessage(WebSocketMessage message) {
    switch (message.type) {
      case 'auth_response':
        _handleAuthResponse(message.data);
        break;

      case 'ticker':
        _handleTickerUpdate(message.data);
        break;

      case 'ohlc':
        _handleCandleUpdate(message.data);
        break;

      case 'subscribed':
        _logger.i('✅ Subscribed: ${message.data}');
        break;

      case 'unsubscribed':
        _logger.i('✅ Unsubscribed: ${message.data}');
        break;

      case 'error':
        _handleWebSocketError(message.data);
        break;

      default:
        _logger.d('📥 Message type: ${message.type}');
    }
  }

  /// Handle authentication response
  void _handleAuthResponse(Map<String, dynamic> data) {
    _isAuthenticating = false;
    _isWebSocketConnected = true;
    final userId = data['user_id'];
    _logger.i('✅ Authenticated as user: $userId');
    notifyListeners();
  }

  /// Wait for WebSocket authentication to complete
  Future<void> waitForAuthCompletion(
      {Duration timeout = const Duration(seconds: 10)}) async {
    int attempts = 0;
    const int maxAttempts = 100; // 100 * 100ms = 10 seconds

    while (!_isWebSocketConnected && attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    if (!_isWebSocketConnected) {
      throw Exception('WebSocket authentication timeout');
    }
  }

  /// Handle ticker (price) updates - Every 1 second
  void _handleTickerUpdate(Map<String, dynamic> data) {
    try {
      _latestTicker = TickerData.fromJson(data);
      _logger.d(
          '💰 Ticker: ${_latestTicker?.symbol} = ${_latestTicker?.lastPrice}');
      notifyListeners();
    } catch (e) {
      _logger.e('Error processing ticker: $e');
    }
  }

  /// Handle OHLC candle updates
  void _handleCandleUpdate(Map<String, dynamic> data) {
    try {
      final newCandle = OHLCData.fromJson(data);

      // Check if this is an update to existing candle or new candle
      if (_candles.isNotEmpty && _candles.last.openTime == newCandle.openTime) {
        // Update existing candle
        _candles[_candles.length - 1] = newCandle;
        _logger.d(
            '📈 Updated candle: ${newCandle.interval} closed=${newCandle.isClosed}');
      } else {
        // Add new candle
        _candles.add(newCandle);
        _logger
            .d('📈 New candle: ${newCandle.interval} close=${newCandle.close}');

        // Keep only last 500 candles for performance
        if (_candles.length > 500) {
          _candles.removeAt(0);
        }
      }

      _recalculateIndicators();
      notifyListeners();
    } catch (e) {
      _logger.e('Error processing candle: $e');
    }
  }

  /// Handle WebSocket errors (per BE spec)
  void _handleWebSocketError(Map<String, dynamic> errorData) {
    final errorCode = errorData['code'] ?? 'UNKNOWN';
    final errorMessage = errorData['message'] ?? 'Unknown error';

    _error = '$errorCode: $errorMessage';
    _logger.e('❌ WebSocket error: $_error');

    // Handle specific error codes
    switch (errorCode) {
      case 'AUTH_FAILED':
        _isAuthenticating = false;
        _logger.e('Authentication failed - token may be invalid');
        // Could trigger token refresh here
        break;

      case 'INVALID_PAIR':
        _logger.w('Invalid trading pair ID');
        break;

      case 'RATE_LIMIT_EXCEEDED':
        _logger.w('Rate limit exceeded - backing off');
        break;

      default:
        _logger.e('Error: $errorMessage');
    }

    notifyListeners();
  }

  /// Recalculate all indicators based on current candles
  void _recalculateIndicators() {
    if (_candles.length < 20) return;

    try {
      final closePrices = _candles.map((c) => c.close).toList();
      final volumes = _candles.map((c) => c.volume).toList();

      _indicators =
          indicatorService.calculateAllIndicators(closePrices, volumes);
      _logger.d('✅ Indicators recalculated');
    } catch (e) {
      _logger.e('Error recalculating indicators: $e');
    }
  }

  /// Subscribe to a trading pair with specific channels
  void subscribeToPair(int pairId, List<String> channels, {String? interval}) {
    if (_selectedPairId == pairId) return;

    // Unsubscribe from previous pair
    if (_selectedPairId != null) {
      webSocketService.unsubscribeFromPair(_selectedPairId!);
    }

    _selectedPairId = pairId;
    _candles.clear();
    _indicators.clear();
    _error = null;

    // Subscribe to new pair
    webSocketService.subscribeToPair(
      pairId,
      channels,
      interval: interval ?? _selectedInterval,
    );

    _logger.i('📡 Subscribed to pair $pairId: $channels');
    notifyListeners();
  }

  /// Set selected interval and resubscribe
  void setInterval(String interval) {
    if (_selectedInterval == interval) return;

    _selectedInterval = interval;

    if (_selectedPairId != null) {
      // Resubscribe with new interval
      webSocketService.subscribeToPair(
        _selectedPairId!,
        ['ticker', 'ohlc'],
        interval: interval,
      );
    }

    notifyListeners();
  }

  /// Load historical candles (from REST API)
  Future<void> loadHistoricalCandles(List<OHLCData> candles) async {
    try {
      _isLoading = true;
      _candles = List.from(candles);
      _recalculateIndicators();
      _logger.i('📚 Historical candles loaded: ${_candles.length}');
    } catch (e) {
      _logger.e('Error loading historical candles: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add multiple candles at once
  void addCandles(List<OHLCData> newCandles) {
    _candles.addAll(newCandles);

    // Keep only last 500 candles
    if (_candles.length > 500) {
      _candles = _candles.sublist(_candles.length - 500);
    }

    _recalculateIndicators();
    notifyListeners();
  }

  /// Clear all data
  void clear() {
    _candles.clear();
    _indicators.clear();
    _latestTicker = null;
    _error = null;
    notifyListeners();
  }

  /// Cleanup resources
  @override
  void dispose() {
    _isDisposed = true;
    _webSocketSubscription?.cancel();
    webSocketService.disconnect();
    super.dispose();
  }
}
