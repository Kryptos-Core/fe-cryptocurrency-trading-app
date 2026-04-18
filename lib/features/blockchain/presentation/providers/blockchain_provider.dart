import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_dtos.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/linked_wallet.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/onchain_transaction.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/wc_link_session_poll_result.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/wc_session_proposal.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/wc_session_status.dart';
import 'package:crypto_trading_app/features/blockchain/domain/repositories/blockchain_repository.dart';

class BlockchainProvider extends ChangeNotifier {
  final BlockchainRepository _blockchainRepository;

  BlockchainProvider({required BlockchainRepository blockchainRepository})
      : _blockchainRepository = blockchainRepository;

  List<LinkedWallet> _linkedWallets = [];
  List<OnchainTransaction> _recentTransactions = [];
  final Map<BlockchainNetwork, DepositAddressResponse> _depositAddresses = {};
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isFetchingDepositAddress = false;
  String? _error;
  /// Last API `code` from a deposit-address / preview / submit failure (trader-safe messaging).
  String? _blockchainApiErrorCode;

  // ============ WalletConnect Session State ============
  WcSessionProposal? _activeWcSession;
  WcSessionStatus _wcSessionStatus = WcSessionStatus.idle;
  bool _isInitializingWcSession = false;
  bool _wcPollSubmitInProgress = false;

  List<LinkedWallet> get linkedWallets => _linkedWallets;
  List<OnchainTransaction> get recentTransactions => _recentTransactions;
  Map<BlockchainNetwork, DepositAddressResponse> get depositAddresses =>
      _depositAddresses;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isFetchingDepositAddress => _isFetchingDepositAddress;
  String? get error => _error;
  String? get blockchainApiErrorCode => _blockchainApiErrorCode;

  // WalletConnect getters
  WcSessionProposal? get activeWcSession => _activeWcSession;
  WcSessionStatus get wcSessionStatus => _wcSessionStatus;
  bool get isInitializingWcSession => _isInitializingWcSession;

  DepositAddressResponse? depositAddressFor(BlockchainNetwork chain) =>
      _depositAddresses[chain];

  Future<DepositAddressResponse?> fetchDepositAddress(
    BlockchainNetwork chain, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _depositAddresses.containsKey(chain)) {
      return _depositAddresses[chain];
    }

    _isFetchingDepositAddress = true;
    _error = null;
    _blockchainApiErrorCode = null;
    notifyListeners();

    final result = await _blockchainRepository.getDepositAddress(chain);
    DepositAddressResponse? payload;

    result.fold(
      (failure) {
        _blockchainApiErrorCode =
            failure is ValidationFailure ? failure.code : null;
        _error = _mapFailureToMessage(failure);
      },
      (response) {
        _depositAddresses[chain] = response;
        payload = response;
      },
    );

    _isFetchingDepositAddress = false;
    notifyListeners();
    return payload;
  }

  Future<DepositPreviewResponse?> previewDeposit(
    BlockchainNetwork chain,
    String txHash,
  ) async {
    _isSubmitting = true;
    _error = null;
    _blockchainApiErrorCode = null;
    notifyListeners();

    final result = await _blockchainRepository.previewDeposit(chain, txHash);
    DepositPreviewResponse? payload;

    result.fold(
      (failure) {
        _blockchainApiErrorCode =
            failure is ValidationFailure ? failure.code : null;
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
    String? amount,
  }) async {
    _isSubmitting = true;
    _error = null;
    _blockchainApiErrorCode = null;
    notifyListeners();

    final trimmedAmount = amount?.trim();
    final amountPayload = (trimmedAmount == null || trimmedAmount.isEmpty)
        ? null
        : trimmedAmount;

    final result = await _blockchainRepository.submitDeposit(
      SubmitDepositRequest(
        chain: chain,
        txHash: txHash,
        amount: amountPayload,
      ),
    );

    var success = false;
    result.fold(
      (failure) {
        _blockchainApiErrorCode =
            failure is ValidationFailure ? failure.code : null;
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

  // ============ WalletConnect v2 Methods ============

  /// Bước 1: Tạo WC session — FE hiển thị QR/deep link
  Future<WcSessionProposal?> initiateWcSession({
    required BlockchainNetwork chain,
  }) async {
    _isInitializingWcSession = true;
    _wcSessionStatus = WcSessionStatus.pending;
    _activeWcSession = null;
    _error = null;
    notifyListeners();

    final result = await _blockchainRepository.initWcSession(chain);
    WcSessionProposal? proposal;

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _wcSessionStatus = WcSessionStatus.failed;
      },
      (session) {
        _activeWcSession = session;
        proposal = session;
        _wcSessionStatus = WcSessionStatus.pending;
      },
    );

    _isInitializingWcSession = false;
    notifyListeners();
    return proposal;
  }

  /// Bước 2: Poll trạng thái từ BE; khi BE đã [WcSessionStatus.signed] + address/signature thì gọi submit.
  Future<WcSessionStatus> pollWcSessionStatus(String sessionId) async {
    final result = await _blockchainRepository.getWcSessionStatus(sessionId);

    return result.fold<Future<WcSessionStatus>>(
      (failure) async {
        _wcSessionStatus = WcSessionStatus.failed;
        notifyListeners();
        return _wcSessionStatus;
      },
      (WcLinkSessionPollResult poll) async {
        _wcSessionStatus = poll.status;
        notifyListeners();

        if (poll.status == WcSessionStatus.signed &&
            poll.address != null &&
            poll.signature != null &&
            _activeWcSession != null &&
            !_wcPollSubmitInProgress) {
          _wcPollSubmitInProgress = true;
          try {
            final ok = await submitWcSignature(
              sessionId: sessionId,
              address: poll.address!,
              signature: poll.signature!,
              chain: _activeWcSession!.chain,
              clearWcSessionAfter: false,
            );
            if (ok) {
              _wcSessionStatus = WcSessionStatus.signed;
              notifyListeners();
              return WcSessionStatus.signed;
            }
            _wcSessionStatus = WcSessionStatus.failed;
            notifyListeners();
            return WcSessionStatus.failed;
          } finally {
            _wcPollSubmitInProgress = false;
          }
        }

        return poll.status;
      },
    );
  }

  /// Bước 3: Submit signature sau khi WC signing hoàn tất (hoặc sau poll khi BE đã ký server-side).
  Future<bool> submitWcSignature({
    required String sessionId,
    required String address,
    required String signature,
    required BlockchainNetwork chain,
    bool clearWcSessionAfter = true,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    final result = await _blockchainRepository.submitWcSignature(
      sessionId: sessionId,
      address: address,
      signature: signature,
      chain: chain,
    );

    var success = false;
    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _wcSessionStatus = WcSessionStatus.failed;
      },
      (_) {
        success = true;
        _wcSessionStatus = WcSessionStatus.signed;
      },
    );

    if (success) {
      await fetchLinkedWallets();
      if (clearWcSessionAfter) {
        clearWcSession();
      }
    }

    _isSubmitting = false;
    notifyListeners();
    return success;
  }

  /// Reset WC session state
  void clearWcSession() {
    _activeWcSession = null;
    _wcSessionStatus = WcSessionStatus.idle;
    _isInitializingWcSession = false;
    _wcPollSubmitInProgress = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    _blockchainApiErrorCode = null;
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
