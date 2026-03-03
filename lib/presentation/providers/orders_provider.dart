import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/domain/entities/order.dart';
import 'package:crypto_trading_app/domain/entities/order_book_level.dart';
import 'package:crypto_trading_app/domain/entities/wallet_balance.dart';
import 'package:crypto_trading_app/domain/repositories/orders_repository.dart';
import 'package:crypto_trading_app/domain/repositories/wallet_repository.dart';

/// Orders Provider (State management cho Orders + Order Book + Balance cho cặp)
///
/// Single Responsibility: quản lý state orders/my orders/order book, balance base/quote.
class OrdersProvider extends ChangeNotifier {
  final OrdersRepository _ordersRepository;
  final WalletRepository? _walletRepository;

  OrdersProvider({
    required OrdersRepository ordersRepository,
    WalletRepository? walletRepository,
  })  : _ordersRepository = ordersRepository,
        _walletRepository = walletRepository;

  // --- State ---
  List<OrderBookLevel> _orderBookBids = [];
  List<OrderBookLevel> _orderBookAsks = [];
  String? _orderBookPairId;
  List<Order> _myOrders = [];
  int _myOrdersTotal = 0;
  int _myOrdersPage = 1;
  int _myOrdersLimit = 20;
  String? _myOrdersStatusFilter;
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;

  /// Số dư base (vd. BNB) và quote (vd. USDT) cho cặp đang chọn trên màn Đặt lệnh
  WalletBalance? _baseBalance;
  WalletBalance? _quoteBalance;

  List<OrderBookLevel> get orderBookBids => List.unmodifiable(_orderBookBids);
  List<OrderBookLevel> get orderBookAsks => List.unmodifiable(_orderBookAsks);
  String? get orderBookPairId => _orderBookPairId;
  List<Order> get myOrders => List.unmodifiable(_myOrders);
  int get myOrdersTotal => _myOrdersTotal;
  int get myOrdersPage => _myOrdersPage;
  int get myOrdersLimit => _myOrdersLimit;
  String? get myOrdersStatusFilter => _myOrdersStatusFilter;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  WalletBalance? get baseBalance => _baseBalance;
  WalletBalance? get quoteBalance => _quoteBalance;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Xóa số dư base/quote (khi đổi cặp hoặc không cần hiển thị)
  void clearPairBalances() {
    _baseBalance = null;
    _quoteBalance = null;
    notifyListeners();
  }

  /// Lấy số dư base + quote cho cặp (GET /wallets/balance?currencyId=... x2)
  Future<void> fetchBaseQuoteBalances(String baseCurrencyId, String quoteCurrencyId) async {
    if (_walletRepository == null) {
      _baseBalance = null;
      _quoteBalance = null;
      notifyListeners();
      return;
    }
    final baseResult = await _walletRepository!.getBalance(baseCurrencyId);
    final quoteResult = await _walletRepository!.getBalance(quoteCurrencyId);
    baseResult.fold(
      (_) => _baseBalance = null,
      (b) => _baseBalance = b,
    );
    quoteResult.fold(
      (_) => _quoteBalance = null,
      (b) => _quoteBalance = b,
    );
    notifyListeners();
  }

  /// Tạo lệnh. Nên truyền idempotencyKey unique mỗi lần bấm đặt lệnh.
  Future<Order?> createOrder(CreateOrderRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _ordersRepository.createOrder(request);

    return result.fold<Order?>(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
        return null;
      },
      (Order order) {
        _isLoading = false;
        _error = null;
        _selectedOrder = order;
        notifyListeners();
        return order;
      },
    );
  }

  /// Hủy lệnh (chỉ OPEN/PARTIAL).
  Future<Order?> cancelOrder(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _ordersRepository.cancelOrder(orderId);

    return result.fold<Order?>(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
        return null;
      },
      (Order order) {
        _isLoading = false;
        _error = null;
        _selectedOrder = order;
        _replaceOrderInList(order);
        notifyListeners();
        return order;
      },
    );
  }

  /// Lấy order book (bid + ask) cho một pair. Gọi 2 request song song.
  Future<void> fetchOrderBook(String pairId, {int limit = 50}) async {
    _isLoading = true;
    _error = null;
    _orderBookPairId = pairId;
    notifyListeners();

    final bidResult = await _ordersRepository.getOrderBook(
      pairId,
      side: 'BUY',
      limit: limit,
    );
    final askResult = await _ordersRepository.getOrderBook(
      pairId,
      side: 'SELL',
      limit: limit,
    );

    bidResult.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _orderBookBids = [];
      },
      (list) => _orderBookBids = list,
    );
    askResult.fold(
      (failure) {
        if (_error == null) _error = _mapFailureToMessage(failure);
        _orderBookAsks = [];
      },
      (list) => _orderBookAsks = list,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Danh sách lệnh của user (có phân trang, lọc status).
  Future<void> fetchMyOrders({
    int page = 1,
    int limit = 20,
    String? status,
    bool refresh = false,
  }) async {
    if (refresh) {
      _myOrders = [];
      _myOrdersPage = 1;
    }

    _isLoading = true;
    _error = null;
    _myOrdersPage = page;
    _myOrdersLimit = limit;
    _myOrdersStatusFilter = status;
    notifyListeners();

    final result = await _ordersRepository.getMyOrders(
      page: page,
      limit: limit,
      status: status,
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (res) {
        if (refresh) {
          _myOrders = res.data;
        } else {
          _myOrders = res.data;
        }
        _myOrdersTotal = res.total;
        _myOrdersPage = res.page;
        _myOrdersLimit = res.limit;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
    );
  }

  /// Chi tiết một lệnh (chỉ chủ lệnh).
  Future<void> fetchOrderById(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _ordersRepository.getOrderById(orderId);

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _selectedOrder = null;
        _isLoading = false;
        notifyListeners();
      },
      (Order order) {
        _selectedOrder = order;
        _replaceOrderInList(order);
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
    );
  }

  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  void _replaceOrderInList(Order order) {
    final i = _myOrders.indexWhere((o) => o.orderId == order.orderId);
    if (i >= 0) {
      _myOrders = List.from(_myOrders)..[i] = order;
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message.isNotEmpty
            ? failure.message
            : 'Server error. Please try again.';
      case NetworkFailure:
        return 'Network error. Check your connection.';
      case ValidationFailure:
        return failure.message;
      case NotFoundFailure:
        return failure.message.isNotEmpty ? failure.message : 'Order not found.';
      case AuthenticationFailure:
        return 'Please sign in again.';
      default:
        return failure.message;
    }
  }
}
