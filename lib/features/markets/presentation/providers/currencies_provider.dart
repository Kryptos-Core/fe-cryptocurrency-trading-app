import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/features/markets/domain/dtos/create_currency_dto.dart';
import 'package:crypto_trading_app/features/markets/domain/dtos/update_currency_dto.dart';
import 'package:crypto_trading_app/features/markets/domain/entities/currency.dart';
import 'package:crypto_trading_app/features/markets/domain/repositories/currencies_repository.dart';

/// Sort options for the user-facing currency list.
///
/// Order matches the dropdown UI.
enum CurrencySortMode {
  topVolume,
  topGainers,
  topLosers,
  alphabet,
}

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
  CurrencySortMode _sortMode = CurrencySortMode.topVolume;

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
  CurrencySortMode get sortMode => _sortMode;

  /// True when the user has narrowed the list via search, status or trading
  /// filters. Used by the list screen to decide between "no results" and
  /// "no data yet" copy, and to surface a clear-filters button.
  bool get hasActiveFilter =>
      _searchQuery.isNotEmpty ||
      _filterTradable != null ||
      _filterIsActive != null ||
      _includeInactive;

  /// Client-side sort applied on top of the paginated repository result.
  List<Currency> get sortedCurrencies =>
      _sortCurrencies([..._currencies], _sortMode);

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

  // ── Filter / sort API ─────────────────────────────────────────────────────

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

  /// Update the search query. The query is debounced client-side by the
  /// search field widget before this method is invoked.
  Future<void> setSearch(String value) async {
    final normalized = value.toLowerCase().trim();
    if (normalized == _searchQuery) return;
    await applyFilters(search: normalized);
  }

  /// Set the active trading filter (`true` = tradable only, `false` = paused
  /// only, `null` = no trading filter).
  Future<void> setTradingFilter({required bool? isTradable}) async {
    if (_filterTradable == isTradable) return;
    await applyFilters(isTradable: isTradable);
  }

  /// Set the active status filter (`true` = active only, `false` = inactive
  /// only, `null` = governed by [includeInactive]).
  Future<void> setStatusFilter({required bool? isActive}) async {
    if (_filterIsActive == isActive) return;
    await applyFilters(
      isActive: isActive,
      includeInactive: isActive == null
          ? false
          : (isActive == false ? true : _includeInactive),
    );
  }

  /// Switch the local sort mode. The list is re-sorted in place — no
  /// re-fetch because pagination is already stable.
  void setSortMode(CurrencySortMode mode) {
    if (_sortMode == mode) return;
    _sortMode = mode;
    notifyListeners();
  }

  /// Reset all filters and sort to their defaults and re-fetch.
  Future<void> clearFilters() async {
    await applyFilters(
      search: '',
      isTradable: null,
      isActive: null,
      includeInactive: false,
    );
    _sortMode = CurrencySortMode.topVolume;
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

          // Reset to last complete page to avoid duplicates if repository
          // returned overlapping rows after filter changes.
          _currencies = _dedupeById(_currencies);
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
        _error = _mapFailureToMessage(failure);
        _isLoading = false;
        _safeNotify();
        return _error;
      },
      (created) {
        _currencies = [created, ..._currencies];
        _total = _total + 1;
        _isLoading = false;
        _safeNotify();
        return null;
      },
    );
  }

  /// Update an existing currency. Returns error message or null on success.
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
        _currencies =
            _currencies.where((c) => c.currencyId != currencyId).toList();
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
    if (failure is ServerFailure) {
      return failure.message.isNotEmpty ? failure.message : 'Lỗi máy chủ.';
    }
    if (failure is NetworkFailure) {
      return 'Lỗi mạng. Vui lòng kiểm tra kết nối.';
    }
    if (failure is NotFoundFailure) return 'Coin không tồn tại.';
    if (failure is ValidationFailure) {
      return failure.message.isNotEmpty
          ? failure.message
          : 'Dữ liệu không hợp lệ.';
    }
    return 'Đã xảy ra lỗi không xác định.';
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static List<Currency> _dedupeById(List<Currency> input) {
    final seen = <String>{};
    final result = <Currency>[];
    for (final c in input) {
      if (seen.add(c.currencyId)) result.add(c);
    }
    return result;
  }

  static List<Currency> _sortCurrencies(
    List<Currency> input,
    CurrencySortMode mode,
  ) {
    final sorted = [...input];
    int desc(double? a, double? b) {
      if (a == null && b == null) return 0;
      if (a == null) return 1;
      if (b == null) return -1;
      return b.compareTo(a);
    }

    int asc(double? a, double? b) {
      if (a == null && b == null) return 0;
      if (a == null) return 1;
      if (b == null) return -1;
      return a.compareTo(b);
    }

    double? num(String? v) {
      if (v == null || v.trim().isEmpty) return null;
      return double.tryParse(v);
    }

    switch (mode) {
      case CurrencySortMode.topVolume:
        sorted.sort(
          (a, b) => desc(num(a.volume24h), num(b.volume24h)),
        );
        break;
      case CurrencySortMode.topGainers:
        sorted.sort(
          (a, b) =>
              desc(num(a.priceChangePercent24h), num(b.priceChangePercent24h)),
        );
        break;
      case CurrencySortMode.topLosers:
        sorted.sort(
          (a, b) =>
              asc(num(a.priceChangePercent24h), num(b.priceChangePercent24h)),
        );
        break;
      case CurrencySortMode.alphabet:
        sorted.sort((a, b) => a.symbol.compareTo(b.symbol));
        break;
    }

    return sorted;
  }
}
