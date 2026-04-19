import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/utils/stale_query_policy.dart';
import 'package:crypto_trading_app/features/treasury/domain/entities/treasury_model.dart';
import 'package:crypto_trading_app/features/treasury/domain/repositories/treasury_repository.dart';

class TreasuryProvider extends ChangeNotifier {
  final TreasuryRepository _repository;

  TreasuryProvider({required TreasuryRepository repository})
      : _repository = repository;

  List<TreasuryWalletModel> _wallets = [];
  List<TreasuryMainWalletModel> _mainWallets = [];
  List<TreasuryOperationModel> _operations = [];
  List<TreasuryTransactionModel> _transactions = [];

  bool _isLoadingWallets = false;
  bool _isLoadingHistory = false;
  bool _isSubmitting = false;
  String? _error;
  String? _apiErrorCode;

  String? _walletChain;
  String? _walletPurpose;

  String? _historyChain;
  String? _historyType;
  String? _historyStatus;
  String? _historyQuery;
  Timer? _realtimeRefreshDebounce;

  static const int _historyPageSize = 15;
  int _historyOpPage = 1;
  int _historyTxPage = 1;
  bool _opHasMore = false;
  bool _txHasMore = false;
  bool _loadingMoreHistory = false;

  String? _walletsFetchKey;
  DateTime? _walletsFetchedAt;

  String? _historyFetchKey;
  DateTime? _historyFetchedAt;

  /// Wallets with an in-flight Fund/Sweep: maps walletId → operationId from API (nullable if unknown).
  final Map<String, String?> _pendingOnChainByWallet = {};
  final Map<String, Timer> _pendingWalletClearTimers = {};

  List<TreasuryWalletModel> get wallets => _wallets;
  List<TreasuryMainWalletModel> get mainWallets => _mainWallets;
  List<TreasuryOperationModel> get operations => _operations;
  List<TreasuryTransactionModel> get transactions => _transactions;

  bool get isLoadingWallets => _isLoadingWallets;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  String? get walletChain => _walletChain;
  String? get walletPurpose => _walletPurpose;
  String? get historyChain => _historyChain;
  String? get historyType => _historyType;
  String? get historyStatus => _historyStatus;
  String? get historyQuery => _historyQuery;

  /// Last API `code` from [ServerException] (e.g. `TX_WALLET_NON_ZERO_BALANCE`) for localized UI.
  String? get apiErrorCode => _apiErrorCode;

  bool get hasMoreHistory => _opHasMore || _txHasMore;
  bool get isLoadingMoreHistory => _loadingMoreHistory;

  String _walletCacheKey() => '${_walletChain ?? ''}\x1F${_walletPurpose ?? ''}';

  String _historyCacheKey() =>
      '${_historyChain ?? ''}\x1F${_historyType ?? ''}\x1F${_historyStatus ?? ''}\x1F${_historyQuery ?? ''}';

  /// After [loadMoreHistory], revisiting the tab should refetch (stale window alone would drop extra pages).
  bool _shouldSkipHistoryStaleFetch(String key) {
    if (!isStaleQueryFresh(_historyFetchedAt)) return false;
    if (_historyFetchKey != key) return false;
    if (_historyOpPage > 2 || _historyTxPage > 2) return false;
    return true;
  }

  TreasuryOperationModel? _findPendingOperationForWallet(String walletId) {
    for (final op in _operations) {
      final s = op.status.toUpperCase();
      if (s != 'PENDING' && s != 'PROCESSING') continue;
      if (op.fromWalletId == walletId || op.toWalletId == walletId) {
        return op;
      }
    }
    return null;
  }

  /// True while a Fund/Sweep is queued or processing for this wallet (client and/or server).
  bool isWalletPendingOnChain(String walletId) {
    if (_pendingOnChainByWallet.containsKey(walletId)) return true;
    return _findPendingOperationForWallet(walletId) != null;
  }

