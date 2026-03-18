import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/data/models/user_model.dart';
import 'package:crypto_trading_app/data/models/admin_wallet_adjustment_model.dart';
import 'package:crypto_trading_app/domain/entities/user.dart';
import 'package:crypto_trading_app/domain/entities/admin_wallet_adjustment.dart';
import 'package:crypto_trading_app/domain/entities/onchain_transaction.dart';
import 'package:crypto_trading_app/domain/entities/user_security_change.dart';

/// Mô tả số dư ví đơn giản dùng cho admin view.
class AdminUserWalletItem {
  final String walletId;
  final String currencyId;
  final String symbol;
  final String name;
  final String available;
  final String frozen;
  final String total;

  const AdminUserWalletItem({
    required this.walletId,
    required this.currencyId,
    required this.symbol,
    required this.name,
    required this.available,
    required this.frozen,
    required this.total,
  });

  factory AdminUserWalletItem.fromJson(Map<String, dynamic> json) {
    return AdminUserWalletItem(
      walletId: json['walletId']?.toString() ?? '',
      currencyId: json['currencyId']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      available: json['available']?.toString() ?? '0',
      frozen: json['frozen']?.toString() ?? '0',
      total: json['total']?.toString() ?? '0',
    );
  }

  bool get hasBalance => (double.tryParse(total) ?? 0) > 0;
}

/// Provider quản lý toàn bộ state cho màn hình Admin User Management.
/// Bao gồm: danh sách users, tìm kiếm/lọc, user được chọn và các tab dữ liệu của user đó.
class AdminUsersProvider extends ChangeNotifier {
  final DioClient _dioClient;

  AdminUsersProvider({required DioClient dioClient}) : _dioClient = dioClient;

