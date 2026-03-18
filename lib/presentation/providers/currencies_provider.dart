import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/data/models/create_currency_dto.dart';
import 'package:crypto_trading_app/data/models/update_currency_dto.dart';
import 'package:crypto_trading_app/domain/entities/currency.dart';
import 'package:crypto_trading_app/domain/repositories/currencies_repository.dart';

/// Currencies Provider
/// Following Provider Pattern for State Management
/// Single Responsibility: Manage currencies state
class CurrenciesProvider extends ChangeNotifier {
  final CurrenciesRepository _currenciesRepository;

  CurrenciesProvider({required CurrenciesRepository currenciesRepository})
      : _currenciesRepository = currenciesRepository;

  // ── Pagination & list state ────────────────────────────────────────────────
  List<Currency> _currencies = [];
  List<Currency> _tradableCurrencies = [];
  Currency? _selectedCurrency;
  bool _isLoading = false;
  String? _error;
  bool _includeInactive = false;
  int _currentPage = 1;
  final int _pageSize = 10;
  int _total = 0;
  bool _hasMore = true;

  // ── Filter state ───────────────────────────────────────────────────────────
  String _searchQuery = '';
  bool? _filterTradable; // null = no filter
  bool? _filterIsActive; // null = governed by _includeInactive

  // ── Getters ────────────────────────────────────────────────────────────────
  List<Currency> get currencies => _currencies;
  List<Currency> get tradableCurrencies => _tradableCurrencies;
  Currency? get selectedCurrency => _selectedCurrency;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get includeInactive => _includeInactive;
  int get currentPage => _currentPage;
  int get total => _total;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  bool? get filterTradable => _filterTradable;
  bool? get filterIsActive => _filterIsActive;

  // ── Safe notify ────────────────────────────────────────────────────────────

