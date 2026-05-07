import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/core/utils/stale_query_policy.dart';
import 'package:crypto_trading_app/features/settings/domain/repositories/system_config_repository.dart';
import 'package:crypto_trading_app/features/settings/domain/models/runtime_setting_row.dart';

class RuntimeSettingsProvider extends ChangeNotifier {
  RuntimeSettingsProvider({required SystemConfigRepository repository})
      : _repository = repository;

  final SystemConfigRepository _repository;

  /// Per-category rows (keyed by ConfigCategory name).
  final Map<String, List<RuntimeSettingRow>> _rowsByCategory = {};
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  DateTime? _runtimeFetchedAt;

  List<RuntimeSettingRow> rowsFor(String category) => _rowsByCategory[category] ?? [];
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  Future<void> load({required String category, bool force = false}) async {
    if (!force &&
        isStaleQueryFresh(_runtimeFetchedAt) &&
        _error == null &&
        _rowsByCategory.containsKey(category)) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final rows = await _repository.getRuntimeSettings(category: category);
      _rowsByCategory[category] = rows;
      _runtimeFetchedAt = DateTime.now();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveAll(Map<String, String> updates, {required String category}) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.patchRuntimeBulk(updates, category: category);
      await load(category: category, force: true);
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
