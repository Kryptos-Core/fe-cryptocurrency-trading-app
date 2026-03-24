import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/services/token_service.dart';
import 'package:crypto_trading_app/core/services/websocket_service.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/data/datasources/dashboard_remote_datasource.dart';
import 'package:crypto_trading_app/data/datasources/fiat_withdrawals_remote_datasource.dart';
import 'package:crypto_trading_app/data/models/dashboard_summary_model.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';

/// Stale threshold: data older than this triggers a REST re-fetch on tab focus.
const _kStaleDuration = Duration(seconds: 30);

/// Dashboard Provider — Observer Pattern + ChangeNotifier
///
/// Data flow:
///   REST (initial load / stale refresh) → DashboardSummary snapshot
///   WS  (live updates) → dashboard_tickers batch every 5s → ticker map update
///
/// The provider acts as an Observer:
///   - Subscribes to [IWebSocketService.messageStream] (broadcast stream)
///   - Reacts to 'auth_response' (joins dashboard room)
///   - Reacts to 'dashboard_tickers' (updates ticker map, recalculates portfolio)
class DashboardProvider extends ChangeNotifier {
  final DashboardRemoteDataSource _datasource;
  final FiatWithdrawalsRemoteDataSource _fiatWithdrawalsRemote;
  final IWebSocketService _wsService;
  final TokenService _tokenService;
  final Logger _logger = Logger();

  // ── State ──────────────────────────────────────────────────────────────────

  DashboardSummary _summary = DashboardSummary.empty;

  /// Ticker map updated by WS live feed: symbol → MarketTicker
  final Map<String, MarketTicker> _liveTickerMap = {};

  bool _isLoading = false;
  bool _isDisposed = false;
  String? _error;
  DateTime? _lastUpdated;

  /// GET /fiat-withdrawals/providers/health (internal ops probe on dashboard).
  Map<String, dynamic>? _bankProvidersHealth;
  bool _bankProvidersHealthLoading = false;
  String? _bankProvidersHealthError;

  StreamSubscription<WebSocketMessage>? _wsAuthSubscription;
  StreamSubscription<List<TickerData>>? _wsDashboardSubscription;

  // ── Getters ────────────────────────────────────────────────────────────────

  DashboardSummary get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  bool get hasData => _summary.topMarkets.isNotEmpty;

  /// Portfolio total: from live ticker map if available, else from REST snapshot.
  double get portfolioTotal {
    if (_liveTickerMap.isEmpty) {
      return double.tryParse(_summary.portfolioTotal) ?? 0.0;
    }
    return _calculatePortfolioTotal();
  }

  int get walletCount => _summary.walletCount;
  int get activeWalletCount => _summary.activeWalletCount;

  Map<String, dynamic>? get bankProvidersHealth => _bankProvidersHealth;
  bool get bankProvidersHealthLoading => _bankProvidersHealthLoading;
  String? get bankProvidersHealthError => _bankProvidersHealthError;

  /// Top market pairs (from REST snapshot, scales included).
  List<MarketPair> get topMarkets =>
      _summary.topMarkets.map((m) => m.toMarketPair()).toList();

  /// Live ticker for a given symbol. Falls back to REST snapshot ticker.
  MarketTicker? tickerFor(String symbol) {
    if (_liveTickerMap.containsKey(symbol)) return _liveTickerMap[symbol];
    final item = _summary.topMarkets.where((m) => m.symbol == symbol).firstOrNull;
    return item?.toMarketTicker();
  }

  /// USD value for a wallet from the summary (pre-calculated on BE).
  double usdValueFor(String currencySymbol) {
    final wallet = _summary.wallets
        .where((w) => w.currencySymbol == currencySymbol)
        .firstOrNull;
    if (wallet == null) return 0.0;

    // Use live ticker price if available
    final priceSymbol = '${currencySymbol}USDT';
    final liveTicker = _liveTickerMap[priceSymbol];
    if (liveTicker != null) {
      final price = double.tryParse(liveTicker.lastPrice) ?? 0.0;
      final total = double.tryParse(wallet.total) ?? 0.0;
      if (price > 0 && total > 0) return total * price;
    }
    return double.tryParse(wallet.usdValue) ?? 0.0;
  }

  bool get _isStale =>
      _lastUpdated == null ||
      DateTime.now().difference(_lastUpdated!) > _kStaleDuration;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  DashboardProvider({
    required DashboardRemoteDataSource datasource,
    required FiatWithdrawalsRemoteDataSource fiatWithdrawalsRemote,
    required IWebSocketService wsService,
    required TokenService tokenService,
  })  : _datasource = datasource,
        _fiatWithdrawalsRemote = fiatWithdrawalsRemote,
        _wsService = wsService,
        _tokenService = tokenService;

  /// Called from DashboardScreen.initState().
  /// Fetches initial REST data and sets up WS live updates.
  Future<void> init() async {
    await Future.wait([
      _fetchInitialData(),
      _probeBankProvidersHealth(),
    ]);
    _subscribeToWsStream();
    _ensureWsConnected();
  }