  /// Defers notification to post-frame when called during Flutter's layout/paint
  /// phase (persistentCallbacks) to prevent '!_debugDoingThisLayout' on desktop.
  void _safeNotify() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }

  // ── Filter API ─────────────────────────────────────────────────────────────

  /// Apply new filter values, reset pagination and re-fetch.
  ///
  /// Pass `null` to clear a filter, pass a value to set it.
  /// Call with no arguments to just reset/refresh with current filters.
  Future<void> applyFilters({
    String? search,
    bool? isTradable,
    bool? isActive,
    bool? includeInactive,
  }) async {
    _searchQuery = search ?? '';
    _filterTradable = isTradable;
    _filterIsActive = isActive;
    if (includeInactive != null) _includeInactive = includeInactive;
    _currentPage = 1;
    _currencies = [];
    _hasMore = true;
    _total = 0;
    notifyListeners();
    await fetchCurrencies(refresh: false);
  }

  // ── Fetch ──────────────────────────────────────────────────────────────────

  /// Fetch currencies respecting current search query + filter state.
  ///
  /// [includeInactive] overrides the stored flag (used for first-time load or
  /// toggle). [refresh] resets pagination before fetching.
  Future<void> fetchCurrencies({
    bool? includeInactive,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _currencies = [];
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

    final result = await _currenciesRepository.getCurrencies(
      page: _currentPage,
      limit: _pageSize,
      includeInactive: _includeInactive,
      search: _searchQuery.isEmpty ? null : _searchQuery,
      isTradable: _filterTradable,
      isActive: _filterIsActive,
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _isLoading = false;
        _safeNotify();
      },
      (paginatedResult) {
        final fetched = paginatedResult.currencies;
        if (refresh || _currentPage == 1) {
          _currencies = fetched;
        } else {
          _currencies.addAll(fetched);
        }

        _total = paginatedResult.total;
        _hasMore = _currencies.length < _total;
        if (_hasMore) {
          _currentPage++;
        }

        _isLoading = false;
        _error = null;
        _safeNotify();
      },
    );
  }

  /// Load more currencies (infinite scroll).
  Future<void> loadMore() async {
    if (!_isLoading && _hasMore) {
      await fetchCurrencies();
    }
  }

  /// Fetch tradable currencies (for dropdowns, e.g. quote filter in markets).
  Future<void> fetchTradableCurrencies() async {
    final result = await _currenciesRepository.getTradableCurrencies();
    result.fold(
      (_) => _tradableCurrencies = [],
      (list) => _tradableCurrencies = list,
    );
    notifyListeners();
  }

  /// Get currency by ID.
  Future<void> getCurrencyById(String currencyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _currenciesRepository.getCurrencyById(currencyId);

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _selectedCurrency = null;
        _isLoading = false;
        _safeNotify();
      },
      (currency) {
        _selectedCurrency = currency;
        _isLoading = false;
        _error = null;
        _safeNotify();
      },
    );
  }

  /// Get currency by symbol.
  Future<void> getCurrencyBySymbol(String symbol) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _currenciesRepository.getCurrencyBySymbol(symbol);

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _selectedCurrency = null;
        _isLoading = false;
        _safeNotify();
      },
      (currency) {
        _selectedCurrency = currency;
        _isLoading = false;
        _error = null;
        _safeNotify();
      },
    );
  }

  void clearSelectedCurrency() {
    _selectedCurrency = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Admin CRUD Methods ─────────────────────────────────────────────────────

  /// Toggle `isActive` for a currency. Returns error message or null on success.
  Future<String?> toggleActive(String currencyId, bool isActive) {
    return updateCurrency(currencyId, UpdateCurrencyDto(isActive: isActive));
  }

  /// Toggle `isTradable` for a currency. Returns error message or null on success.
  Future<String?> toggleTradable(String currencyId, bool isTradable) {
    return updateCurrency(currencyId, UpdateCurrencyDto(isTradable: isTradable));
  }

  /// Create a new currency. Returns error message or null on success.
  Future<String?> createCurrency(CreateCurrencyDto dto) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _currenciesRepository.createCurrency(dto);

    return result.fold(
      (failure) {
        _isLoading = false;
        _safeNotify();
        return _mapFailureToMessage(failure);
      },
      (currency) {
        _currencies = [currency, ..._currencies];
        _total++;
        _isLoading = false;
        _safeNotify();
        return null;
      },
    );
  }

  /// Update a currency. Returns error message or null on success.
  Future<String?> updateCurrency(String currencyId, UpdateCurrencyDto dto) async {
    final result = await _currenciesRepository.updateCurrency(currencyId, dto);

    return result.fold(
      (failure) => _mapFailureToMessage(failure),
      (updated) {
        _currencies = _currencies.map((c) {
          return c.currencyId == currencyId ? updated : c;
        }).toList();
        if (_selectedCurrency?.currencyId == currencyId) {
          _selectedCurrency = updated;
        }
        _safeNotify();
        return null;
      },
    );
  }

  /// Delete (soft-delete) a currency. Returns error message or null on success.
  Future<String?> deleteCurrency(String currencyId) async {
    final result = await _currenciesRepository.deleteCurrency(currencyId);

    return result.fold(
      (failure) => _mapFailureToMessage(failure),
      (_) {
        _currencies = _currencies.where((c) => c.currencyId != currencyId).toList();
        if (_selectedCurrency?.currencyId == currencyId) {
          _selectedCurrency = null;
        }
        if (_total > 0) _total--;
        _safeNotify();
        return null;
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message.isNotEmpty ? failure.message : 'Lỗi máy chủ.';
    if (failure is NetworkFailure) return 'Lỗi mạng. Vui lòng kiểm tra kết nối.';
    if (failure is NotFoundFailure) return 'Coin không tồn tại.';
    if (failure is ValidationFailure) return failure.message.isNotEmpty ? failure.message : 'Dữ liệu không hợp lệ.';
    return 'Đã xảy ra lỗi không xác định.';
  }
}
