import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_dtos.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/linked_wallet.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/onchain_transaction.dart';
import 'package:crypto_trading_app/domain/repositories/blockchain_repository.dart';

class BlockchainProvider extends ChangeNotifier {
  final BlockchainRepository _blockchainRepository;

  BlockchainProvider({required BlockchainRepository blockchainRepository})
      : _blockchainRepository = blockchainRepository;

  List<LinkedWallet> _linkedWallets = [];
  List<OnchainTransaction> _recentTransactions = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  List<LinkedWallet> get linkedWallets => _linkedWallets;
  List<OnchainTransaction> get recentTransactions => _recentTransactions;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Future<void> fetchLinkedWallets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _blockchainRepository.getLinkedWallets();
    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
      },
      (wallets) {
        _linkedWallets = wallets;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<RequestLinkResponse?> initiateWalletLink({
    required BlockchainNetwork chain,
    required String address,
    String? label,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _blockchainRepository.requestLink(
      chain: chain,
      address: address,
      label: label,
    );

    RequestLinkResponse? payload;
    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
      },
      (response) {
        payload = response;
      },
    );

    _isSubmitting = false;
    notifyListeners();
    return payload;
  }

  Future<bool> verifyWalletLink({
    required BlockchainNetwork chain,
    required String address,
    required String signature,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _blockchainRepository.verifyLink(
      chain: chain,
      address: address,
      signature: signature,
    );

    var success = false;
    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
      },
      (_) {
        success = true;
      },
    );

    if (success) {
      await fetchLinkedWallets();
    }

    _isSubmitting = false;
    notifyListeners();
    return success;
  }

  Future<bool> unlinkWallet(String linkId) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _blockchainRepository.unlinkWallet(linkId);

    var success = false;
    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
      },
      (_) {
        success = true;
      },
    );

    if (success) {
      _linkedWallets =
          _linkedWallets.where((wallet) => wallet.linkId != linkId).toList();
    }

    _isSubmitting = false;
    notifyListeners();
    return success;
  }

  Future<bool> submitDeposit({
    required BlockchainNetwork chain,
    required String txHash,
    required String amount,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _blockchainRepository.submitDeposit(
      SubmitDepositRequest(
        chain: chain,
        txHash: txHash,
        amount: amount,
      ),
    );

    var success = false;
    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
      },
      (tx) {
        _recentTransactions = [tx, ..._recentTransactions];
        success = true;
      },
    );

    _isSubmitting = false;
    notifyListeners();
    return success;
  }

  Future<bool> requestWithdrawal({
    required BlockchainNetwork chain,
    required String linkedWalletId,
    required String amount,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _blockchainRepository.requestWithdrawal(
      RequestWithdrawalRequest(
        chain: chain,
        linkedWalletId: linkedWalletId,
        amount: amount,
      ),
    );

    var success = false;
    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
      },
      (tx) {
        _recentTransactions = [tx, ..._recentTransactions];
        success = true;
      },
    );

    _isSubmitting = false;
    notifyListeners();
    return success;
  }

  Future<void> fetchRecentTransactions({int limit = 50}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _blockchainRepository.getTransactions(limit: limit);
    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
      },
      (transactions) {
        _recentTransactions = transactions;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure) {
      case NetworkFailure _:
        return 'Network error. Please check your connection.';
      case AuthenticationFailure _:
        return 'Session expired. Please login again.';
      case ValidationFailure _:
        return failure.message;
      case ConflictFailure _:
        return failure.message;
      case NotFoundFailure _:
        return failure.message;
      case ServerFailure _:
        return failure.message.isNotEmpty
            ? failure.message
            : 'Server error. Please try again later.';
      default:
        return failure.message;
    }
  }
}
