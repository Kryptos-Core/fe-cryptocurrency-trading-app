import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/utils/stale_query_policy.dart';
import 'package:crypto_trading_app/data/repositories/system_config_repository.dart';
import 'package:crypto_trading_app/domain/models/runtime_setting_row.dart';

class RuntimeSettingsProvider extends ChangeNotifier {
  RuntimeSettingsProvider({required SystemConfigRepository repository})
      : _repository = repository;

  final SystemConfigRepository _repository;

  List<RuntimeSettingRow> _rows = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  DateTime? _runtimeFetchedAt;

  List<RuntimeSettingRow> get rows => _rows;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  Future<void> load({bool force = false}) async {
    if (!force && isStaleQueryFresh(_runtimeFetchedAt) && _error == null) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _rows = await _repository.getRuntimeSettings();
      _runtimeFetchedAt = DateTime.now();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveAll(Map<String, String> updates) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.patchRuntimeBulk(updates);
      await load(force: true);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
