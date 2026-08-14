import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';

/// Wires WebSocket events to the HTTP cache layer.
///
/// On each realtime signal we drop the matching cache prefix so the next
/// REST request forced by user interaction hits a fresh BE response.
/// Without this, the SWR cache could keep showing stale data until the TTL
/// expires (5–60s depending on endpoint).
class CacheInvalidator {
  CacheInvalidator({DioClient? client}) : _client = client ?? DioClient.instance;

  static const _prefixWallets = 'GET /api/v1/wallets';
  static const _prefixUsersMe = 'GET /api/v1/users/me';
  static const _prefixOrders = 'GET /api/v1/orders/my';
  static const _prefixDashboard = 'GET /api/v1/dashboard';

  final DioClient _client;

  /// Wire to [NotificationsSocketService]'s wallet:balance stream.
  StreamSubscription<dynamic>? _walletSub;

  /// Wire to the trading namespace order update stream.
  StreamSubscription<dynamic>? _orderSub;

  /// Wire to the user profile WS channel (e.g. settings change broadcast).
  StreamSubscription<dynamic>? _userSub;

  void bindWalletStream(Stream<dynamic> stream) {
    _walletSub?.cancel();
    _walletSub = stream.listen((_) => invalidateWallets());
  }

  void bindOrderStream(Stream<dynamic> stream) {
    _orderSub?.cancel();
    _orderSub = stream.listen((_) => invalidateOrders());
  }

  void bindUserStream(Stream<dynamic> stream) {
    _userSub?.cancel();
    _userSub = stream.listen((_) => invalidateUsersMe());
  }

  Future<int> invalidateWallets() async {
    final interceptor = _client.apiCacheInterceptor;
    if (interceptor == null) return 0;
    final count = await interceptor.invalidatePrefix(_prefixWallets);
    if (kDebugMode) debugPrint('[CacheInvalidator] wallets flushed=$count');
    return count;
  }

  Future<int> invalidateOrders() async {
    final interceptor = _client.apiCacheInterceptor;
    if (interceptor == null) return 0;
    final count = await interceptor.invalidatePrefix(_prefixOrders);
    if (kDebugMode) debugPrint('[CacheInvalidator] orders flushed=$count');
    return count;
  }

  Future<int> invalidateUsersMe() async {
    final interceptor = _client.apiCacheInterceptor;
    if (interceptor == null) return 0;
    final count = await interceptor.invalidatePrefix(_prefixUsersMe);
    if (kDebugMode) debugPrint('[CacheInvalidator] users/me flushed=$count');
    return count;
  }

  Future<int> invalidateDashboard() async {
    final interceptor = _client.apiCacheInterceptor;
    if (interceptor == null) return 0;
    final count = await interceptor.invalidatePrefix(_prefixDashboard);
    if (kDebugMode) debugPrint('[CacheInvalidator] dashboard flushed=$count');
    return count;
  }

  Future<void> dispose() async {
    await _walletSub?.cancel();
    await _orderSub?.cancel();
    await _userSub?.cancel();
  }
}
