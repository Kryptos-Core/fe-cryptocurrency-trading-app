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
  bool? _filterIsActive;
  bool? _filterIsTradable;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMore = true;

  // Getters
  List<Currency> get currencies => _currencies;
  Currency? get selectedCurrency => _selectedCurrency;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool? get filterIsActive => _filterIsActive;
  bool? get filterIsTradable => _filterIsTradable;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;

  /// Fetch currencies with optional filters
  Future<void> fetchCurrencies({
    bool? isActive,
    bool? isTradable,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _currencies = [];
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _error = null;
    _filterIsActive = isActive;
    _filterIsTradable = isTradable;
    notifyListeners();

    final result = await getCurrenciesUseCase(
      GetCurrenciesParams(
        isActive: isActive,
        isTradable: isTradable,
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
      (currencies) {
        if (refresh) {
          _currencies = currencies;
        } else {
          _currencies.addAll(currencies);
        }

        _hasMore = currencies.length == _pageSize;
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
        isActive: _filterIsActive,
        isTradable: _filterIsTradable,
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
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error. Please try again later.';
      case NetworkFailure:
        return 'Network error. Please check your connection.';
      case NotFoundFailure:
        return 'Currency not found.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