  /// Best-known operation id for UI (tooltip); null if only "pending" without id yet.
  String? pendingOnChainOperationIdForWallet(String walletId) {
    final local = _pendingOnChainByWallet[walletId];
    if (local != null && local.isNotEmpty) return local;
    return _findPendingOperationForWallet(walletId)?.operationId;
  }

  void _trackPendingOnChain(String walletId, String? operationId) {
    _pendingOnChainByWallet[walletId] =
        (operationId != null && operationId.isNotEmpty) ? operationId : null;
    _pendingWalletClearTimers[walletId]?.cancel();
    _pendingWalletClearTimers[walletId] = Timer(const Duration(minutes: 3), () {
      _pendingOnChainByWallet.remove(walletId);
      _pendingWalletClearTimers.remove(walletId);
      notifyListeners();
    });
    notifyListeners();
  }

  void _prunePendingIfOperationTerminalInList() {
    var changed = false;
    for (final walletId in _pendingOnChainByWallet.keys.toList()) {
      final oid = _pendingOnChainByWallet[walletId];
      if (oid == null || oid.isEmpty) continue;
      TreasuryOperationModel? match;
      for (final o in _operations) {
        if (o.operationId == oid) {
          match = o;
          break;
        }
      }
      if (match != null) {
        final st = match.status.toUpperCase();
        if (st == 'COMPLETED' || st == 'FAILED') {
          _pendingOnChainByWallet.remove(walletId);
          _pendingWalletClearTimers[walletId]?.cancel();
          _pendingWalletClearTimers.remove(walletId);
          changed = true;
        }
      }
    }
    if (changed) notifyListeners();
  }

  void _clearOnChainPendingState() {
    for (final t in _pendingWalletClearTimers.values) {
      t.cancel();
    }
    _pendingWalletClearTimers.clear();
    if (_pendingOnChainByWallet.isEmpty) return;
    _pendingOnChainByWallet.clear();
    notifyListeners();
  }

  void setWalletFilters({String? chain, String? purpose}) {
    _walletChain = chain;
    _walletPurpose = purpose;
    notifyListeners();
  }

  void _resetDisplayedError() {
    _error = null;
    _apiErrorCode = null;
  }

  void _captureError(Object e) {
    if (e is ServerException) {
      _error = e.message;
      _apiErrorCode = e.code;
      return;
    }
    _error = e.toString();
    _apiErrorCode = null;
  }

  void setHistoryFilters({
    String? chain,
    String? type,
    String? status,
    String? query,
  }) {
    _historyChain = chain;
    _historyType = type;
    _historyStatus = status;
    _historyQuery = query;
    notifyListeners();
  }

  Future<void> loadMainWallets(String chain) async {
    try {
      final list = await _repository.listMainWallets(chain);
      _mainWallets = list;
      notifyListeners();
    } catch (e) {
      _mainWallets = [];
      _captureError(e);
      notifyListeners();
    }
  }

  Future<void> loadWallets({bool force = false}) async {
    final key = _walletCacheKey();
    if (!force && isStaleQueryFresh(_walletsFetchedAt) && _walletsFetchKey == key) {
      return;
    }

    _isLoadingWallets = true;
    _resetDisplayedError();
    notifyListeners();

    try {
      final list = await _repository.listWallets(
        chain: _walletChain,
        purpose: _walletPurpose,
      );
      _wallets = list;
      _walletsFetchKey = key;
      _walletsFetchedAt = DateTime.now();
    } catch (e) {
      _captureError(e);
    } finally {
      _isLoadingWallets = false;
      notifyListeners();
    }
  }

  static bool _pageHasMore({
    required int itemCount,
    required int total,
    required int loadedCount,
    required int limit,
  }) {
    if (itemCount == 0) return false;
    if (itemCount < limit) return false;
    if (total > 0) return loadedCount < total;
    return true;
  }

