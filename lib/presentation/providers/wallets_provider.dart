import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/wallet.dart';
import 'package:crypto_trading_app/domain/usecases/wallets_usecases.dart';
import 'package:crypto_trading_app/domain/entities/wallet_balance.dart';
import 'package:crypto_trading_app/domain/entities/wallet_transaction.dart';
import 'package:crypto_trading_app/domain/usecases/get_wallet_balance_usecase.dart';
import 'package:crypto_trading_app/domain/usecases/execute_wallet_transaction_usecase.dart';
import 'package:crypto_trading_app/domain/usecases/get_transaction_history_usecase.dart';

/// Wallets Provider
/// Following Provider Pattern for State Management
class WalletsProvider extends ChangeNotifier {
  final Logger _logger = Logger();
  final GetWalletsUseCase getWalletsUseCase;
  final GetWalletByCurrencyUseCase getWalletByCurrencyUseCase;
  final GetWalletBalanceUseCase getWalletBalanceUseCase;
  final GetWalletLedgerUseCase getWalletLedgerUseCase;
  final GetWalletBalanceApiUseCase? getWalletBalanceApiUseCase;
  final ExecuteWalletTransactionApiUseCase? executeWalletTransactionApiUseCase;
  final GetTransactionHistoryApiUseCase? getTransactionHistoryApiUseCase;

  WalletsProvider({
    required this.getWalletsUseCase,
    required this.getWalletByCurrencyUseCase,
    required this.getWalletBalanceUseCase,
    required this.getWalletLedgerUseCase,
    this.getWalletBalanceApiUseCase,
    this.executeWalletTransactionApiUseCase,
    this.getTransactionHistoryApiUseCase,
  });

  // State
  List<Wallet> _wallets = [];
  Wallet? _selectedWallet;
  List<WalletLedger> _ledger = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMore = true;

  // New Wallet API state
  WalletBalance? _walletBalance;
  WalletTransactionResponse? _lastTransaction;
  static const int _maxRecentTransactions = 50;
  final List<WalletTransactionResponse> _recentTransactions = [];

  // Getters
  List<Wallet> get wallets => _wallets;
  Wallet? get selectedWallet => _selectedWallet;
  List<WalletLedger> get ledger => _ledger;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  WalletBalance? get walletBalance => _walletBalance;
  WalletTransactionResponse? get lastTransaction => _lastTransaction;
  List<WalletTransactionResponse> get recentTransactions =>
      List.unmodifiable(_recentTransactions);

  /// Total portfolio value in USDT. Returns 0 when no price source is available;
  /// integrate with Markets/ticker API for real conversion (e.g. BTC/USDT, ETH/USDT).
  double get totalPortfolioValue => 0.0;

