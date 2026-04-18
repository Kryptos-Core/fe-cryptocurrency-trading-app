import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/features/managed_wallets/domain/entities/managed_wallet/managed_wallet.dart';
import 'package:crypto_trading_app/features/managed_wallets/domain/entities/managed_wallet/managed_wallet_balance.dart';
import 'package:crypto_trading_app/features/managed_wallets/domain/entities/managed_wallet/managed_wallet_transaction.dart';
import 'package:crypto_trading_app/features/managed_wallets/domain/entities/managed_wallet/deposit_method.dart';
import 'package:crypto_trading_app/features/managed_wallets/domain/repositories/managed_wallets_repository.dart';

class ManagedWalletsProvider extends ChangeNotifier {
  final ManagedWalletsRepository _repository;

  ManagedWalletsProvider({required ManagedWalletsRepository repository})
      : _repository = repository;

  // ── State ──────────────────────────────────────────────────────────────────

  List<ManagedWallet> _wallets = [];
  List<ManagedWallet> _depositDefaults = [];
  ManagedWalletBalance? _selectedBalance;
  List<ManagedWalletTransaction> _transactions = [];
  DepositMethodsResponse? _depositMethods;
  String? _recommendedChain;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  // ── Getters ────────────────────────────────────────────────────────────────

  List<ManagedWallet> get wallets => _wallets;
  List<ManagedWallet> get depositDefaults => _depositDefaults;
  ManagedWalletBalance? get selectedBalance => _selectedBalance;
  List<ManagedWalletTransaction> get transactions => _transactions;
  DepositMethodsResponse? get depositMethods => _depositMethods;
  String? get recommendedChain => _recommendedChain;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> fetchWallets() async {
    _setLoading(true);
    final result = await _repository.listWallets();
    result.fold(
      (f) => _setError(_mapFailureToMessage(f)),
      (wallets) {
        _wallets = wallets;
        _error = null;
      },
    );
    _setLoading(false);
  }

  Future<void> fetchDepositDefaults() async {
    _setLoading(true);
    final result = await _repository.getDepositDefaults();
    result.fold(
      (f) => _setError(_mapFailureToMessage(f)),
      (defaults) {
        _depositDefaults = defaults;
        _error = null;
      },
    );
    _setLoading(false);
  }

  Future<void> fetchDepositMethods() async {
    _setLoading(true);
    final result = await _repository.getDepositMethods();
    result.fold(
      (f) => _setError(_mapFailureToMessage(f)),
      (methods) {
        _depositMethods = methods;
        _recommendedChain = methods.recommendedChain;
        _error = null;
      },
    );
    _setLoading(false);
  }

  Future<void> fetchWalletDetail(String walletId) async {
    _setLoading(true);
    _selectedBalance = null;
    final result = await _repository.getWalletDetail(walletId);
    result.fold(
      (f) => _setError(_mapFailureToMessage(f)),
      (balance) {
        _selectedBalance = balance;
        _error = null;
      },
    );
    _setLoading(false);
  }

  Future<void> fetchWalletTransactions(String walletId) async {
    _setLoading(true);
    _transactions = [];
    final result = await _repository.getWalletTransactions(walletId);
    result.fold(
      (f) => _setError(_mapFailureToMessage(f)),
      (txs) {
        _transactions = txs;
        _error = null;
      },
    );
    _setLoading(false);
  }

  Future<String?> sendTrx({
    required String walletId,
    required String toAddress,
    required String amount,
  }) async {
    _setSubmitting(true);
    String? errorMessage;
    final result = await _repository.sendTrx(
      walletId: walletId,
      toAddress: toAddress,
      amount: amount,
    );
    result.fold(
      (f) {
        errorMessage = _mapFailureToMessage(f);
        _setError(errorMessage!);
      },
      (_) {
        _error = null;
      },
    );
    _setSubmitting(false);
    return errorMessage;
  }

  Future<String?> setDepositDefault(String walletId) async {
    _setSubmitting(true);
    String? errorMessage;
    final result = await _repository.setDepositDefault(walletId);
    result.fold(
      (f) {
        errorMessage = _mapFailureToMessage(f);
        _setError(errorMessage!);
      },
      (_) {
        _error = null;
      },
    );
    if (errorMessage == null) {
      await fetchWallets();
      await fetchDepositDefaults();
    }
    _setSubmitting(false);
    return errorMessage;
  }

  Future<String?> clearDepositDefault(String walletId) async {
    _setSubmitting(true);
    String? errorMessage;
    final result = await _repository.clearDepositDefault(walletId);
    result.fold(
      (f) {
        errorMessage = _mapFailureToMessage(f);
        _setError(errorMessage!);
      },
      (_) {
        _error = null;
      },
    );
    if (errorMessage == null) {
      await fetchWallets();
      await fetchDepositDefaults();
      await fetchDepositMethods();
    }
    _setSubmitting(false);
    return errorMessage;
  }

  Future<String?> setRecommendedChain(String chain) async {
    _setSubmitting(true);
    String? errorMessage;
    final result = await _repository.setRecommendedChain(chain);
    result.fold(
      (f) {
        errorMessage = _mapFailureToMessage(f);
        _setError(errorMessage!);
      },
      (newChain) {
        _recommendedChain = newChain;
        _error = null;
      },
    );
    _setSubmitting(false);
    return errorMessage;
  }

  Future<String?> deactivateWallet(String walletId) async {
    _setSubmitting(true);
    String? errorMessage;
    final result = await _repository.deactivateWallet(walletId);
    result.fold(
      (f) {
        errorMessage = _mapFailureToMessage(f);
        _setError(errorMessage!);
      },
      (_) {
        _wallets = _wallets.map((w) {
          if (w.walletId == walletId) {
            return ManagedWallet(
              walletId: w.walletId,
              userId: w.userId,
              chain: w.chain,
              address: w.address,
              label: w.label,
              isDefaultDeposit: w.isDefaultDeposit,
              defaultSetAt: w.defaultSetAt,
              isActive: false,
              createdAt: w.createdAt,
              updatedAt: w.updatedAt,
            );
          }
          return w;
        }).toList();
        _error = null;
      },
    );
    _setSubmitting(false);
    return errorMessage;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      NetworkFailure() => 'Network error. Check your connection.',
      AuthenticationFailure() => 'Session expired. Please log in again.',
      ValidationFailure() => failure.message,
      NotFoundFailure() => failure.message,
      ConflictFailure() => failure.message,
      _ => failure.message,
    };
  }
}
