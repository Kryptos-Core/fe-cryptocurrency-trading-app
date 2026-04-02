import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/utils/stale_query_policy.dart';
import 'package:crypto_trading_app/data/datasources/payment_config_remote_datasource.dart';
import 'package:crypto_trading_app/data/models/payment_method_config_model.dart';

/// PaymentConfigProvider
/// Manages payment method config state and real-time update events.
///
/// WebSocket event flow:
///  TRANSITIONING → show grace-period banner in deposit screens
///  ACTIVATED     → dismiss banner, refresh QR/addresses
///  DEACTIVATED   → refresh config list
class PaymentConfigProvider extends ChangeNotifier {
  final PaymentConfigRemoteDataSource _dataSource;

  PaymentConfigProvider({required PaymentConfigRemoteDataSource dataSource})
      : _dataSource = dataSource;

  List<PaymentMethodConfigModel> _configs = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  DateTime? _configsFetchedAt;

  /// Latest payment config event received via WebSocket.
  PaymentConfigEvent? _latestEvent;

  /// True when any config is in TRANSITIONING state.
  bool get isAnyTransitioning =>
      _configs.any((c) => c.isTransitioning) ||
      (_latestEvent?.event == 'TRANSITIONING');

  /// Grace period remaining for the most recent TRANSITIONING config.
  int? get transitioningGraceMinsRemaining {
    final transitioning = _configs.where((c) => c.isTransitioning).toList();
    if (transitioning.isEmpty) {
      if (_latestEvent?.event == 'TRANSITIONING') return _latestEvent?.graceMins;
      return null;
    }
    return transitioning.first.graceMinsRemaining;
  }

  /// The type being transitioned (e.g. 'PAYOS', 'TRON') for targeted banners.
  String? get transitioningType => _latestEvent?.event == 'TRANSITIONING'
      ? _latestEvent!.type
      : _configs
            .where((c) => c.isTransitioning)
            .map((c) => c.type)
            .firstOrNull;

  List<PaymentMethodConfigModel> get configs => _configs;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  PaymentConfigEvent? get latestEvent => _latestEvent;

  // ── Data loading ─────────────────────────────────────────────────────────

  /// [force] — true after pull-to-refresh, mutations, or WebSocket (bypass stale window).
  Future<void> loadConfigs({bool force = false}) async {
    if (!force && isStaleQueryFresh(_configsFetchedAt) && _error == null) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _configs = await _dataSource.listConfigs();
      _configsFetchedAt = DateTime.now();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── CRUD ─────────────────────────────────────────────────────────────────

  Future<bool> createConfig({
    required String type,
    required String network,
    required String displayName,
    required Map<String, dynamic> config,
    int? gracePeriodMinutes,
    int? sortOrder,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      final created = await _dataSource.createConfig({
        'type': type,
        'network': network,
        'display_name': displayName,
        'config': config,
        if (gracePeriodMinutes != null) 'grace_period_minutes': gracePeriodMinutes,
        if (sortOrder != null) 'sort_order': sortOrder,
      });
      _configs = [created, ..._configs];
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateConfig(
    String configId, {
    String? displayName,
    Map<String, dynamic>? config,
    int? gracePeriodMinutes,
    int? sortOrder,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await _dataSource.updateConfig(configId, {
        if (displayName != null) 'display_name': displayName,
        if (config != null) 'config': config,
        if (gracePeriodMinutes != null) 'grace_period_minutes': gracePeriodMinutes,
        if (sortOrder != null) 'sort_order': sortOrder,
      });
      _configs = _configs.map((c) => c.configId == configId ? updated : c).toList();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> activateConfig(
    String configId, {
    int? gracePeriodMinutes,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _dataSource.activateConfig(
        configId,
        gracePeriodMinutes: gracePeriodMinutes,
      );
      await loadConfigs(force: true); // Refresh list to show TRANSITIONING state
      return result;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deactivateConfig(String configId) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      await _dataSource.deactivateConfig(configId);
      await loadConfigs(force: true);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ── WebSocket event handling ──────────────────────────────────────────────

  /// Called by MainScreen when `payment_config:event` WebSocket message arrives.
  void handleWebSocketEvent(Map<String, dynamic> data) {
    try {
      _latestEvent = PaymentConfigEvent.fromJson(data);
      // Refresh config list so status chips update immediately
      loadConfigs(force: true);
    } catch (_) {
      // Malformed event — ignore
    }
  }

  /// Clear event after consumers (banners) have processed it.
  void clearLatestEvent() {
    _latestEvent = null;
    notifyListeners();
  }
}