  /// Fetch wallets with optional filters
  Future<void> fetchWallets({
    String? currencyId,
    bool includeZero = false,
    bool refresh = false,
  }) async {
    if (refresh) {
      _wallets = [];
    }

    _isLoading = true;
    _error = null;
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
  Future<void> getWalletByCurrency(String currencyId) async {
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
  Future<void> getWalletBalance(String walletId) async {
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
    required String walletId,
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
    required String walletId,
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

  // ===== NEW WALLET API METHODS =====

  /// Fetch wallet balance using new Wallet API
  Future<void> fetchWalletBalance(String currencyId,
      {bool forceRefresh = false}) async {
    if (getWalletBalanceApiUseCase == null) {
      _error = 'Wallet API not configured';
      notifyListeners();
      return;
    }

    _logger.d(
        '[WalletsProvider] Fetching wallet balance for currencyId: $currencyId');

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getWalletBalanceApiUseCase!(
      GetWalletBalanceParams(currencyId: currencyId),
    );

    result.fold(
      (failure) {
        _logger.e('[WalletsProvider] ERROR: Failure type: ${failure.runtimeType}');
        _logger.e('[WalletsProvider] ERROR: Failure message: ${failure.message}');
        _error = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (balance) {
        _logger.i(
            '[WalletsProvider] SUCCESS: Balance fetched - userId=${balance.userId}, currencyId=${balance.currencyId}, available=${balance.available}, frozen=${balance.frozen}, total=${balance.total}');
        _walletBalance = balance;
        _recentTransactions.clear(); // Clear so we never show another currency's history
        _isLoading = false;
        _error = null;
        notifyListeners();
        // Load transaction history for this currency only
        fetchTransactionHistory(currencyId);
      },
    );
  }

  /// Fetch transaction history (ledger) for a currency and set as recent transactions
  Future<void> fetchTransactionHistory(String currencyId) async {
    if (getTransactionHistoryApiUseCase == null) return;

    final result = await getTransactionHistoryApiUseCase!(
      GetTransactionHistoryParams(currencyId: currencyId),
    );

    result.fold(
      (_) {
        // On failure keep current _recentTransactions (e.g. in-session only)
      },
      (list) {
        _recentTransactions.clear();
        _recentTransactions.addAll(list);
        if (_recentTransactions.length > _maxRecentTransactions) {
          _recentTransactions.removeRange(
            _maxRecentTransactions,
            _recentTransactions.length,
          );
        }
        notifyListeners();
      },
    );
  }

  /// Execute wallet transaction (CREDIT/DEBIT/FREEZE/UNFREEZE/TRANSFER)
  Future<bool> executeTransaction(WalletTransactionRequest request) async {
    if (executeWalletTransactionApiUseCase == null) {
      _error = 'Wallet API not configured';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await executeWalletTransactionApiUseCase!(
      ExecuteWalletTransactionParams(request: request),
    );

    bool success = false;
    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (response) {
        _lastTransaction = response;
        _walletBalance = response.newBalance;
        // Only add to list if it matches current balance currency (avoid mixing currencies)
        if (response.currencyId == _walletBalance?.currencyId) {
          _recentTransactions.insert(0, response);
          if (_recentTransactions.length > _maxRecentTransactions) {
            _recentTransactions.removeLast();
          }
        }
        _isLoading = false;
        _error = null;
        success = true;
        notifyListeners();
      },
    );

    return success;
  }

  /// Deposit (CREDIT action)
  Future<bool> deposit({
    required String currencyId,
    required String amount,
    required String refId,
  }) async {
    final request = WalletTransactionRequest(
      currencyId: currencyId,
      action: WalletTransactionAction.credit,
      amount: amount,
      refType: WalletReferenceType.deposit,
      refId: refId,
    );
    return await executeTransaction(request);
  }

  /// Withdraw (DEBIT action)
  Future<bool> withdraw({
    required String currencyId,
    required String amount,
    required String refId,
  }) async {
    final request = WalletTransactionRequest(
      currencyId: currencyId,
      action: WalletTransactionAction.debit,
      amount: amount,
      refType: WalletReferenceType.withdraw,
      refId: refId,
    );
    return await executeTransaction(request);
  }

  /// Freeze balance (for order placement)
  Future<bool> freezeBalance({
    required String currencyId,
    required String amount,
    required String refId,
  }) async {
    final request = WalletTransactionRequest(
      currencyId: currencyId,
      action: WalletTransactionAction.freeze,
      amount: amount,
      refType: WalletReferenceType.order,
      refId: refId,
    );
    return await executeTransaction(request);
  }

  /// Unfreeze balance (for order cancellation)
  Future<bool> unfreezeBalance({
    required String currencyId,
    required String amount,
    required String refId,
  }) async {
    final request = WalletTransactionRequest(
      currencyId: currencyId,
      action: WalletTransactionAction.unfreeze,
      amount: amount,
      refType: WalletReferenceType.order,
      refId: refId,
    );
    return await executeTransaction(request);
  }

  /// Transfer to another user.
  /// Uses a unique refId per transfer to avoid duplicate ledger key (TRANSFER-refId-userId-currencyId-direction).
  Future<bool> transfer({
    required String currencyId,
    required String amount,
    required String toUserId,
  }) async {
    final request = WalletTransactionRequest(
      currencyId: currencyId,
      action: WalletTransactionAction.transfer,
      amount: amount,
      refType: WalletReferenceType.transfer,
      refId: '${DateTime.now().millisecondsSinceEpoch}',
      targetUserId: toUserId,
    );
    return await executeTransaction(request);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure) {
      case ServerFailure _:
        return failure.message.isNotEmpty
            ? failure.message
            : 'Server error. Please try again later.';
      case NetworkFailure _:
        return 'Network error. Please check your connection.';
      case ValidationFailure _:
        return failure.message;
      case NotFoundFailure _:
        return 'Wallet not found.';
      default:
        return failure.message;
    }
  }
}
