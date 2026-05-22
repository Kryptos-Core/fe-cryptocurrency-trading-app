import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';
import '../../domain/entities/binance_credentials.dart';
import '../../domain/entities/binance_trading_entities.dart';

class BinanceTradingRemoteDataSource {
  final DioClient _dioClient;

  BinanceTradingRemoteDataSource({required DioClient dioClient}) : _dioClient = dioClient;

  Dio get _dio => _dioClient.dio;

  Future<({String id, String accountId, String accountType})> saveCredentials({
    required String apiKey,
    required String apiSecret,
    String? label,
    List<String>? permissions,
    bool? testnet,
  }) async {
    final response = await _dio.post(
      '/binance-credentials',
      data: {
        'apiKey': apiKey,
        'apiSecret': apiSecret,
        if (label != null) 'label': label,
        if (permissions != null) 'permissions': permissions,
        if (testnet != null) 'testnet': testnet,
      },
    );
    final data = response.data['data'] ?? response.data;
    return (id: data['id'] as String, accountId: data['accountId'] as String, accountType: data['accountType'] as String);
  }

  Future<List<BinanceCredentials>> listCredentials() async {
    final response = await _dio.get('/binance-credentials');
    final List<dynamic> items = response.data['data'] ?? response.data ?? [];
    return items.map((item) => _parseCredential(item)).toList();
  }

  Future<void> deleteCredential(String credentialId) async {
    await _dio.delete('/binance-credentials/$credentialId');
  }

  Future<({bool success, String? accountId, String? accountType, String? error})> testConnection(
    String credentialId,
  ) async {
    final response = await _dio.post('/binance-credentials/$credentialId/test');
    final data = response.data['data'] ?? response.data;
    return (
      success: data['success'] as bool,
      accountId: data['accountId'] as String?,
      accountType: data['accountType'] as String?,
      error: data['error'] as String?,
    );
  }

  Future<List<BinanceSpotBalance>> getSpotBalances(String credentialId) async {
    final response = await _dio.get(
      '/binance-proxy/spot/balance',
      queryParameters: {'credentialId': credentialId},
    );
    final List<dynamic> items = response.data['data'] ?? response.data ?? [];
    return items.map((b) => BinanceSpotBalance(
      asset: b['asset'] as String,
      free: b['free'] as String,
      locked: b['locked'] as String,
    )).toList();
  }

  Future<BinanceSpotOrderResult> placeSpotOrder({
    required String credentialId,
    required String symbol,
    required String side,
    required String type,
    required String quantity,
    String? price,
    String? timeInForce,
    String? stopPrice,
  }) async {
    final response = await _dio.post(
      '/binance-proxy/spot/order',
      data: {
        'credentialId': credentialId,
        'symbol': symbol,
        'side': side,
        'type': type,
        'quantity': quantity,
        if (price != null) 'price': price,
        if (timeInForce != null) 'timeInForce': timeInForce,
        if (stopPrice != null) 'stopPrice': stopPrice,
      },
    );
    final data = response.data['data'] ?? response.data;
    return BinanceSpotOrderResult(
      orderId: data['orderId']?.toString() ?? '',
      symbol: data['symbol'] as String,
      side: data['side'] as String,
      type: data['type'] as String,
      price: data['price']?.toString() ?? '0',
      origQty: data['origQty']?.toString() ?? '0',
      executedQty: data['executedQty']?.toString() ?? '0',
      status: data['status'] as String,
      transactTime: data['transactTime'] as int,
    );
  }

  Future<void> cancelSpotOrder({
    required String credentialId,
    required String symbol,
    required String orderId,
  }) async {
    await _dio.delete(
      '/binance-proxy/spot/order',
      data: {
        'credentialId': credentialId,
        'symbol': symbol,
        'orderId': orderId,
      },
    );
  }