  /// Notifies listeners safely from async callbacks.
  ///
  /// On desktop (Windows) a LayoutBuilder's build phase can overlap with async
  /// completion handlers, triggering Flutter's '!_debugDoingThisLayout' and
  /// '!_debugDuringDeviceUpdate' assertions.  Deferring to post-frame when we
  /// detect we are inside Flutter's persistent-callbacks phase (build/layout/
  /// paint) prevents that race without adding visible flicker for the user.
  void _safeNotify() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }

  // ── User List State ──────────────────────────────────────────────────────────

  List<User> _users = [];
  int _totalUsers = 0;
  int _currentPage = 1;
  static const int _pageSize = 20;
  bool _hasMore = true;
  bool _isLoadingList = false;
  String? _listError;

  // Filter state
  String _searchQuery = '';
  String? _roleFilter;
  String? _statusFilter;

  List<User> get users => List.unmodifiable(_users);
  int get totalUsers => _totalUsers;
  bool get hasMore => _hasMore;
  bool get isLoadingList => _isLoadingList;
  String? get listError => _listError;
  String get searchQuery => _searchQuery;
  String? get roleFilter => _roleFilter;
  String? get statusFilter => _statusFilter;

  // ── Selected User State ──────────────────────────────────────────────────────

  User? _selectedUser;
  User? get selectedUser => _selectedUser;

  // Wallets tab
  List<AdminUserWalletItem> _selectedUserWallets = [];
  bool _isLoadingWallets = false;
  String? _walletsError;

  List<AdminUserWalletItem> get selectedUserWallets =>
      List.unmodifiable(_selectedUserWallets);
  bool get isLoadingWallets => _isLoadingWallets;
  String? get walletsError => _walletsError;

  // Adjustment history tab
  List<AdminWalletAdjustment> _adjustments = [];
  bool _isLoadingAdjustments = false;
  String? _adjustmentsError;

  List<AdminWalletAdjustment> get adjustments =>
      List.unmodifiable(_adjustments);
  bool get isLoadingAdjustments => _isLoadingAdjustments;
  String? get adjustmentsError => _adjustmentsError;

  // Onchain transactions tab
  List<OnchainTransaction> _onchainTxs = [];
  bool _isLoadingOnchainTxs = false;
  String? _onchainTxsError;

  List<OnchainTransaction> get onchainTxs =>
      List.unmodifiable(_onchainTxs);
  bool get isLoadingOnchainTxs => _isLoadingOnchainTxs;
  String? get onchainTxsError => _onchainTxsError;

  // Security changes tab
  List<UserSecurityChange> _securityChanges = [];
  bool _isLoadingSecurityChanges = false;
  String? _securityChangesError;

  List<UserSecurityChange> get securityChanges =>
      List.unmodifiable(_securityChanges);
  bool get isLoadingSecurityChanges => _isLoadingSecurityChanges;
  String? get securityChangesError => _securityChangesError;

  // Orders tab
  List<Map<String, dynamic>> _userOrders = [];
  bool _isLoadingOrders = false;
  String? _ordersError;
  int _ordersTotal = 0;

  List<Map<String, dynamic>> get userOrders =>
      List.unmodifiable(_userOrders);
  bool get isLoadingOrders => _isLoadingOrders;
  String? get ordersError => _ordersError;
  int get ordersTotal => _ordersTotal;

  // ── Adjust Balance State (bottom sheet) ─────────────────────────────────────

  bool _isAdjusting = false;
  String? _adjustError;

  bool get isAdjusting => _isAdjusting;
  String? get adjustError => _adjustError;

  // ── User List Methods ────────────────────────────────────────────────────────

  /// Áp dụng bộ lọc mới và tải lại danh sách từ đầu.
  Future<void> applyFilters({
    String? search,
    String? role,
    String? status,
  }) async {
    _searchQuery = search ?? _searchQuery;
    _roleFilter = role;
    _statusFilter = status;
    await fetchUsers(refresh: true);
  }

  /// Cập nhật từ khóa tìm kiếm và tải lại.
  Future<void> updateSearch(String query) async {
    if (_searchQuery == query) return;
    _searchQuery = query;
    await fetchUsers(refresh: true);
  }

  /// Tải danh sách người dùng với filter hiện tại.
  Future<void> fetchUsers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _users = [];
      _hasMore = true;
    }
    if (!_hasMore || _isLoadingList) return;

    _isLoadingList = true;
    _listError = null;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{
        'page': _currentPage,
        'limit': _pageSize,
        if (_searchQuery.isNotEmpty) 'search': _searchQuery,
        if (_roleFilter != null) 'role': _roleFilter,
        if (_statusFilter != null) 'status': _statusFilter,
        'sortBy': 'created_at',
        'sortOrder': 'DESC',
      };

      final response = await _dioClient.dio.get(
        ApiConstants.users,
        queryParameters: queryParams,
      );

      final data = response.data;
      List<dynamic> rawUsers;
      int total = 0;

      if (data is Map<String, dynamic>) {
        // { data: { users: [...], total: N } } or { users: [...], total: N }
        final inner = data['data'] ?? data;
        if (inner is Map<String, dynamic>) {
          rawUsers = (inner['users'] as List?) ?? [];
          total = (inner['total'] as num?)?.toInt() ?? rawUsers.length;
        } else if (inner is List) {
          rawUsers = inner;
          total = rawUsers.length;
        } else {
          rawUsers = [];
        }
      } else {
        rawUsers = [];
      }

      final newUsers = rawUsers
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();

      _users.addAll(newUsers);
      _totalUsers = total;
      _hasMore = newUsers.length == _pageSize;
      if (_hasMore) _currentPage++;
    } on DioException catch (e) {
      _listError = e.response?.data?['message']?.toString() ??
          e.message ??
          'Không thể tải danh sách người dùng';
    } catch (e) {
      _listError = e.toString();
    } finally {
      _isLoadingList = false;
      _safeNotify();
    }
  }

  /// Tải thêm trang tiếp theo (infinite scroll).
  Future<void> loadMoreUsers() => fetchUsers();

  // ── Selected User Methods ────────────────────────────────────────────────────

  void selectUser(User user) {
    _selectedUser = user;
    _selectedUserWallets = [];
    _adjustments = [];
    _onchainTxs = [];
    _securityChanges = [];
    _userOrders = [];
    _ordersTotal = 0;
    notifyListeners();
  }

  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }

  /// Tải số dư các ví của user được chọn.
  Future<void> fetchSelectedUserWallets() async {
    final userId = _selectedUser?.id;
    if (userId == null) return;

    _isLoadingWallets = true;
    _walletsError = null;
    notifyListeners();

    try {
      final response = await _dioClient.dio.get(ApiConstants.userWallets(userId));
      final data = response.data;
      List<dynamic> raw;

      if (data is Map<String, dynamic>) {
        final inner = data['data'] ?? data;
        raw = inner is List ? inner : [];
      } else if (data is List) {
        raw = data;
      } else {
        raw = [];
      }

      _selectedUserWallets = raw
          .map((e) =>
              AdminUserWalletItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _walletsError = e.response?.data?['message']?.toString() ??
          e.message ??
          'Không thể tải số dư ví';
    } catch (e) {
      _walletsError = e.toString();
    } finally {
      _isLoadingWallets = false;
      _safeNotify();
    }
  }

  /// Tải lịch sử nạp/rút thủ công của user được chọn.
  Future<void> fetchSelectedUserAdjustments() async {
    final userId = _selectedUser?.id;
    if (userId == null) return;

    _isLoadingAdjustments = true;
    _adjustmentsError = null;
    notifyListeners();

    try {
      final response = await _dioClient.dio.get(
        ApiConstants.walletsAdminAdjustmentHistory(userId),
        queryParameters: {'limit': 50, 'offset': 0},
      );
      final data = response.data;
      List<dynamic> raw;

      if (data is Map<String, dynamic>) {
        final inner = data['data'] ?? data;
        raw = inner is List
            ? inner
            : (inner is Map ? (inner['items'] as List? ?? inner['adjustments'] as List? ?? []) : []);
      } else if (data is List) {
        raw = data;
      } else {
        raw = [];
      }

      _adjustments = raw
          .map((e) => AdminWalletAdjustmentModel.fromJson(
              e as Map<String, dynamic>).toEntity())
          .toList();
    } on DioException catch (e) {
      _adjustmentsError = e.response?.data?['message']?.toString() ??
          e.message ??
          'Không thể tải lịch sử nạp/rút';
    } catch (e) {
      _adjustmentsError = e.toString();
    } finally {
      _isLoadingAdjustments = false;
      _safeNotify();
    }
  }

  /// Tải lịch sử giao dịch onchain của user được chọn.
  Future<void> fetchSelectedUserOnchainTxs() async {
    final userId = _selectedUser?.id;
    if (userId == null) return;

    _isLoadingOnchainTxs = true;
    _onchainTxsError = null;
    notifyListeners();

    try {
      final response = await _dioClient.dio.get(
        ApiConstants.userOnchainTxs(userId),
        queryParameters: {'page': 1, 'limit': 50},
      );
      final data = response.data;
      List<dynamic> raw;

      if (data is Map<String, dynamic>) {
        final inner = data['data'] ?? data;
        raw = inner is Map
            ? (inner['items'] as List? ?? [])
            : (inner is List ? inner : []);
      } else if (data is List) {
        raw = data;
      } else {
        raw = [];
      }

      _onchainTxs = raw
          .map((e) => _parseOnchainTx(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _onchainTxsError = e.response?.data?['message']?.toString() ??
          e.message ??
          'Không thể tải lịch sử giao dịch';
    } catch (e) {
      _onchainTxsError = e.toString();
    } finally {
      _isLoadingOnchainTxs = false;
      _safeNotify();
    }
  }

  /// Tải lịch sử thay đổi thông tin của user được chọn.
  Future<void> fetchSelectedUserSecurityChanges() async {
    final userId = _selectedUser?.id;
    if (userId == null) return;

    _isLoadingSecurityChanges = true;
    _securityChangesError = null;
    notifyListeners();

    try {
      final response = await _dioClient.dio.get(
        ApiConstants.userSecurityChanges(userId),
        queryParameters: {'page': 1, 'limit': 50},
      );
      final data = response.data;
      List<dynamic> raw;

      if (data is Map<String, dynamic>) {
        final inner = data['data'] ?? data;
        raw = inner is Map
            ? (inner['items'] as List? ?? [])
            : (inner is List ? inner : []);
      } else if (data is List) {
        raw = data;
      } else {
        raw = [];
      }

      _securityChanges = raw
          .map((e) => _parseSecurityChange(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _securityChangesError = e.response?.data?['message']?.toString() ??
          e.message ??
          'Không thể tải lịch sử thay đổi thông tin';
    } catch (e) {
      _securityChangesError = e.toString();
    } finally {
      _isLoadingSecurityChanges = false;
      _safeNotify();
    }
  }

  // ── Admin Balance Adjustment ─────────────────────────────────────────────────

  /// Thực hiện nạp/rút số dư cho user được chọn. Trả về true nếu thành công.
  Future<bool> adjustBalance({
    required String userId,
    required String currencyId,
    required String amount,
    required String type, // 'DEPOSIT' | 'WITHDRAW'
    String? note,
  }) async {
    _isAdjusting = true;
    _adjustError = null;
    notifyListeners();

    try {
      await _dioClient.dio.post(
        ApiConstants.walletsAdminAdjust,
        data: {
          'userId': userId,
          'currencyId': currencyId,
          'amount': amount,
          'type': type,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
      return true;
    } on DioException catch (e) {
      _adjustError = e.response?.data?['message']?.toString() ??
          e.message ??
          'Thao tác thất bại';
      return false;
    } catch (e) {
      _adjustError = e.toString();
      return false;
    } finally {
      _isAdjusting = false;
      _safeNotify();
    }
  }

  /// Tải danh sách lệnh của user được chọn (admin view).
  Future<void> fetchSelectedUserOrders({
    int page = 1,
    int limit = 20,
  }) async {
    final userId = _selectedUser?.id;
    if (userId == null) return;

    _isLoadingOrders = true;
    _ordersError = null;
    notifyListeners();

    try {
      final response = await _dioClient.dio.get(
        ApiConstants.userOrders(userId),
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data;
      List<dynamic> raw;
      int total = 0;

      if (data is Map<String, dynamic>) {
        final inner = data['data'] ?? data;
        if (inner is Map<String, dynamic>) {
          raw = (inner['orders'] as List?) ??
              (inner['items'] as List?) ??
              [];
          total = (inner['total'] as num?)?.toInt() ?? raw.length;
        } else if (inner is List) {
          raw = inner;
          total = raw.length;
        } else {
          raw = [];
        }
      } else if (data is List) {
        raw = data;
        total = raw.length;
      } else {
        raw = [];
      }

      _userOrders = raw.cast<Map<String, dynamic>>();
      _ordersTotal = total;
    } on DioException catch (e) {
      _ordersError = e.response?.data?['message']?.toString() ??
          e.message ??
          'Không thể tải danh sách lệnh';
    } catch (e) {
      _ordersError = e.toString();
    } finally {
      _isLoadingOrders = false;
      _safeNotify();
    }
  }

  // ── Private Parsers ──────────────────────────────────────────────────────────

  OnchainTransaction _parseOnchainTx(Map<String, dynamic> json) {
    return OnchainTransaction(
      txId: json['tx_id']?.toString() ?? json['txId']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      linkedWalletId: json['linked_wallet_id']?.toString() ?? json['linkedWalletId']?.toString(),
      chain: json['chain']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      txHash: json['tx_hash']?.toString() ?? json['txHash']?.toString(),
      fromAddress: json['from_address']?.toString() ?? json['fromAddress']?.toString() ?? '',
      toAddress: json['to_address']?.toString() ?? json['toAddress']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      confirmations: (json['confirmations'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      confirmedAt: json['confirmed_at'] != null || json['confirmedAt'] != null
          ? _parseDateNullable(json['confirmed_at'] ?? json['confirmedAt'])
          : null,
    );
  }

  UserSecurityChange _parseSecurityChange(Map<String, dynamic> json) {
    return UserSecurityChange(
      requestId: json['request_id']?.toString() ?? json['requestId']?.toString() ?? '',
      changeType: json['change_type']?.toString() ?? json['changeType']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      requestedAt: _parseDate(json['requested_at'] ?? json['requestedAt']),
      reviewedAt: _parseDateNullable(json['reviewed_at'] ?? json['reviewedAt']),
      reviewedBy: json['reviewed_by']?.toString() ?? json['reviewedBy']?.toString(),
      reviewNote: json['review_note']?.toString() ?? json['reviewNote']?.toString(),
    );
  }

  DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }

  DateTime? _parseDateNullable(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}
