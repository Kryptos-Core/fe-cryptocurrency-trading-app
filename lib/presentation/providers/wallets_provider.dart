import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/wallet.dart';
import 'package:crypto_trading_app/domain/usecases/wallets_usecases.dart';

/// Wallets Provider
/// Following Provider Pattern for State Management
class WalletsProvider extends ChangeNotifier {
  final GetWalletsUseCase getWalletsUseCase;
  final GetWalletByCurrencyUseCase getWalletByCurrencyUseCase;
  final GetWalletBalanceUseCase getWalletBalanceUseCase;
  final GetWalletLedgerUseCase getWalletLedgerUseCase;

  WalletsProvider({
    required this.getWalletsUseCase,
    required this.getWalletByCurrencyUseCase,
    required this.getWalletBalanceUseCase,
    required this.getWalletLedgerUseCase,
  });

  // State
  List<Wallet> _wallets = [];
  Wallet? _selectedWallet;
  List<WalletLedger> _ledger = [];
  bool _isLoading = false;
  String? _error;
  int? _filterCurrencyId;
  bool _includeZero = false;
  String? _filterRefType;
  String? _filterDirection;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMore = true;

  // Getters
  List<Wallet> get wallets => _wallets;
  Wallet? get selectedWallet => _selectedWallet;
  List<WalletLedger> get ledger => _ledger;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  /// Calculate total portfolio value in USDT (mock calculation)
  double get totalPortfolioValue {
    // In real app, this would fetch current prices and calculate
    // For now, return a mock value
    return _wallets.fold(0.0, (sum, wallet) {
      final total = double.tryParse(wallet.total) ?? 0;
      // Mock conversion rates
      final rates = {'BTC': 45000.0, 'ETH': 2850.0, 'USDT': 1.0, 'BNB': 350.0};
      final rate = rates[wallet.currency.symbol] ?? 1.0;
      return sum + (total * rate);
    });
  }

  /// Fetch wallets with optional filters
  Future<void> fetchWallets({
    int? currencyId,
    bool includeZero = false,
    bool refresh = false,
  }) async {
    if (refresh) {
      _wallets = [];
    }

    _isLoading = true;
    _error = null;
    _filterCurrencyId = currencyId;
    _includeZero = includeZero;
    notifyListeners();

    final result = await getWalletsUseCase(
      GetWalletsParams(
        currencyId: currencyId,
        includeZero: includeZero,
      ),
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (wallets) {
        _wallets = wallets;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Get wallet by currency ID
  Future<void> getWalletByCurrency(int currencyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getWalletByCurrencyUseCase(currencyId);

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _selectedWallet = null;
        _isLoading = false;
        notifyListeners();
      },
      (wallet) {
        _selectedWallet = wallet;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Get wallet balance by wallet ID
  Future<void> getWalletBalance(int walletId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getWalletBalanceUseCase(walletId);

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _selectedWallet = null;
        _isLoading = false;
        notifyListeners();
      },
      (wallet) {
        _selectedWallet = wallet;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Fetch wallet ledger (transaction history)
  Future<void> fetchLedger({
    required int walletId,
    String? refType,
    String? direction,
    String? startDate,
    String? endDate,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _ledger = [];
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _error = null;
    _filterRefType = refType;
    _filterDirection = direction;
    notifyListeners();

    final result = await getWalletLedgerUseCase(
      GetWalletLedgerParams(
        walletId: walletId,
        refType: refType,
        direction: direction,
        startDate: startDate,
        endDate: endDate,
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
      (ledger) {
        if (refresh) {
          _ledger = ledger;
        } else {
          _ledger.addAll(ledger);
        }

        _hasMore = ledger.length == _pageSize;
        if (_hasMore) {
          _currentPage++;
        }

        _isLoading = false;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Load more ledger entries (pagination)
  Future<void> loadMoreLedger({
    required int walletId,
    String? refType,
    String? direction,
  }) async {
    if (!_isLoading && _hasMore) {
      await fetchLedger(
        walletId: walletId,
        refType: refType,
        direction: direction,
      );
    }
  }

  /// Clear selected wallet
  void clearSelectedWallet() {
    _selectedWallet = null;
    _ledger = [];
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
        return 'Wallet not found.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