  /// Smart refresh: no-op when WS is connected and data is fresh.
  /// Called on tab focus from MainScreen.
  Future<void> refresh({bool force = false}) async {
    if (!force && !_isStale) return;
    await Future.wait([
      _fetchInitialData(),
      _probeBankProvidersHealth(),
    ]);
    // Re-join dashboard room if WS is already connected
    if (_wsService.isConnected) {
      _wsService.joinDashboard();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _wsAuthSubscription?.cancel();
    _wsDashboardSubscription?.cancel();
    if (_wsService.isConnected) {
      _wsService.leaveDashboard();
    }
    super.dispose();
  }

  // ── Private ────────────────────────────────────────────────────────────────

  Future<void> _probeBankProvidersHealth() async {
    if (_bankProvidersHealthLoading) return;
    _bankProvidersHealthLoading = true;
    _bankProvidersHealthError = null;
    _notify();
    try {
      _bankProvidersHealth = await _fiatWithdrawalsRemote.getBankProvidersHealth();
    } catch (e, st) {
      _logger.w('[DashboardProvider] bank providers health probe failed: $e\n$st');
      _bankProvidersHealth = null;
      _bankProvidersHealthError = e.toString();
    } finally {
      _bankProvidersHealthLoading = false;
      _notify();
    }
  }

  Future<void> _fetchInitialData() async {
    if (_isLoading) return;
    _setLoading(true);
    try {
      _summary = await _datasource.getDashboardSummary();
      _lastUpdated = DateTime.now();
      _error = null;
    } on NetworkException {
      _error = 'Network error. Please check your connection.';
    } on ServerException catch (e) {
      // 401 means unauthenticated: show empty portfolio (guest view)
      if (e.statusCode == 401) {
        _summary = DashboardSummary.empty;
        _error = null;
      } else {
        _error = e.message.isNotEmpty ? e.message : 'Server error. Please try again.';
      }
    } catch (e) {
      _error = 'Unexpected error. Please try again.';
      _logger.e('[DashboardProvider] Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Subscribe to the shared broadcast WS stream using typed pipelines (Observer Pattern).
  void _subscribeToWsStream() {
    // auth_response → join dashboard room
    _wsAuthSubscription?.cancel();
    _wsAuthSubscription = _wsService.messageStream
        .where((m) => m.type == 'auth_response' && m.data['success'] == true)
        .listen(
          (_) {
            _wsService.joinDashboard();
            _logger.d('[DashboardProvider] WS authenticated, joined dashboard room');
          },
          onError: (e) => _logger.w('[DashboardProvider] auth stream error: $e'),
        );

    // dashboardStream → batch ticker updates every 5s
    _wsDashboardSubscription?.cancel();
    _wsDashboardSubscription = _wsService.dashboardStream.listen(
      _handleDashboardTickers,
      onError: (e) => _logger.w('[DashboardProvider] dashboardStream error: $e'),
    );
  }

  void _handleDashboardTickers(List<TickerData> tickers) {
    if (_isDisposed) return;
    for (final ticker in tickers) {
      _applyTickerUpdate(ticker);
    }
    _notify();
  }

  /// Ensure WS is connected (or connect it) then join dashboard room.
  void _ensureWsConnected() {
    if (_wsService.isConnected) {
      // Already connected — join dashboard room immediately
      _wsService.joinDashboard();
    } else {
      // Try to connect with stored token
      final token = _tokenService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        _wsService
            .connect(ApiConstants.webSocketUrl, token)
            .catchError((e) {
          _logger.w('[DashboardProvider] WS connect failed: $e');
        });
        // joinDashboard() will be called after auth_response arrives (see _handleWsMessage)
      }
    }
  }

  void _applyTickerUpdate(TickerData ticker) {
    if (ticker.symbol.isEmpty) return;

    _liveTickerMap[ticker.symbol] = MarketTicker(
      pairId: ticker.pairId,
      symbol: ticker.symbol,
      lastPrice: ticker.lastPrice.toString(),
      open24h: ticker.open24h.toString(),
      high24h: ticker.high24h.toString(),
      low24h: ticker.low24h.toString(),
      volume24h: ticker.volume24h.toString(),
      quoteVolume24h: ticker.volume24hUsd.toString(),
      change24h: ticker.changePercent24h.toString(),
      changeAmount24h: ticker.change24h.toString(),
      bestBid: ticker.bid.toString(),
      bestAsk: ticker.ask.toString(),
      timestamp: DateTime.now(),
    );
  }

  double _calculatePortfolioTotal() {
    double total = 0.0;
    const stablecoins = {'USDT', 'USDC', 'FDUSD', 'BUSD', 'DAI', 'TUSD'};

    for (final wallet in _summary.wallets) {
      final walletTotal = double.tryParse(wallet.total) ?? 0.0;
      if (walletTotal <= 0) continue;

      final symbol = wallet.currencySymbol.toUpperCase();
      if (stablecoins.contains(symbol)) {
        total += walletTotal;
      } else {
        final ticker = _liveTickerMap['${symbol}USDT'];
        final price = double.tryParse(ticker?.lastPrice ?? '0') ?? 0.0;
        if (price > 0) {
          total += walletTotal * price;
        } else {
          // Fallback to pre-calculated USD value from REST snapshot
          total += double.tryParse(wallet.usdValue) ?? 0.0;
        }
      }
    }
    return total;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _notify();
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }
}
