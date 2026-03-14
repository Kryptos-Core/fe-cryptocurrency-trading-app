import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/domain/repositories/markets_repository.dart';

enum MarketSortOption {
  symbolAsc,
  symbolDesc,
  newest,
  oldest,
  topVolume,
  topGainers,
  topLosers,
}

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
  String _searchQuery = '';
  String? _filterBaseSymbol;
  String? _filterQuoteSymbol;
  MarketSortOption _sortOption = MarketSortOption.topVolume;
  bool _fuzzySearch = true;

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
  String get searchQuery => _searchQuery;
  String? get filterBaseSymbol => _filterBaseSymbol;
  String? get filterQuoteSymbol => _filterQuoteSymbol;
  MarketSortOption get sortOption => _sortOption;
  bool get fuzzySearch => _fuzzySearch;
  bool get hasActiveFilter =>
      _searchQuery.trim().isNotEmpty ||
      (_filterBaseSymbol != null && _filterBaseSymbol!.trim().isNotEmpty) ||
      (_filterQuoteSymbol != null && _filterQuoteSymbol!.trim().isNotEmpty) ||
      _sortOption != MarketSortOption.topVolume ||
      _fuzzySearch != true;

  /// Fetch markets with optional filters.
  /// [includeTickers] when true, GET /markets returns tickers for current page; they are merged into [allTickers] (one request instead of separate GET /markets/tickers/all).
  /// [search] partial symbol search; [baseSymbol], [quoteSymbol] filter by base/quote currency.
  Future<void> fetchMarkets({
    bool? includeInactive,
    bool refresh = false,
    bool includeTickers = false,
    String? search,
    String? baseSymbol,
    String? quoteSymbol,
    MarketSortOption? sortOption,
    bool? fuzzySearch,
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
    if (search != null) {
      _searchQuery = search;
    }
    if (baseSymbol != null) {
      _filterBaseSymbol = baseSymbol.isEmpty ? null : baseSymbol;
    }
    if (quoteSymbol != null) {
      _filterQuoteSymbol = quoteSymbol.isEmpty ? null : quoteSymbol;
    }
    if (sortOption != null) {
      _sortOption = sortOption;
    }
    if (fuzzySearch != null) {
      _fuzzySearch = fuzzySearch;
    }
    notifyListeners();

    final backendSort = _toBackendSort(_sortOption);

    final result = await _marketsRepository.getMarkets(
      page: _currentPage,
      limit: _pageSize,
      includeInactive: _includeInactive,
      includeTickers: includeTickers,
      search: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
      baseSymbol: _filterBaseSymbol?.trim().isEmpty ?? true
          ? null
          : _filterBaseSymbol?.trim(),
      quoteSymbol: _filterQuoteSymbol?.trim().isEmpty ?? true
          ? null
          : _filterQuoteSymbol?.trim(),
      sortBy: backendSort.$1,
      sortOrder: backendSort.$2,
      fuzzySearch: _fuzzySearch,
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
        if (paginatedResult.tickers != null &&
            paginatedResult.tickers!.isNotEmpty) {
          final byPairId = Map<String, MarketTicker>.fromEntries(
            _allTickers.map((t) => MapEntry(t.pairId, t)),
          );
          for (final t in paginatedResult.tickers!) {
            byPairId[t.pairId] = t;
          }
          _allTickers = byPairId.values.toList();
        }

        _applyLocalSort();

        // If no tickers in response, keep existing _allTickers; UI may call fetchTickersForPairs for visible pairs (avoids slow GET /markets/tickers/all timeout).

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

  /// Update search query and refetch (call with debounced value from UI).
  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    fetchMarkets(refresh: true, includeTickers: true);
  }

  /// Set filter by base currency symbol and refetch.
  void setFilterBaseSymbol(String? symbol) {
    if (_filterBaseSymbol == symbol) return;
    _filterBaseSymbol = symbol?.trim().isEmpty ?? true ? null : symbol?.trim();
    fetchMarkets(refresh: true, includeTickers: true);
  }

  /// Set filter by quote currency symbol and refetch.
  void setFilterQuoteSymbol(String? symbol) {
    if (_filterQuoteSymbol == symbol) return;
    _filterQuoteSymbol = symbol?.trim().isEmpty ?? true ? null : symbol?.trim();
    fetchMarkets(refresh: true, includeTickers: true);
  }

  void setSortOption(MarketSortOption option) {
    if (_sortOption == option) return;
    _sortOption = option;
    fetchMarkets(refresh: true, includeTickers: true);
  }

  void setFuzzySearch(bool enabled) {
    if (_fuzzySearch == enabled) return;
    _fuzzySearch = enabled;
    fetchMarkets(refresh: true, includeTickers: true);
  }

  /// Clear all search and filters, then refetch.
  void clearSearchAndFilters() {
    _searchQuery = '';
    _filterBaseSymbol = null;
    _filterQuoteSymbol = null;
    _sortOption = MarketSortOption.topVolume;
    _fuzzySearch = true;
    fetchMarkets(refresh: true, includeTickers: true);
  }

  /// Refresh data while keeping current scroll position (re-fetches all loaded pages).
  /// Use when user taps Refresh: same number of items, updated data and tickers.
  Future<void> refreshKeepingPosition() async {
    final pagesLoaded =
        _markets.isEmpty ? 1 : (_markets.length / _pageSize).ceil();
    if (pagesLoaded < 1) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final combined = <MarketPair>[];
    final tickersByPairId = <String, MarketTicker>{};
    var total = _total;
    var lastPage = 0;

    for (var k = 1; k <= pagesLoaded; k++) {
      final result = await _marketsRepository.getMarkets(
        page: k,
        limit: _pageSize,
        includeInactive: _includeInactive,
        includeTickers: true,
        search: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
        baseSymbol: _filterBaseSymbol?.trim().isEmpty ?? true
            ? null
            : _filterBaseSymbol?.trim(),
        quoteSymbol: _filterQuoteSymbol?.trim().isEmpty ?? true
            ? null
            : _filterQuoteSymbol?.trim(),
        sortBy: _toBackendSort(_sortOption).$1,
        sortOrder: _toBackendSort(_sortOption).$2,
        fuzzySearch: _fuzzySearch,
      );

      result.fold(
        (failure) {
          _error = _mapFailureToMessage(failure);
          _isLoading = false;
          // Do not replace _markets with partial combined on failure; keep current list.
          notifyListeners();
        },
        (paginatedResult) {
          combined.addAll(paginatedResult.markets);
          total = paginatedResult.total;
          lastPage = k;
          for (final t in paginatedResult.tickers ?? []) {
            if (t.pairId.isNotEmpty) tickersByPairId[t.pairId] = t;
          }
        },
      );

      if (_error != null) return;
    }

    _markets = combined;
    _total = total;
    _currentPage = lastPage + 1;
    _hasMore = _markets.length < _total;
    _allTickers = tickersByPairId.values.toList();
    _applyLocalSort();

    _isLoading = false;
    _error = null;
    notifyListeners();
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
        _applyLocalSort();
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
    _applyLocalSort();
    notifyListeners();
  }

  (String, String) _toBackendSort(MarketSortOption option) {
    switch (option) {
      case MarketSortOption.symbolDesc:
        return ('symbol', 'desc');
      case MarketSortOption.newest:
        return ('createdAt', 'desc');
      case MarketSortOption.oldest:
        return ('createdAt', 'asc');
      case MarketSortOption.symbolAsc:
      case MarketSortOption.topVolume:
      case MarketSortOption.topGainers:
      case MarketSortOption.topLosers:
        return ('symbol', 'asc');
    }
  }

  void _applyLocalSort() {
    if (_markets.isEmpty) return;
    final tickerByPairId = {
      for (final t in _allTickers)
        if (t.pairId.isNotEmpty) t.pairId: t,
    };
    double asDouble(String value) => double.tryParse(value) ?? 0;

    int compareTicker(
        MarketPair a, MarketPair b, String Function(MarketTicker) valueOf,
        {bool desc = true}) {
      final ta = tickerByPairId[a.pairId];
      final tb = tickerByPairId[b.pairId];
      final va = ta == null ? 0 : asDouble(valueOf(ta));
      final vb = tb == null ? 0 : asDouble(valueOf(tb));
      return desc ? vb.compareTo(va) : va.compareTo(vb);
    }

    switch (_sortOption) {
      case MarketSortOption.symbolAsc:
        _markets.sort((a, b) => a.symbol.compareTo(b.symbol));
        break;
      case MarketSortOption.symbolDesc:
        _markets.sort((a, b) => b.symbol.compareTo(a.symbol));
        break;
      case MarketSortOption.newest:
      case MarketSortOption.oldest:
        // Keep backend ordering for createdAt sorts to preserve cross-page consistency.
        break;
      case MarketSortOption.topVolume:
        _markets.sort((a, b) => compareTicker(a, b, (t) => t.volume24h));
        break;
      case MarketSortOption.topGainers:
        _markets.sort((a, b) => compareTicker(a, b, (t) => t.change24h));
        break;
      case MarketSortOption.topLosers:
        _markets.sort(
            (a, b) => compareTicker(a, b, (t) => t.change24h, desc: false));
        break;
    }
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
