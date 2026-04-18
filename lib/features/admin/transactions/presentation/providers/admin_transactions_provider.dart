import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';

/// Generic paginated section state for admin transaction tabs.
class _SectionState<T> {
  List<T> items = [];
  bool isLoading = false;
  String? error;
  int page = 1;
  bool hasMore = true;
  int total = 0;

  // Active filters
  String? filterUserId;
  String? filterStatus;
  String? filterPair;  // orders only
  String? filterChain; // withdrawals only

  void reset() {
    items = [];
    page = 1;
    hasMore = true;
    total = 0;
    error = null;
    isLoading = false;
  }
}

/// Provider managing the 3-tab AdminTransactionsScreen state.
/// Each tab (Orders / Deposits / Withdrawals) has independent pagination, filters, and loading state.
class AdminTransactionsProvider extends ChangeNotifier {
  final DioClient _dioClient;

  AdminTransactionsProvider({required DioClient dioClient})
      : _dioClient = dioClient;

  static const int _pageSize = 20;

  void _safeNotify() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }

  // ── Orders section ────────────────────────────────────────────────────────

  final _orders = _SectionState<Map<String, dynamic>>();

  List<Map<String, dynamic>> get orders =>
      List.unmodifiable(_orders.items);
  bool get isLoadingOrders => _orders.isLoading;
  String? get ordersError => _orders.error;
  bool get ordersHasMore => _orders.hasMore;
  int get ordersTotal => _orders.total;
  String? get ordersFilterUserId => _orders.filterUserId;
  String? get ordersFilterStatus => _orders.filterStatus;
  String? get ordersFilterPair => _orders.filterPair;

  bool _reconcileMatchingLoading = false;
  bool get isReconcileMatchingLoading => _reconcileMatchingLoading;

  // ── Deposits section ──────────────────────────────────────────────────────

  final _deposits = _SectionState<Map<String, dynamic>>();

  List<Map<String, dynamic>> get deposits =>
      List.unmodifiable(_deposits.items);
  bool get isLoadingDeposits => _deposits.isLoading;
  String? get depositsError => _deposits.error;
  bool get depositsHasMore => _deposits.hasMore;
  int get depositsTotal => _deposits.total;
  String? get depositsFilterUserId => _deposits.filterUserId;
  String? get depositsFilterStatus => _deposits.filterStatus;

  // ── Withdrawals section ───────────────────────────────────────────────────

  final _withdrawals = _SectionState<Map<String, dynamic>>();

  List<Map<String, dynamic>> get withdrawals =>
      List.unmodifiable(_withdrawals.items);
  bool get isLoadingWithdrawals => _withdrawals.isLoading;
  String? get withdrawalsError => _withdrawals.error;
  bool get withdrawalsHasMore => _withdrawals.hasMore;
  int get withdrawalsTotal => _withdrawals.total;
  String? get withdrawalsFilterUserId => _withdrawals.filterUserId;
  String? get withdrawalsFilterStatus => _withdrawals.filterStatus;
  String? get withdrawalsFilterChain => _withdrawals.filterChain;

  // ── Orders methods ────────────────────────────────────────────────────────

  Future<void> applyOrderFilters({
    String? userId,
    String? status,
    String? pairId,
  }) async {
    _orders.filterUserId = userId;
    _orders.filterStatus = status;
    _orders.filterPair = pairId;
    _orders.reset();
    notifyListeners();
    await fetchOrders();
  }

  Future<void> fetchOrders({bool refresh = false}) async {
    if (refresh) _orders.reset();
    if (!_orders.hasMore || _orders.isLoading) return;

    _orders.isLoading = true;
    _orders.error = null;
    notifyListeners();

    try {
      final resp = await _dioClient.dio.get(
        ApiConstants.ordersAdminAll,
        queryParameters: {
          'page': _orders.page,
          'limit': _pageSize,
          if (_orders.filterUserId?.isNotEmpty == true)
            'userId': _orders.filterUserId,
          if (_orders.filterStatus?.isNotEmpty == true)
            'status': _orders.filterStatus,
          if (_orders.filterPair?.isNotEmpty == true)
            'pairId': _orders.filterPair,
        },
      );
      final parsed = _parseListResponse(resp.data, 'data');
      _orders.items.addAll(
          parsed.items.cast<Map<String, dynamic>>());
      _orders.total = parsed.total;
      _orders.hasMore = parsed.items.length == _pageSize;
      if (_orders.hasMore) _orders.page++;
    } on DioException catch (e) {
      _orders.error = _errorMsg(e);
    } catch (e) {
      _orders.error = e.toString();
    } finally {
      _orders.isLoading = false;
      _safeNotify();
    }
  }

  Future<void> loadMoreOrders() => fetchOrders();

  /// POST /orders/admin/reconcile-matching/:pairId — ops recovery (requires matching:reconcile).
  Future<OrdersMatchingReconcileResult> reconcileOrdersMatching(
      String pairId) async {
    final id = pairId.trim();
    if (id.isEmpty) {
      throw ArgumentError('pairId empty');
    }
    _reconcileMatchingLoading = true;
    notifyListeners();
    try {
      final resp = await _dioClient.dio.post(
        ApiConstants.ordersAdminReconcileMatching(id),
      );
      final data = resp.data;
      if (data is! Map) {
        throw StateError('Invalid reconcile response');
      }
      final envelope = Map<String, dynamic>.from(data);
      final inner = envelope['data'];
      final payload = inner is Map<String, dynamic>
          ? inner
          : inner is Map
              ? Map<String, dynamic>.from(inner)
              : envelope;
      return OrdersMatchingReconcileResult.fromJson(payload);
    } on DioException catch (e) {
      throw Exception(_errorMsg(e));
    } finally {
      _reconcileMatchingLoading = false;
      _safeNotify();
    }
  }

  // ── Deposits methods ──────────────────────────────────────────────────────

  Future<void> applyDepositFilters({
    String? userId,
    String? status,
  }) async {
    _deposits.filterUserId = userId;
    _deposits.filterStatus = status;
    _deposits.reset();
    notifyListeners();
    await fetchDeposits();
  }

  Future<void> fetchDeposits({bool refresh = false}) async {
    if (refresh) _deposits.reset();
    if (!_deposits.hasMore || _deposits.isLoading) return;

    _deposits.isLoading = true;
    _deposits.error = null;
    notifyListeners();

    try {
      final resp = await _dioClient.dio.get(
        ApiConstants.depositsAdminAll,
        queryParameters: {
          'page': _deposits.page,
          'limit': _pageSize,
          if (_deposits.filterUserId?.isNotEmpty == true)
            'userId': _deposits.filterUserId,
          if (_deposits.filterStatus?.isNotEmpty == true)
            'status': _deposits.filterStatus,
        },
      );
      final parsed = _parseListResponse(resp.data, 'data');
      _deposits.items.addAll(
          parsed.items.cast<Map<String, dynamic>>());
      _deposits.total = parsed.total;
      _deposits.hasMore = parsed.items.length == _pageSize;
      if (_deposits.hasMore) _deposits.page++;
    } on DioException catch (e) {
      _deposits.error = _errorMsg(e);
    } catch (e) {
      _deposits.error = e.toString();
    } finally {
      _deposits.isLoading = false;
      _safeNotify();
    }
  }

  Future<void> loadMoreDeposits() => fetchDeposits();

  // ── Withdrawals methods ───────────────────────────────────────────────────

  Future<void> applyWithdrawalFilters({
    String? userId,
    String? status,
    String? chain,
  }) async {
    _withdrawals.filterUserId = userId;
    _withdrawals.filterStatus = status;
    _withdrawals.filterChain = chain;
    _withdrawals.reset();
    notifyListeners();
    await fetchWithdrawals();
  }

  Future<void> fetchWithdrawals({bool refresh = false}) async {
    if (refresh) _withdrawals.reset();
    if (!_withdrawals.hasMore || _withdrawals.isLoading) return;

    _withdrawals.isLoading = true;
    _withdrawals.error = null;
    notifyListeners();

    try {
      final resp = await _dioClient.dio.get(
        ApiConstants.blockchainAdminWithdrawals,
        queryParameters: {
          'page': _withdrawals.page,
          'limit': _pageSize,
          if (_withdrawals.filterUserId?.isNotEmpty == true)
            'userId': _withdrawals.filterUserId,
          if (_withdrawals.filterStatus?.isNotEmpty == true)
            'status': _withdrawals.filterStatus,
          if (_withdrawals.filterChain?.isNotEmpty == true)
            'chain': _withdrawals.filterChain,
        },
      );
      final parsed = _parseListResponse(resp.data, 'data');
      _withdrawals.items.addAll(
          parsed.items.cast<Map<String, dynamic>>());
      _withdrawals.total = parsed.total;
      _withdrawals.hasMore = parsed.items.length == _pageSize;
      if (_withdrawals.hasMore) _withdrawals.page++;
    } on DioException catch (e) {
      _withdrawals.error = _errorMsg(e);
    } catch (e) {
      _withdrawals.error = e.toString();
    } finally {
      _withdrawals.isLoading = false;
      _safeNotify();
    }
  }

  Future<void> loadMoreWithdrawals() => fetchWithdrawals();

  // ── Helpers ───────────────────────────────────────────────────────────────

  ({List<dynamic> items, int total}) _parseListResponse(
      dynamic data, String itemsKey) {
    if (data is Map<String, dynamic>) {
      final inner = data['data'] ?? data;
      if (inner is Map<String, dynamic>) {
        final items = (inner[itemsKey] as List?) ??
            (inner['items'] as List?) ??
            (inner['orders'] as List?) ??
            [];
        final total = (inner['total'] as num?)?.toInt() ?? items.length;
        return (items: items, total: total);
      } else if (inner is List) {
        return (items: inner, total: inner.length);
      }
    } else if (data is List) {
      return (items: data, total: data.length);
    }
    return (items: [], total: 0);
  }

  String _errorMsg(DioException e) =>
      e.response?.data?['message']?.toString() ??
      e.message ??
      'Đã có lỗi xảy ra';
}

/// Response from POST /orders/admin/reconcile-matching/:pairId
class OrdersMatchingReconcileResult {
  final String pairId;
  final int tradesExecuted;
  final int matchRuns;
  final int openOrdersRemaining;
  final String stoppedReason;

  const OrdersMatchingReconcileResult({
    required this.pairId,
    required this.tradesExecuted,
    required this.matchRuns,
    required this.openOrdersRemaining,
    required this.stoppedReason,
  });

  factory OrdersMatchingReconcileResult.fromJson(Map<String, dynamic> j) {
    int n(String a, [String? b]) {
      final v = j[a] ?? (b != null ? j[b] : null);
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    String s(String a, [String? b]) =>
        j[a]?.toString() ?? (b != null ? j[b]?.toString() : null) ?? '';

    return OrdersMatchingReconcileResult(
      pairId: s('pairId', 'pair_id'),
      tradesExecuted: n('tradesExecuted', 'trades_executed'),
      matchRuns: n('matchRuns', 'match_runs'),
      openOrdersRemaining: n('openOrdersRemaining', 'open_orders_remaining'),
      stoppedReason: s('stoppedReason', 'stopped_reason'),
    );
  }
}
