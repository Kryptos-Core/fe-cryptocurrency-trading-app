import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/features/admin/withdrawal_management/data/datasources/withdrawal_admin_remote_datasource.dart';
import 'package:crypto_trading_app/features/admin/withdrawal_management/data/models/admin_withdrawal_model.dart';

/// WithdrawalManagementProvider
/// Manages admin withdrawal list, stats, approve/reject for FINANCE_MANAGER.
class WithdrawalManagementProvider extends ChangeNotifier {
  final WithdrawalAdminRemoteDataSource _dataSource;

  WithdrawalManagementProvider({required WithdrawalAdminRemoteDataSource dataSource})
      : _dataSource = dataSource;

  List<AdminWithdrawalModel> _withdrawals = [];
  AdminWithdrawalStatsModel? _stats;
  AdminWithdrawalModel? _selectedDetail;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  String? _filterStatus;
  String? _filterChain;
  String? _filterSearch;
  String? _filterDateFrom;
  String? _filterDateTo;
  int _total = 0;
  int _page = 1;
  int _limit = 20;

  List<AdminWithdrawalModel> get withdrawals => _withdrawals;
  AdminWithdrawalStatsModel? get stats => _stats;
  AdminWithdrawalModel? get selectedDetail => _selectedDetail;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  int get total => _total;
  int get page => _page;
  int get limit => _limit;

  String? get filterStatus => _filterStatus;
  String? get filterChain => _filterChain;
  String? get filterSearch => _filterSearch;
  String? get filterDateFrom => _filterDateFrom;
  String? get filterDateTo => _filterDateTo;

  Future<void> loadWithdrawals({
    String? status,
    String? chain,
    String? search,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int limit = 20,
  }) async {
    _isLoading = true;
    _error = null;
    _filterStatus = status;
    _filterChain = chain;
    _filterSearch = search;
    _filterDateFrom = dateFrom;
    _filterDateTo = dateTo;
    _page = page;
    _limit = limit;
    notifyListeners();

    try {
      final result = await _dataSource.listWithdrawals(
        status: status,
        chain: chain,
        search: search,
        dateFrom: dateFrom,
        dateTo: dateTo,
        page: page,
        limit: limit,
      );
      _withdrawals = (result['data'] as List<dynamic>?)
              ?.whereType<AdminWithdrawalModel>()
              .toList() ??
          [];
      _total = result['total'] as int? ?? 0;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStats() async {
    try {
      _stats = await _dataSource.getStats();
      notifyListeners();
    } catch (_) {
      // non-critical
    }
  }

  Future<AdminWithdrawalModel?> loadDetail(String txId) async {
    _isLoading = true;
    _error = null;
    _selectedDetail = null;
    notifyListeners();

    try {
      _selectedDetail = await _dataSource.getWithdrawalDetail(txId);
      return _selectedDetail;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approve(String txId) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _dataSource.approve(txId);
      _withdrawals = _withdrawals.where((w) => w.txId != txId).toList();
      _selectedDetail = null;
      await loadStats();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> reject(String txId, {String? reason}) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _dataSource.reject(txId, reason: reason);
      _withdrawals = _withdrawals.where((w) => w.txId != txId).toList();
      _selectedDetail = null;
      await loadStats();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> batchProcessPending({int limit = 20}) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _dataSource.processPending(limit: limit);
      await loadWithdrawals(
        status: _filterStatus,
        chain: _filterChain,
        search: _filterSearch,
        dateFrom: _filterDateFrom,
        dateTo: _filterDateTo,
        page: _page,
        limit: _limit,
      );
      await loadStats();
      return result;
    } catch (e) {
      _error = e.toString();
      return {};
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearDetail() {
    _selectedDetail = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
