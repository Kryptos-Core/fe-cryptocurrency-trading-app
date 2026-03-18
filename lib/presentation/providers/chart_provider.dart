import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:crypto_trading_app/core/services/indicator_service.dart';
import 'package:crypto_trading_app/core/services/websocket_service.dart';
import 'package:crypto_trading_app/core/services/chart_cache_service.dart';
import 'package:logger/logger.dart';

/// Chart Provider - Observer Pattern + State Management
/// Manages chart data, indicators, and realtime updates.
/// Uses ChartCacheService to retain ~1 month of data per pair/interval.
class ChartProvider extends ChangeNotifier {
  final IWebSocketService webSocketService;
  final IndicatorService indicatorService;
  final ChartCacheService chartCacheService;
  final Logger _logger = Logger();

  // State
  List<OHLCData> _candles = [];
  Map<String, dynamic> _indicators = {};
  TickerData? _latestTicker;
  bool _isLoading = false;
  String? _error;
  String _selectedInterval = '1m';
  String? _selectedPairId;

  /// Max candles to hold in memory for chart display (performance).
  static const int _maxCandlesDisplay = 2000;

  // Realtime state
  bool _isWebSocketConnected = false;
  bool _isDisposed = false;
  /// Last time we received a ticker or ohlc message (for "receiving data" vs "connected only").
  DateTime? _lastTickerOrOhlcAt;

  // Typed stream subscriptions (Observer pipelines)
  StreamSubscription<Map<String, dynamic>>? _authResponseSubscription;
  StreamSubscription<TickerData>? _tickerSubscription;
  StreamSubscription<OHLCData>? _ohlcSubscription;
  StreamSubscription<WorkspaceState>? _workspaceRestoredSubscription;

