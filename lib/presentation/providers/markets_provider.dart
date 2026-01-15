import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/domain/usecases/markets_usecases.dart';

/// Markets Provider
/// Following Provider Pattern for State Management
class MarketsProvider extends ChangeNotifier {
  final GetMarketsUseCase getMarketsUseCase;
  final GetMarketByIdUseCase getMarketByIdUseCase;
  final GetMarketBySymbolUseCase getMarketBySymbolUseCase;
  final GetMarketTickerUseCase getMarketTickerUseCase;
  final GetOrderBookUseCase getOrderBookUseCase;
  final GetOHLCVUseCase getOHLCVUseCase;

  MarketsProvider({
    required this.getMarketsUseCase,
    required this.getMarketByIdUseCase,
    required this.getMarketBySymbolUseCase,
    required this.getMarketTickerUseCase,
    required this.getOrderBookUseCase,
    required this.getOHLCVUseCase,
  });

  // State
  List<MarketPair> _markets = [];
  MarketPair? _selectedMarket;
  MarketTicker? _ticker;
  OrderBook? _orderBook;
  List<OHLCV> _ohlcv = [];
  String _selectedInterval = '1h';
  bool _isLoading = false;
  String? _error;
  bool? _filterIsActive;
  String? _filterBaseCurrency;
  String? _filterQuoteCurrency;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMore = true;

  // Getters
  List<MarketPair> get markets => _markets;
  MarketPair? get selectedMarket => _selectedMarket;
  MarketTicker? get ticker => _ticker;
  OrderBook? get orderBook => _orderBook;
  List<OHLCV> get ohlcv => _ohlcv;
  String get selectedInterval => _selectedInterval;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  /// Fetch markets with optional filters
  Future<void> fetchMarkets({
    bool? isActive,
    String? baseCurrency,
    String? quoteCurrency,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _markets = [];
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _error = null;
    _filterIsActive = isActive;
    _filterBaseCurrency = baseCurrency;
    _filterQuoteCurrency = quoteCurrency;
    notifyListeners();

    final result = await getMarketsUseCase(
      GetMarketsParams(
        isActive: isActive,
        baseCurrency: baseCurrency,
        quoteCurrency: quoteCurrency,
        page: _currentPage,
        limit: _pageSize,
      ),
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (markets) {
        if (refresh) {
          _markets = markets;
        } else {
          _markets.addAll(markets);
        }

        _hasMore = markets.length == _pageSize;
        if (_hasMore) {
          _currentPage++;
        }

        _isLoading = false;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Load more markets (pagination)
  Future<void> loadMore() async {
    if (!_isLoading && _hasMore) {
      await fetchMarkets(
        isActive: _filterIsActive,
        baseCurrency: _filterBaseCurrency,
        quoteCurrency: _filterQuoteCurrency,
      );
    }
  }

  /// Get market by ID
  Future<void> getMarketById(int pairId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getMarketByIdUseCase(pairId);

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _selectedMarket = null;
        _isLoading = false;
        notifyListeners();
      },
      (market) {
        _selectedMarket = market;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Get market by symbol
  Future<void> getMarketBySymbol(String symbol) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getMarketBySymbolUseCase(symbol);

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _selectedMarket = null;
        _isLoading = false;
        notifyListeners();
      },
      (market) {
        _selectedMarket = market;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Get market ticker
  Future<void> fetchTicker(int pairId) async {
    _error = null;
    notifyListeners();

    final result = await getMarketTickerUseCase(pairId);

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _ticker = null;
        notifyListeners();
      },
      (ticker) {
        _ticker = ticker;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Get order book
  Future<void> fetchOrderBook(int pairId, {int limit = 20}) async {
    _error = null;
    notifyListeners();

    final result = await getOrderBookUseCase(
      GetOrderBookParams(pairId: pairId, limit: limit),
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _orderBook = null;
        notifyListeners();
      },
      (orderBook) {
        _orderBook = orderBook;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Get OHLCV data
  Future<void> fetchOHLCV({
    required int pairId,
    String? interval,
    int limit = 100,
  }) async {
    if (interval != null) {
      _selectedInterval = interval;
    }

    _error = null;
    notifyListeners();

    final result = await getOHLCVUseCase(
      GetOHLCVParams(
        pairId: pairId,
        interval: _selectedInterval,
        limit: limit,
      ),
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _ohlcv = [];
        notifyListeners();
      },
      (ohlcv) {
        _ohlcv = ohlcv;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Clear selected market
  void clearSelectedMarket() {
    _selectedMarket = null;
    _ticker = null;
    _orderBook = null;
    _ohlcv = [];
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error. Please try again later.';
      case NetworkFailure:
        return 'Network error. Please check your connection.';
      case NotFoundFailure:
        return 'Market not found.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
