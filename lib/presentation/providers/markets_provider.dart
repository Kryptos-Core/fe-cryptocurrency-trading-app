import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/domain/repositories/markets_repository.dart';

/// Markets Provider
/// Following Provider Pattern for State Management
/// Single Responsibility: Manage markets state
class MarketsProvider extends ChangeNotifier {
  final MarketsRepository _marketsRepository;

  MarketsProvider({required MarketsRepository marketsRepository})
      : _marketsRepository = marketsRepository;

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

  /// Fetch markets with optional filters.
  /// [includeTickers] when true, GET /markets returns tickers for current page; they are merged into [allTickers] (one request instead of separate GET /markets/tickers/all).
  Future<void> fetchMarkets({
    bool? includeInactive,
    bool refresh = false,
    bool includeTickers = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _markets = [];
      _hasMore = true;
      _total = 0;
      if (includeTickers) _allTickers = [];
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _error = null;
    if (includeInactive != null) {
      _includeInactive = includeInactive;
    }
    notifyListeners();

    final result = await _marketsRepository.getMarkets(
      page: _currentPage,
      limit: _pageSize,
      includeInactive: _includeInactive,
      includeTickers: includeTickers,
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

        // Merge tickers from this page (when includeTickers=true) into _allTickers by pairId
        if (paginatedResult.tickers != null && paginatedResult.tickers!.isNotEmpty) {
          final byPairId = Map<String, MarketTicker>.fromEntries(
            _allTickers.map((t) => MapEntry(t.pairId, t)),
          );
          for (final t in paginatedResult.tickers!) {
            byPairId[t.pairId] = t;
          }
          _allTickers = byPairId.values.toList();
        }

        // Fallback: if we asked for tickers but got none (e.g. backend does not support includeTickers), fetch all tickers once
        if (includeTickers && refresh && (paginatedResult.tickers == null || paginatedResult.tickers!.isEmpty) && markets.isNotEmpty) {
          _marketsRepository.getAllTickers().then((either) {
            either.fold((_) {}, (list) {
              _allTickers = list;
              notifyListeners();
            });
          });
        }

        _total = paginatedResult.total;
        _hasMore = _markets.length < _total && markets.length == _pageSize;
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

    final result = await _marketsRepository.getActiveMarkets();

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
      includeTickers: true,
    );
  }

  /// Get market by ID
  Future<void> getMarketById(String pairId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _marketsRepository.getMarketById(pairId);

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

    final result = await _marketsRepository.getMarketBySymbol(symbol);

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

    final result = await _marketsRepository.getMarketTicker(pairId);

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

    final result = await _marketsRepository.getMarketTickerBySymbol(symbol);

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

  /// Get all tickers for active markets (e.g. GET /markets/tickers/all).
  /// On failure, keeps existing _allTickers so tickers from GET /markets?includeTickers=true are not lost.
  Future<void> fetchAllTickers() async {
    _error = null;
    notifyListeners();

    final result = await _marketsRepository.getAllTickers();

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        // Do not clear _allTickers so tickers from paginated response are kept
        notifyListeners();
      },
      (tickers) {
        _allTickers = tickers;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Fallback: fetch ticker per pair (GET /markets/:id/ticker) and merge into [allTickers].
  /// Use when GET /markets/tickers/all is empty or returns zeros; single-pair endpoint often has real data.
  Future<void> fetchTickersForPairs(List<String> pairIds) async {
    if (pairIds.isEmpty) return;
    final byPairId = <String, MarketTicker>{
      for (final t in _allTickers) t.pairId: t,
    };
    for (final id in pairIds) {
      final result = await _marketsRepository.getMarketTicker(id);
      result.fold(
        (_) {},
        (ticker) => byPairId[ticker.pairId] = ticker,
      );
    }
    _allTickers = byPairId.values.toList();
    notifyListeners();
  }

  /// Get order book by ID
  Future<void> fetchOrderBook(String pairId, {int limit = 20}) async {
    _error = null;
    notifyListeners();

    final result = await _marketsRepository.getOrderBook(
      pairId: pairId,
      limit: limit,
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

    final result = await _marketsRepository.getOrderBookBySymbol(
      symbol: symbol,
      limit: limit,
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

    final result = await _marketsRepository.getTrades(
      pairId: pairId,
      limit: limit,
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

    final result = await _marketsRepository.getTradesBySymbol(
      symbol: symbol,
      limit: limit,
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

    final result = await _marketsRepository.getOHLCV(
      pairId: pairId,
      interval: _selectedInterval,
      range: range,
      limit: range != null ? 500 : limit,
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
