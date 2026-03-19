import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/data/datasources/treasury_remote_datasource.dart';
import 'package:crypto_trading_app/data/models/treasury_model.dart';

class TreasuryProvider extends ChangeNotifier {
  final TreasuryRemoteDataSource _dataSource;

  TreasuryProvider({required TreasuryRemoteDataSource dataSource})
      : _dataSource = dataSource;

  List<TreasuryWalletModel> _wallets = [];
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

  List<TreasuryWalletModel> get wallets => _wallets;
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

  Future<bool> sweepWallet(String walletId) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _dataSource.sweepWallet(walletId);
      await loadHistory();
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
      await _dataSource.fundWallet(walletId: walletId, amount: amount);
      await loadHistory();
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
    final opStatus = (event['status'] ?? event['operation_status'] ?? '').toString().toUpperCase();
    final eventName = (event['event'] ?? '').toString().toLowerCase();
    final isTerminalStatus = opStatus == 'COMPLETED' || opStatus == 'FAILED';
    final isRelevantEvent = eventName.contains('operation.completed') || eventName.contains('operation.failed');

    if (!isTerminalStatus && !isRelevantEvent) {
      return;
    }

    _realtimeRefreshDebounce?.cancel();
    _realtimeRefreshDebounce = Timer(const Duration(milliseconds: 350), () async {
      await refreshAll();
    });
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _realtimeRefreshDebounce?.cancel();
    super.dispose();
  }
}
