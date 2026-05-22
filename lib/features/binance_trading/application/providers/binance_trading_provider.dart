import 'package:flutter/foundation.dart';
import '../../domain/entities/binance_trading_entities.dart';
import '../../domain/repositories/binance_trading_repository.dart';

enum TradingStatus { idle, loading, placing, error }

class BinanceTradingProvider extends ChangeNotifier {
  final BinanceTradingRepository _repository;

  List<BinanceSpotBalance> _balances = [];
  List<BinanceSpotOrder> _openOrders = [];
  List<BinanceSpotOrder> _orderHistory = [];
  List<BinanceFuturesPosition> _futuresPositions = [];
  List<BinanceFuturesBalance> _futuresBalances = [];
  TradingStatus _status = TradingStatus.idle;
  String? _error;
  String? _selectedSymbol;
  String _selectedCredentialId = '';

  BinanceTradingProvider({required BinanceTradingRepository repository})
      : _repository = repository;

  List<BinanceSpotBalance> get balances => _balances;
  List<BinanceSpotOrder> get openOrders => _openOrders;
  List<BinanceSpotOrder> get orderHistory => _orderHistory;
  List<BinanceFuturesPosition> get futuresPositions => _futuresPositions;
  List<BinanceFuturesBalance> get futuresBalances => _futuresBalances;
  TradingStatus get status => _status;
  String? get error => _error;
  String? get selectedSymbol => _selectedSymbol;
  String get selectedCredentialId => _selectedCredentialId;
  bool get isLoading => _status == TradingStatus.loading;
  bool get isPlacing => _status == TradingStatus.placing;

  void setCredentialId(String credentialId) {
    _selectedCredentialId = credentialId;
    notifyListeners();
  }

  void setSelectedSymbol(String symbol) {
    _selectedSymbol = symbol;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadBalances() async {
    if (_selectedCredentialId.isEmpty) return;
    _status = TradingStatus.loading;
    _error = null;
    notifyListeners();

    final result = await _repository.getSpotBalances(_selectedCredentialId);
    result.fold(
      (failure) {
        _status = TradingStatus.error;
        _error = failure.message;
      },
      (balances) {
        _balances = balances;
        _status = TradingStatus.idle;
      },
    );
    notifyListeners();
  }

  Future<void> loadOpenOrders({String? symbol}) async {
    if (_selectedCredentialId.isEmpty) return;
    _status = TradingStatus.loading;
    notifyListeners();

    final result = await _repository.getOpenOrders(
      _selectedCredentialId,
      symbol: symbol,
    );
    result.fold(
      (failure) {
        _status = TradingStatus.error;
        _error = failure.message;
      },
      (orders) {
        _openOrders = orders;
        _status = TradingStatus.idle;
      },
    );
    notifyListeners();
  }

  Future<void> loadOrderHistory({String? symbol, int? limit}) async {
    if (_selectedCredentialId.isEmpty) return;
    _status = TradingStatus.loading;
    notifyListeners();

    final result = await _repository.getOrderHistory(
      _selectedCredentialId,
      symbol: symbol,
      limit: limit,
    );
    result.fold(
      (failure) {
        _status = TradingStatus.error;
        _error = failure.message;
      },
      (orders) {
        _orderHistory = orders;
        _status = TradingStatus.idle;
      },
    );
    notifyListeners();
  }

  Future<({bool success, String? error})> placeSpotOrder({
    required String symbol,
    required String side,
    required String type,
    required String quantity,
    String? price,
    String? timeInForce,
    String? stopPrice,
  }) async {
    _status = TradingStatus.placing;
    _error = null;
    notifyListeners();

    final result = await _repository.placeSpotOrder(
      credentialId: _selectedCredentialId,
      symbol: symbol,
      side: side,
      type: type,
      quantity: quantity,
      price: price,
      timeInForce: timeInForce,
      stopPrice: stopPrice,
    );

    return result.fold(
      (failure) {
        _status = TradingStatus.error;
        _error = failure.message;
        notifyListeners();
        return (success: false, error: failure.message);
      },
      (orderResult) {
        _status = TradingStatus.idle;
        notifyListeners();
        loadOpenOrders(symbol: symbol);
        loadBalances();
        return (success: true, error: null);
      },
    );
  }

  Future<void> cancelSpotOrder({
    required String symbol,
    required String orderId,
  }) async {
    _status = TradingStatus.loading;
    notifyListeners();

    final result = await _repository.cancelSpotOrder(
      credentialId: _selectedCredentialId,
      symbol: symbol,
      orderId: orderId,
    );

    result.fold(
      (failure) {
        _status = TradingStatus.error;
        _error = failure.message;
      },
      (_) {
        _status = TradingStatus.idle;
        loadOpenOrders(symbol: _selectedSymbol);
      },
    );
    notifyListeners();
  }

  Future<void> loadFuturesBalances() async {
    if (_selectedCredentialId.isEmpty) return;
    _status = TradingStatus.loading;
    notifyListeners();

    final result = await _repository.getFuturesBalances(_selectedCredentialId);
    result.fold(
      (failure) {
        _status = TradingStatus.error;
        _error = failure.message;
      },
      (balances) {
        _futuresBalances = balances;
        _status = TradingStatus.idle;
      },
    );
    notifyListeners();
  }

  Future<void> loadFuturesPositions() async {
    if (_selectedCredentialId.isEmpty) return;
    _status = TradingStatus.loading;
    notifyListeners();

    final result = await _repository.getFuturesPositions(_selectedCredentialId);
    result.fold(
      (failure) {
        _status = TradingStatus.error;
        _error = failure.message;
      },
      (positions) {
        _futuresPositions = positions;
        _status = TradingStatus.idle;
      },
    );
    notifyListeners();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadBalances(),
      loadOpenOrders(symbol: _selectedSymbol),
    ]);
  }
}
