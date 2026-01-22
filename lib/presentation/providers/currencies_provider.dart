import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/currency.dart';
import 'package:crypto_trading_app/domain/usecases/currencies_usecases.dart';

/// Currencies Provider
/// Following Provider Pattern for State Management
/// Single Responsibility: Manage currencies state
class CurrenciesProvider extends ChangeNotifier {
  final GetCurrenciesUseCase getCurrenciesUseCase;
  final GetCurrencyByIdUseCase getCurrencyByIdUseCase;
  final GetCurrencyBySymbolUseCase getCurrencyBySymbolUseCase;

  CurrenciesProvider({
    required this.getCurrenciesUseCase,
    required this.getCurrencyByIdUseCase,
    required this.getCurrencyBySymbolUseCase,
  });

  // State
  List<Currency> _currencies = [];
  Currency? _selectedCurrency;
  bool _isLoading = false;
  String? _error;
  bool _includeInactive = false;
  int _currentPage = 1;
  final int _pageSize = 10;
  int _total = 0;
  bool _hasMore = true;

  // Getters
  List<Currency> get currencies => _currencies;
  Currency? get selectedCurrency => _selectedCurrency;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get includeInactive => _includeInactive;
  int get currentPage => _currentPage;
  int get total => _total;
  bool get hasMore => _hasMore;

  /// Fetch currencies with optional filters
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

    final result = await getCurrenciesUseCase(
      GetCurrenciesParams(
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
        final currencies = paginatedResult.currencies;
        if (refresh) {
          _currencies = currencies;
        } else {
          _currencies.addAll(currencies);
        }

        _total = paginatedResult.total;
        _hasMore = _currencies.length < _total;
        if (_hasMore) {
          _currentPage++;
        }

        _isLoading = false;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Load more currencies (pagination)
  Future<void> loadMore() async {
    if (!_isLoading && _hasMore) {
      await fetchCurrencies(
        includeInactive: _includeInactive,
      );
    }
  }

  /// Get currency by ID
  Future<void> getCurrencyById(int currencyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getCurrencyByIdUseCase(currencyId);

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _selectedCurrency = null;
        _isLoading = false;
        notifyListeners();
      },
      (currency) {
        _selectedCurrency = currency;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Get currency by symbol
  Future<void> getCurrencyBySymbol(String symbol) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getCurrencyBySymbolUseCase(symbol);

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _selectedCurrency = null;
        _isLoading = false;
        notifyListeners();
      },
      (currency) {
        _selectedCurrency = currency;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Clear selected currency
  void clearSelectedCurrency() {
    _selectedCurrency = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server error. Please try again later.';
    } else if (failure is NetworkFailure) {
      return 'Network error. Please check your connection.';
    } else if (failure is NotFoundFailure) {
      return 'Currency not found.';
    } else {
      return 'An unexpected error occurred.';
    }
  }
}