  /// Resets pagination and loads the first page of operations + on-chain txs.
  Future<void> loadHistory({bool force = false}) async {
    final key = _historyCacheKey();
    if (!force && _shouldSkipHistoryStaleFetch(key)) {
      return;
    }

    _historyOpPage = 1;
    _historyTxPage = 1;
    _opHasMore = false;
    _txHasMore = false;
    _operations = [];
    _transactions = [];

    _isLoadingHistory = true;
    _resetDisplayedError();
    notifyListeners();

    try {
      final opResult = await _repository.listOperations(
        chain: _historyChain,
        type: _historyType,
        status: _historyStatus,
        q: _historyQuery,
        page: 1,
        limit: _historyPageSize,
      );
      _operations = opResult.items;
      _historyOpPage = 2;
      _opHasMore = _pageHasMore(
        itemCount: opResult.items.length,
        total: opResult.total,
        loadedCount: _operations.length,
        limit: _historyPageSize,
      );

      final txResult = await _repository.listTransactions(
        chain: _historyChain,
        type: _historyType,
        status: _historyStatus,
        q: _historyQuery,
        page: 1,
        limit: _historyPageSize,
      );
      _transactions = txResult.items;
      _historyTxPage = 2;
      _txHasMore = _pageHasMore(
        itemCount: txResult.items.length,
        total: txResult.total,
        loadedCount: _transactions.length,
        limit: _historyPageSize,
      );

      _prunePendingIfOperationTerminalInList();
      _historyFetchKey = key;
      _historyFetchedAt = DateTime.now();
    } catch (e) {
      _captureError(e);
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Appends next pages (operations and/or transactions) when user scrolls near the end.
  Future<void> loadMoreHistory() async {
    if (_loadingMoreHistory || _isLoadingHistory) return;
    if (!_opHasMore && !_txHasMore) return;

    _loadingMoreHistory = true;
    notifyListeners();

    try {
      if (_opHasMore) {
        final opResult = await _repository.listOperations(
          chain: _historyChain,
          type: _historyType,
          status: _historyStatus,
          q: _historyQuery,
          page: _historyOpPage,
          limit: _historyPageSize,
        );
        _operations = [..._operations, ...opResult.items];
        _historyOpPage += 1;
        _opHasMore = _pageHasMore(
          itemCount: opResult.items.length,
          total: opResult.total,
          loadedCount: _operations.length,
          limit: _historyPageSize,
        );
      }

      if (_txHasMore) {
        final txResult = await _repository.listTransactions(
          chain: _historyChain,
          type: _historyType,
          status: _historyStatus,
          q: _historyQuery,
          page: _historyTxPage,
          limit: _historyPageSize,
        );
        _transactions = [..._transactions, ...txResult.items];
        _historyTxPage += 1;
        _txHasMore = _pageHasMore(
          itemCount: txResult.items.length,
          total: txResult.total,
          loadedCount: _transactions.length,
          limit: _historyPageSize,
        );
      }

      _prunePendingIfOperationTerminalInList();
    } catch (e) {
      _captureError(e);
    } finally {
      _loadingMoreHistory = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTransactionWallet(String walletId) async {
    _isSubmitting = true;
    _resetDisplayedError();
    notifyListeners();

    try {
      await _repository.deleteTransactionWallet(walletId);
      _pendingOnChainByWallet.remove(walletId);
      _pendingWalletClearTimers.remove(walletId)?.cancel();
      await loadWallets(force: true);
      return true;
    } catch (e) {
      _captureError(e);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> createWallet({
    required String chain,
    required String purpose,
    String? label,
  }) async {
    _isSubmitting = true;
    _resetDisplayedError();
    notifyListeners();

    try {
      await _repository.createWallet(chain: chain, purpose: purpose, label: label);
      await loadWallets(force: true);
      return true;
    } catch (e) {
      _captureError(e);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> sweepWallet(
    String walletId, {
    String? mainWalletId,
    String asset = 'NATIVE',
  }) async {
    _isSubmitting = true;
    _resetDisplayedError();
    notifyListeners();

    try {
      final result = await _repository.sweepWallet(
        walletId,
        mainWalletId: mainWalletId,
        asset: asset,
      );
      final opId = _parseOperationId(result);
      _trackPendingOnChain(walletId, opId);
      await refreshAll();
      return true;
    } catch (e) {
      _captureError(e);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> fundWallet({
    required String walletId,
    required String amount,
    String asset = 'NATIVE',
  }) async {
    _isSubmitting = true;
    _resetDisplayedError();
    notifyListeners();

    try {
      final result = await _repository.fundWallet(
        walletId: walletId,
        amount: amount,
        asset: asset,
      );
      final opId = _parseOperationId(result);
      _trackPendingOnChain(walletId, opId);
      await refreshAll();
      return true;
    } catch (e) {
      _captureError(e);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll({bool force = true}) async {
    await Future.wait([
      loadWallets(force: force),
      loadHistory(force: force),
    ]);
  }

  Future<bool> manualRetryTreasuryOperation(
    String operationId, {
    String? mainWalletId,
  }) async {
    _isSubmitting = true;
    _resetDisplayedError();
    notifyListeners();
    try {
      await _repository.manualRetryTreasuryOperation(operationId, mainWalletId: mainWalletId);
      await refreshAll();
      return true;
    } catch (e) {
      _captureError(e);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> manualAbortTreasuryOperation(String operationId, {String? reason}) async {
    _isSubmitting = true;
    _resetDisplayedError();
    notifyListeners();
    try {
      await _repository.manualAbortTreasuryOperation(operationId, reason: reason);
      await refreshAll();
      _clearOnChainPendingState();
      return true;
    } catch (e) {
      _captureError(e);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> manualSettleTreasuryOperation(
    String operationId, {
    required String txHash,
    String? mainWalletId,
  }) async {
    _isSubmitting = true;
    _resetDisplayedError();
    notifyListeners();
    try {
      await _repository.manualSettleTreasuryOperation(
        operationId,
        txHash: txHash,
        mainWalletId: mainWalletId,
      );
      await refreshAll();
      _clearOnChainPendingState();
      return true;
    } catch (e) {
      _captureError(e);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void handleRealtimeEvent(Map<String, dynamic> event) {
    final nested = event['payload'];
    final nestedMap =
        nested is Map ? Map<String, dynamic>.from(nested) : null;

    final opStatus = (event['status'] ??
            event['operation_status'] ??
            nestedMap?['status'] ??
            nestedMap?['operation_status'] ??
            '')
        .toString()
        .toUpperCase();
    final eventName = (event['event'] ?? nestedMap?['event'] ?? '')
        .toString()
        .toLowerCase();
    final isTerminalStatus = opStatus == 'COMPLETED' || opStatus == 'FAILED';
    final isOpTerminalEvent = eventName.contains('operation.completed') ||
        eventName.contains('operation.failed');
    final isWalletCreated = eventName == 'wallet.created' ||
        eventName.contains('wallet.created');

    if (!isTerminalStatus && !isOpTerminalEvent && !isWalletCreated) {
      return;
    }

    _realtimeRefreshDebounce?.cancel();
    _realtimeRefreshDebounce = Timer(const Duration(milliseconds: 350), () async {
      await refreshAll(force: true);
      if (isOpTerminalEvent || isTerminalStatus) {
        _clearOnChainPendingState();
      }
    });
  }

  static String? _parseOperationId(Map<String, dynamic> body) {
    final raw = body['operationId'] ?? body['operation_id'];
    if (raw == null) return null;
    final s = raw.toString();
    return s.isEmpty ? null : s;
  }

  void clearError() {
    _resetDisplayedError();
    notifyListeners();
  }

  @override
  void dispose() {
    _realtimeRefreshDebounce?.cancel();
    for (final t in _pendingWalletClearTimers.values) {
      t.cancel();
    }
    _pendingWalletClearTimers.clear();
    super.dispose();
  }
}
