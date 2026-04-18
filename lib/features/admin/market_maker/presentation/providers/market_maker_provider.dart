import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/features/admin/market_maker/data/datasources/market_maker_remote_datasource.dart';
import 'package:crypto_trading_app/features/admin/market_maker/data/models/market_maker_config_model.dart';
import 'package:crypto_trading_app/features/admin/market_maker/data/models/market_maker_form_defaults_model.dart';

class MarketMakerProvider extends ChangeNotifier {
  final MarketMakerRemoteDataSource _dataSource;

  MarketMakerProvider({required MarketMakerRemoteDataSource dataSource})
      : _dataSource = dataSource;

  List<MarketMakerConfigModel> _configs = [];
  List<MarketMakerPairOption> _pairs = [];
  MarketMakerFormDefaultsModel? _formDefaults;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  List<MarketMakerConfigModel> get configs => _configs;
  List<MarketMakerPairOption> get pairs => _pairs;
  MarketMakerFormDefaultsModel? get formDefaults => _formDefaults;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  MarketMakerConfigModel? configByPairId(String pairId) {
    for (final item in _configs) {
      if (item.pairId == pairId) return item;
    }
    return null;
  }

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await Future.wait([
        _dataSource.getActivePairs(),
        _dataSource.listConfigs(),
      ]);
      _pairs = result[0] as List<MarketMakerPairOption>;
      _configs = result[1] as List<MarketMakerConfigModel>;
      try {
        _formDefaults = await _dataSource.getFormDefaults();
      } catch (_) {
        _formDefaults = null;
      }
    } catch (e) {
      _error = e.toString();
      _formDefaults = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> upsertConfig(
    String pairId,
    Map<String, dynamic> payload,
  ) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _dataSource.upsertConfig(pairId, payload);
      final idx = _configs.indexWhere((item) => item.pairId == pairId);
      if (idx >= 0) {
        _configs[idx] = updated;
      } else {
        _configs = [updated, ..._configs];
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteConfig(String pairId) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _dataSource.deleteConfig(pairId);
      _configs = _configs.where((item) => item.pairId != pairId).toList();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> placeMakerOrders(
    String pairId, {
    String? orderAmountOverride,
    String? refreshCycleKey,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      return await _dataSource.placeMakerOrders(
        pairId,
        orderAmountOverride: orderAmountOverride,
        refreshCycleKey: refreshCycleKey,
      );
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
