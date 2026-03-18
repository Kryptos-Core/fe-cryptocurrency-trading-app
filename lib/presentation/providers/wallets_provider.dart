import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/admin_wallet_adjustment.dart';
import 'package:crypto_trading_app/domain/entities/wallet.dart';
import 'package:crypto_trading_app/domain/entities/wallet_balance.dart';
import 'package:crypto_trading_app/domain/entities/wallet_transaction.dart';
import 'package:crypto_trading_app/domain/repositories/wallets_repository.dart';
import 'package:crypto_trading_app/domain/repositories/wallet_repository.dart';

/// Wallets Provider
/// Following Provider Pattern for State Management
class WalletsProvider extends ChangeNotifier {
  final Logger _logger = Logger();
  final WalletsRepository _walletsRepository;
  final WalletRepository? _walletRepository;

  WalletsProvider({
    required WalletsRepository walletsRepository,
    WalletRepository? walletRepository,
  })  : _walletsRepository = walletsRepository,
        _walletRepository = walletRepository;

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

  // Admin adjustment state
  bool _isAdjusting = false;
  String? _adjustError;
  List<AdminWalletAdjustment> _adjustmentHistory = [];
  bool _isLoadingHistory = false;

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

  // Admin adjustment getters
  bool get isAdjusting => _isAdjusting;
  String? get adjustError => _adjustError;
  List<AdminWalletAdjustment> get adjustmentHistory =>
      List.unmodifiable(_adjustmentHistory);
  bool get isLoadingHistory => _isLoadingHistory;

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

    final result = await _walletsRepository.getWallets(
      currencyId: currencyId,
      includeZero: includeZero,
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

    final result = await _walletsRepository.getWalletByCurrency(currencyId);

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

    final result = await _walletsRepository.getWalletBalance(walletId);

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

    final result = await _walletsRepository.getWalletLedger(
      walletId: walletId,
      refType: refType,
      direction: direction,
      startDate: startDate,
      endDate: endDate,
      page: _currentPage,
      limit: _pageSize,
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
    if (_walletRepository == null) {
      _error = 'Wallet API not configured';
      notifyListeners();
      return;
    }

    _logger.d(
        '[WalletsProvider] Fetching wallet balance for currencyId: $currencyId');

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _walletRepository!.getBalance(currencyId);

    result.fold(
      (failure) {
        _logger
            .e('[WalletsProvider] ERROR: Failure type: ${failure.runtimeType}');
        _logger
            .e('[WalletsProvider] ERROR: Failure message: ${failure.message}');
        _error = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (balance) {
        _logger.i(
            '[WalletsProvider] SUCCESS: Balance fetched - userId=${balance.userId}, currencyId=${balance.currencyId}, available=${balance.available}, frozen=${balance.frozen}, total=${balance.total}');
        _walletBalance = balance;
        _recentTransactions
            .clear(); // Clear so we never show another currency's history
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
    if (_walletRepository == null) return;

    final result = await _walletRepository!.getTransactionHistory(currencyId);

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
    if (_walletRepository == null) {
      _error = 'Wallet API not configured';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _walletRepository!.executeTransaction(request);

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

  // ===== ADMIN WALLET ADJUSTMENT METHODS =====

  /// Điều chỉnh số dư ví thủ công. Trả về true nếu thành công.
  Future<bool> adminAdjustBalance({
    required String userId,
    required String currencyId,
    required String amount,
    required String type,
    String? note,
  }) async {
    if (_walletRepository == null) {
      _adjustError = 'Wallet API not configured';
      notifyListeners();
      return false;
    }

    _isAdjusting = true;
    _adjustError = null;
    notifyListeners();

    final result = await _walletRepository!.adminAdjustBalance(
      userId: userId,
      currencyId: currencyId,
      amount: amount,
      type: type,
      note: note,
    );

    bool success = false;
    result.fold(
      (failure) {
        _adjustError = _mapFailureToMessage(failure);
        _isAdjusting = false;
        notifyListeners();
      },
      (adjustment) {
        _logger.i(
          '[WalletsProvider] AdminAdjust SUCCESS: id=${adjustment.adjustmentId} type=${adjustment.type} amount=${adjustment.amount}',
        );
        _adjustmentHistory.insert(0, adjustment);
        _isAdjusting = false;
        _adjustError = null;
        success = true;
        notifyListeners();
      },
    );

    return success;
  }

  /// Tải lịch sử điều chỉnh thủ công cho một người dùng.
  Future<void> loadAdjustmentHistory(
    String userId, {
    int limit = 50,
    int offset = 0,
    bool refresh = false,
  }) async {
    if (_walletRepository == null) return;

    if (refresh) _adjustmentHistory = [];

    _isLoadingHistory = true;
    notifyListeners();

    final result = await _walletRepository!.getAdminAdjustmentHistory(
      userId,
      limit: limit,
      offset: offset,
    );

    result.fold(
      (failure) {
        _adjustError = _mapFailureToMessage(failure);
        _isLoadingHistory = false;
        notifyListeners();
      },
      (list) {
        if (refresh) {
          _adjustmentHistory = list;
        } else {
          _adjustmentHistory.addAll(list);
        }
        _isLoadingHistory = false;
        notifyListeners();
      },
    );
  }

  void clearAdjustError() {
    _adjustError = null;
    notifyListeners();
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