  // Getters
  List<OHLCData> get candles => List.unmodifiable(_candles);
  Map<String, dynamic> get indicators => Map.unmodifiable(_indicators);
  TickerData? get latestTicker => _latestTicker;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedInterval => _selectedInterval;
  String? get selectedPairId => _selectedPairId;
  bool get isWebSocketConnected => _isWebSocketConnected;
  /// True if we received at least one ticker or ohlc in the last 45 seconds.
  bool get hasReceivedRealtimeDataRecently =>
      _lastTickerOrOhlcAt != null &&
      DateTime.now().difference(_lastTickerOrOhlcAt!) < const Duration(seconds: 45);

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
    required this.chartCacheService,
  });

  /// Initialize WebSocket connection and authenticate.
  /// Uses typed stream pipelines (Observer pattern) instead of a single message switch.
  Future<void> initializeWebSocket(String url, String token) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await webSocketService.connect(url, token);

      // ── auth_response ────────────────────────────────────────────────────
      _authResponseSubscription?.cancel();
      _authResponseSubscription = webSocketService.messageStream
          .where((m) => m.type == 'auth_response')
          .map((m) => m.data)
          .listen(
            _handleAuthResponse,
            onError: (e) => _logger.e('auth_response error: $e'),
          );

      // ── ticker stream ────────────────────────────────────────────────────
      _tickerSubscription?.cancel();
      _tickerSubscription = webSocketService.tickerStream.listen(
        _handleTickerUpdate,
        onError: (e) => _logger.e('tickerStream error: $e'),
      );

      // ── ohlc stream ──────────────────────────────────────────────────────
      _ohlcSubscription?.cancel();
      _ohlcSubscription = webSocketService.ohlcStream.listen(
        _handleCandleUpdate,
        onError: (e) => _logger.e('ohlcStream error: $e'),
      );

      // ── workspace_restored stream ────────────────────────────────────────
      _workspaceRestoredSubscription?.cancel();
      _workspaceRestoredSubscription =
          webSocketService.workspaceRestoredStream.listen(
        _handleWorkspaceRestored,
        onError: (e) => _logger.e('workspaceRestoredStream error: $e'),
      );

      // error messages from socket
      webSocketService.messageStream
          .where((m) => m.type == 'error')
          .listen((m) => _handleWebSocketError(m.data));

      _logger.i('✅ WebSocket initialized with typed stream pipelines');
    } catch (e) {
      _logger.e('Failed to initialize WebSocket: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Handle authentication response.
  /// WebSocketService handles the workspace restore grace period / fallback internally.
  /// ChartProvider only needs to mark itself as connected here.
  void _handleAuthResponse(Map<String, dynamic> data) {
    _isWebSocketConnected = true;
    _logger.i('✅ Authenticated as user: ${data['user_id']}');
    notifyListeners();
  }

  /// Handle workspace restore event from server.
  /// Server confirmed the subscription is active — no need to re-subscribe.
  /// If the restored workspace contains our current pair, we're already in the room.
  void _handleWorkspaceRestored(WorkspaceState workspace) {
    _logger.i('📦 Workspace restored by server: ${workspace.pairs.length} pair(s)');
    _isWebSocketConnected = true;

    // Check if our selected pair is in the restored workspace
    final restoredPair = workspace.pairs.where((p) => p.pairId == _selectedPairId).firstOrNull;
    if (restoredPair != null) {
      _logger.i('✅ Current pair $_selectedPairId is in restored workspace — no re-subscribe needed');
    } else if (_selectedPairId != null) {
      // Current pair not in workspace (e.g., user changed pair while offline) — subscribe it now
      webSocketService.subscribeToPair(
        _selectedPairId!,
        ['ticker', 'ohlc'],
        interval: _selectedInterval,
      );
    }

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
  void _handleTickerUpdate(TickerData ticker) {
    try {
      _lastTickerOrOhlcAt = DateTime.now();
      _latestTicker = ticker;
      notifyListeners();
    } catch (e) {
      _logger.e('Error processing ticker: $e');
    }
  }

  /// Handle OHLC candle updates
  void _handleCandleUpdate(OHLCData newCandle) {
    try {
      _lastTickerOrOhlcAt = DateTime.now();

      // Check if this is an update to existing candle or new candle
      if (_candles.isNotEmpty && _candles.last.openTime == newCandle.openTime) {
        _candles[_candles.length - 1] = newCandle;
      } else {
        _candles.add(newCandle);

        if (_candles.length > _maxCandlesDisplay) {
          _candles.removeAt(0);
        }
      }

      if (_selectedPairId != null) {
        chartCacheService.putCandles(_selectedPairId!, _selectedInterval, _candles);
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
    } catch (e) {
      _logger.e('Error recalculating indicators: $e');
    }
  }

  /// Subscribe to a trading pair with specific channels.
  /// Loads cached candles for this pair/interval first (if any), then subscribes to realtime.
  void subscribeToPair(String pairId, List<String> channels, {String? interval}) {
    final effectiveInterval = interval ?? _selectedInterval;
    if (_selectedPairId == pairId && _selectedInterval == effectiveInterval) return;

    if (_selectedPairId != null) {
      webSocketService.unsubscribeFromPair(_selectedPairId!);
    }

    _selectedPairId = pairId;
    _selectedInterval = effectiveInterval;
    _indicators.clear();
    _error = null;
    _lastTickerOrOhlcAt = null; // reset so UI shows "connected" until we get first ticker/ohlc for this pair

    // Load from cache (trim to display limit for performance)
    final cached = chartCacheService.getCandles(pairId, effectiveInterval);
    _candles = cached.length > _maxCandlesDisplay
        ? cached.sublist(cached.length - _maxCandlesDisplay)
        : cached;
    if (_candles.isNotEmpty) {
      _recalculateIndicators();
      _logger.i('📂 Loaded ${_candles.length} candles from cache for pair $pairId $effectiveInterval');
    }

    webSocketService.subscribeToPair(
      pairId,
      channels,
      interval: effectiveInterval,
    );

    _logger.i('📡 Subscribed to pair $pairId: $channels');
    notifyListeners();
  }

  /// Set selected interval: load cache for new interval (if any) and resubscribe
  void setInterval(String interval) {
    if (_selectedInterval == interval) return;

    _selectedInterval = interval;

    if (_selectedPairId != null) {
      final cached = chartCacheService.getCandles(_selectedPairId!, interval);
      _candles = cached.length > _maxCandlesDisplay
          ? cached.sublist(cached.length - _maxCandlesDisplay)
          : cached;
      if (_candles.isNotEmpty) _recalculateIndicators();
      webSocketService.subscribeToPair(
        _selectedPairId!,
        ['ticker', 'ohlc'],
        interval: interval,
      );
    }

    notifyListeners();
  }

  /// Load historical candles (from REST API or merged cache+API).
  /// Keeps last [_maxCandlesDisplay] for display; cache stores full list (up to ~1 month).
  Future<void> loadHistoricalCandles(List<OHLCData> candles) async {
    try {
      _isLoading = true;
      if (_selectedPairId != null) {
        chartCacheService.putCandles(_selectedPairId!, _selectedInterval, candles);
      }
      _candles = candles.length > _maxCandlesDisplay
          ? candles.sublist(candles.length - _maxCandlesDisplay)
          : List.from(candles);
      _recalculateIndicators();
      _logger.i('📚 Historical candles loaded: ${_candles.length} (cache retained)');
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
    if (_candles.length > _maxCandlesDisplay) {
      _candles = _candles.sublist(_candles.length - _maxCandlesDisplay);
    }
    if (_selectedPairId != null) {
      chartCacheService.putCandles(_selectedPairId!, _selectedInterval, _candles);
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

  /// Cleanup resources — cancel all typed stream subscriptions
  @override
  void dispose() {
    _isDisposed = true;
    _authResponseSubscription?.cancel();
    _tickerSubscription?.cancel();
    _ohlcSubscription?.cancel();
    _workspaceRestoredSubscription?.cancel();
    webSocketService.disconnect();
    super.dispose();
  }
}
