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
  bool _isConfirmDialogOpen = false;
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
  bool get isConfirmDialogOpen => _isConfirmDialogOpen;
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

  void startSubmission() {
    _isSubmitting = true;
    _isConfirmDialogOpen = true;
    notifyListeners();
  }

  Future<bool> approve(String txId) async {
    _isSubmitting = true;
    _isConfirmDialogOpen = true;
    _error = null;
    notifyListeners();

    try {
      await _dataSource.approve(txId);
      _withdrawals = _withdrawals.where((w) => w.txId != txId).toList();
      _selectedDetail = null;
      await loadStats();
      return true;
    } catch (e) {
      final errorString = e.toString();
      _error = _friendlyErrorMessage(errorString);
      _withdrawals = _withdrawals.where((w) => w.txId != txId).toList();
      await loadStats();
      return false;
    } finally {
      _isSubmitting = false;
      _isConfirmDialogOpen = false;
      notifyListeners();
    }
  }

  Future<bool> reject(String txId, {String? reason}) async {
    _isSubmitting = true;
    _isConfirmDialogOpen = true;
    _error = null;
    notifyListeners();

    try {
      await _dataSource.reject(txId, reason: reason);
      _withdrawals = _withdrawals.where((w) => w.txId != txId).toList();
      _selectedDetail = null;
      await loadStats();
      return true;
    } catch (e) {
      _error = _friendlyErrorMessage(e.toString());
      await loadWithdrawals(
        status: _filterStatus,
        chain: _filterChain,
        search: _filterSearch,
        dateFrom: _filterDateFrom,
        dateTo: _filterDateTo,
        page: _page,
      );
      return false;
    } finally {
      _isSubmitting = false;
      _isConfirmDialogOpen = false;
      notifyListeners();
    }
  }

  Future<bool> processPending({int limit = 20}) async {
    _isSubmitting = true;
    _isConfirmDialogOpen = true;
    _error = null;
    notifyListeners();

    try {
      await _dataSource.processPending(limit: limit);
      await loadWithdrawals();
      await loadStats();
      return true;
    } catch (e) {
      _error = _friendlyErrorMessage(e.toString());
      return false;
    } finally {
      _isSubmitting = false;
      _isConfirmDialogOpen = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> batchProcessPending({int limit = 20}) async {
    _isSubmitting = true;
    _isConfirmDialogOpen = true;
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
      _error = _friendlyErrorMessage(e.toString());
      return {};
    } finally {
      _isSubmitting = false;
      _isConfirmDialogOpen = false;
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

  /// Map raw API error strings to user-friendly messages.
  String _friendlyErrorMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('already_processing') ||
        lower.contains('dang duoc xu ly') ||
        lower.contains('conflict')) {
      return 'Yeu cau nay dang duoc xu ly boi thao tac khac. Vui long doi va thu lai.';
    }
    if (lower.contains('not_found') || lower.contains('khong tim thay')) {
      return 'Khong tim thay giao dich nay. Co the no da duoc xu ly truoc do.';
    }
    if (lower.contains('invalid_status') || lower.contains('trang thai')) {
      return 'Giao dich khong con o trang thai chap nhan. Vui long tai lai danh sach.';
    }
    if (lower.contains('blockchain') || lower.contains('giao dich blockchain')) {
      return 'Giao dich blockchain that bai. Vui long thu lai hoac lien he ho tro.';
    }
    if (lower.contains('hot_wallet') || lower.contains('vi rut tien')) {
      return 'He thong dang gap van de voi vi rut tien. Vui long thu lai sau.';
    }
    if (lower.contains('insufficient') || lower.contains('khong du')) {
      return 'So du khong du de thuc hien giao dich.';
    }
    return raw;
  }
}
