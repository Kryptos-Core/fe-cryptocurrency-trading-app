import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/core/usecases/usecase.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/domain/usecases/markets_usecases.dart';

/// Markets Provider
/// Following Provider Pattern for State Management
/// Single Responsibility: Manage markets state
class MarketsProvider extends ChangeNotifier {
  final GetMarketsUseCase getMarketsUseCase;
  final GetActiveMarketsUseCase getActiveMarketsUseCase;
  final GetMarketByIdUseCase getMarketByIdUseCase;
  final GetMarketBySymbolUseCase getMarketBySymbolUseCase;
  final GetMarketTickerUseCase getMarketTickerUseCase;
  final GetMarketTickerBySymbolUseCase getMarketTickerBySymbolUseCase;
  final GetAllTickersUseCase getAllTickersUseCase;
  final GetOrderBookUseCase getOrderBookUseCase;
  final GetOrderBookBySymbolUseCase getOrderBookBySymbolUseCase;
  final GetTradesUseCase getTradesUseCase;
  final GetTradesBySymbolUseCase getTradesBySymbolUseCase;
  final GetOHLCVUseCase getOHLCVUseCase;

  MarketsProvider({
    required this.getMarketsUseCase,
    required this.getActiveMarketsUseCase,
    required this.getMarketByIdUseCase,
    required this.getMarketBySymbolUseCase,
    required this.getMarketTickerUseCase,
    required this.getMarketTickerBySymbolUseCase,
    required this.getAllTickersUseCase,
    required this.getOrderBookUseCase,
    required this.getOrderBookBySymbolUseCase,
    required this.getTradesUseCase,
    required this.getTradesBySymbolUseCase,
    required this.getOHLCVUseCase,
  });

  // State
  List<MarketPair> _markets = [];
  MarketPair? _selectedMarket;
  MarketTicker? _ticker;
  List<MarketTicker> _allTickers = [];
  OrderBook? _orderBook;
  List<Trade> _trades = [];
  List<OHLCV> _ohlcv = [];
  String _selectedInterval = '1m';
  bool _isLoading = false;
  String? _error;
  bool _includeInactive = false;
  int _currentPage = 1;
  final int _pageSize = 10;
  int _total = 0;
  bool _hasMore = true;

  // Getters
  List<MarketPair> get markets => _markets;
  MarketPair? get selectedMarket => _selectedMarket;
  MarketTicker? get ticker => _ticker;
  List<MarketTicker> get allTickers => _allTickers;
  OrderBook? get orderBook => _orderBook;
  List<Trade> get trades => _trades;
  List<OHLCV> get ohlcv => _ohlcv;
  String get selectedInterval => _selectedInterval;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get includeInactive => _includeInactive;
  int get currentPage => _currentPage;
  int get total => _total;
  bool get hasMore => _hasMore;

  /// Fetch markets with optional filters
  Future<void> fetchMarkets({
    bool? includeInactive,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _markets = [];
      _hasMore = true;
      _total = 0;
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _error = null;
    if (includeInactive != null) {
      _includeInactive = includeInactive;
    }
    notifyListeners();

    final result = await getMarketsUseCase(
      GetMarketsParams(
        page: _currentPage,
        limit: _pageSize,
        includeInactive: _includeInactive,
      ),
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (paginatedResult) {
        final markets = paginatedResult.markets;
        if (refresh) {
          _markets = markets;
          _currentPage = 1;
        } else {
          _markets.addAll(markets);
        }

        _total = paginatedResult.total;
        // Update hasMore: check if we have more items to load
        _hasMore = _markets.length < _total && markets.length == _pageSize;

        // Only increment page if we got a full page of results
        if (markets.length == _pageSize && _hasMore) {
          _currentPage++;
        }

        _isLoading = false;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Fetch active markets (cached endpoint)
  Future<void> fetchActiveMarkets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getActiveMarketsUseCase(NoParams());

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (markets) {
        _markets = markets;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Load more markets (pagination)
  Future<void> loadMore() async {
    // Prevent multiple simultaneous load more calls
    if (_isLoading || !_hasMore) {
      return;
    }

    // Check if we've already loaded all data
    if (_markets.length >= _total) {
      _hasMore = false;
      notifyListeners();
      return;
    }

    await fetchMarkets(
      includeInactive: _includeInactive,
    );
  }

  /// Get market by ID
  Future<void> getMarketById(String pairId) async {
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

  /// Get market ticker by ID
  Future<void> fetchTicker(String pairId) async {
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

  /// Get market ticker by symbol
  Future<void> fetchTickerBySymbol(String symbol) async {
    _error = null;
    notifyListeners();

    final result = await getMarketTickerBySymbolUseCase(symbol);

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

  /// Get all tickers for active markets
  Future<void> fetchAllTickers() async {
    _error = null;
    notifyListeners();

    final result = await getAllTickersUseCase(NoParams());

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _allTickers = [];
        notifyListeners();
      },
      (tickers) {
        _allTickers = tickers;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Get order book by ID
  Future<void> fetchOrderBook(String pairId, {int limit = 20}) async {
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

  /// Get order book by symbol
  Future<void> fetchOrderBookBySymbol(String symbol, {int limit = 20}) async {
    _error = null;
    notifyListeners();

    final result = await getOrderBookBySymbolUseCase(
      GetOrderBookBySymbolParams(symbol: symbol, limit: limit),
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

  /// Get recent trades by ID
  Future<void> fetchTrades(String pairId, {int limit = 50}) async {
    _error = null;
    notifyListeners();

    final result = await getTradesUseCase(
      GetTradesParams(pairId: pairId, limit: limit),
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _trades = [];
        notifyListeners();
      },
      (trades) {
        _trades = trades;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Get recent trades by symbol
  Future<void> fetchTradesBySymbol(String symbol, {int limit = 50}) async {
    _error = null;
    notifyListeners();

    final result = await getTradesBySymbolUseCase(
      GetTradesBySymbolParams(symbol: symbol, limit: limit),
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _trades = [];
        notifyListeners();
      },
      (trades) {
        _trades = trades;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Get OHLCV data
  /// [range] optional: 1d, 1M, 3M, 1y, 5y – khi có range sẽ dùng interval gợi ý (1d→1m, 1M→1h, 3M→4h, 1y/5y→1d)
  Future<void> fetchOHLCV({
    required String pairId,
    String? interval,
    String? range,
    int limit = 100,
  }) async {
    if (range != null) {
      _selectedInterval = ApiConstants.intervalForRange(range);
    } else if (interval != null) {
      _selectedInterval = interval;
    }

    _error = null;
    notifyListeners();

    final result = await getOHLCVUseCase(
      GetOHLCVParams(
        pairId: pairId,
        interval: _selectedInterval,
        range: range,
        limit: range != null ? 500 : limit,
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
    _trades = [];
    _ohlcv = [];
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return failure.message;
    } else if (failure is NotFoundFailure) {
      return failure.message;
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is AuthenticationFailure) {
      return failure.message;
    } else {
      return 'An unexpected error occurred.';
    }
  }
}
