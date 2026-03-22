import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/data/datasources/treasury_remote_datasource.dart';
import 'package:crypto_trading_app/data/models/treasury_model.dart';

class TreasuryProvider extends ChangeNotifier {
  final TreasuryRemoteDataSource _dataSource;

  TreasuryProvider({required TreasuryRemoteDataSource dataSource})
      : _dataSource = dataSource;

  List<TreasuryWalletModel> _wallets = [];
  List<TreasuryMainWalletModel> _mainWallets = [];
  List<TreasuryOperationModel> _operations = [];
  List<TreasuryTransactionModel> _transactions = [];

  bool _isLoadingWallets = false;
  bool _isLoadingHistory = false;
  bool _isSubmitting = false;
  String? _error;

  String? _walletChain;
  String? _walletPurpose;

  String? _historyChain;
  String? _historyType;
  String? _historyStatus;
  String? _historyQuery;
  Timer? _realtimeRefreshDebounce;
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
      final list = await _dataSource.listMainWallets(chain);
      _mainWallets = list;
      notifyListeners();
    } catch (e) {
      _mainWallets = [];
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadWallets() async {
    _isLoadingWallets = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _dataSource.listWallets(
        chain: _walletChain,
        purpose: _walletPurpose,
      );
      _wallets = list;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingWallets = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory() async {
    _isLoadingHistory = true;
    _error = null;
    notifyListeners();

    try {
      final opResult = await _dataSource.listOperations(
        chain: _historyChain,
        type: _historyType,
        status: _historyStatus,
        q: _historyQuery,
      );
      _operations = opResult.items;

      final txResult = await _dataSource.listTransactions(
        chain: _historyChain,
        type: _historyType,
        status: _historyStatus,
        q: _historyQuery,
      );
      _transactions = txResult.items;
      _prunePendingIfOperationTerminalInList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<bool> createWallet({
    required String chain,
    required String purpose,
    String? label,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _dataSource.createWallet(chain: chain, purpose: purpose, label: label);
      await loadWallets();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> sweepWallet(String walletId, {String? mainWalletId}) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final result =
          await _dataSource.sweepWallet(walletId, mainWalletId: mainWalletId);
      final opId = _parseOperationId(result);
      _trackPendingOnChain(walletId, opId);
      await refreshAll();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> fundWallet({
    required String walletId,
    required String amount,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final result =
          await _dataSource.fundWallet(walletId: walletId, amount: amount);
      final opId = _parseOperationId(result);
      _trackPendingOnChain(walletId, opId);
      await refreshAll();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadWallets(),
      loadHistory(),
    ]);
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
      await refreshAll();
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
    _error = null;
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