  Future<List<BinanceSpotOrder>> getOpenOrders(String credentialId, {String? symbol}) async {
    final params = <String, dynamic>{'credentialId': credentialId};
    if (symbol != null) params['symbol'] = symbol;
    final response = await _dio.get('/binance-proxy/spot/orders', queryParameters: params);
    final List<dynamic> items = response.data['data'] ?? response.data ?? [];
    return items.map((o) => BinanceSpotOrder(
      orderId: o['orderId']?.toString() ?? '',
      symbol: o['symbol'] as String,
      side: o['side'] as String,
      type: o['type'] as String,
      price: o['price']?.toString() ?? '0',
      origQty: o['origQty']?.toString() ?? '0',
      executedQty: o['executedQty']?.toString() ?? '0',
      status: o['status'] as String,
      time: o['time'] as int,
      updateTime: o['updateTime'] as int,
      isIsolated: o['isIsolated'] as bool? ?? false,
    )).toList();
  }

  Future<List<BinanceSpotOrder>> getOrderHistory(String credentialId, {String? symbol, int? limit}) async {
    final params = <String, dynamic>{'credentialId': credentialId};
    if (symbol != null) params['symbol'] = symbol;
    if (limit != null) params['limit'] = limit;
    final response = await _dio.get('/binance-proxy/spot/order-history', queryParameters: params);
    final List<dynamic> items = response.data['data'] ?? response.data ?? [];
    return items.map((o) => BinanceSpotOrder(
      orderId: o['orderId']?.toString() ?? '',
      symbol: o['symbol'] as String,
      side: o['side'] as String,
      type: o['type'] as String,
      price: o['price']?.toString() ?? '0',
      origQty: o['origQty']?.toString() ?? '0',
      executedQty: o['executedQty']?.toString() ?? '0',
      status: o['status'] as String,
      time: o['time'] as int,
      updateTime: o['updateTime'] as int,
      isIsolated: o['isIsolated'] as bool? ?? false,
    )).toList();
  }

  Future<List<BinanceFuturesBalance>> getFuturesBalances(String credentialId) async {
    final response = await _dio.get(
      '/binance-proxy/futures/balance',
      queryParameters: {'credentialId': credentialId},
    );
    final List<dynamic> items = response.data['data'] ?? response.data ?? [];
    return items.map((b) => BinanceFuturesBalance(
      asset: b['asset'] as String,
      walletBalance: b['walletBalance'] as String,
      unrealizedProfit: b['unrealizedProfit'] as String,
      availableBalance: b['availableBalance'] as String,
    )).toList();
  }

  Future<List<BinanceFuturesPosition>> getFuturesPositions(String credentialId) async {
    final response = await _dio.get(
      '/binance-proxy/futures/positions',
      queryParameters: {'credentialId': credentialId},
    );
    final List<dynamic> items = response.data['data'] ?? response.data ?? [];
    return items.map((p) => BinanceFuturesPosition(
      symbol: p['symbol'] as String,
      positionSide: p['positionSide'] as String,
      positionAmt: p['positionAmt'] as String,
      entryPrice: p['entryPrice'] as String,
      markPrice: p['markPrice'] as String,
      unrealizedPnL: p['unrealizedPnL'] as String,
      marginType: p['marginType'] as String,
      isolatedMargin: p['isolatedMargin'] as String,
      leverage: p['leverage'] as String,
    )).toList();
  }

  BinanceCredentials _parseCredential(Map<String, dynamic> item) {
    return BinanceCredentials(
      id: item['id'] as String,
      label: item['label'] as String?,
      permissions: (item['permissions'] as List<dynamic>?)
          ?.map((p) => (p as String).toUpperCase() == 'FUTURES'
              ? BinancePermission.futures
              : BinancePermission.spot)
          .toList() ?? [BinancePermission.spot],
      testnet: item['testnet'] as bool? ?? false,
      isActive: item['is_active'] as bool? ?? true,
      lastUsedAt: item['last_used_at'] != null
          ? DateTime.tryParse(item['last_used_at'] as String)
          : null,
      createdAt: DateTime.parse(item['created_at'] as String),
    );
  }
}
