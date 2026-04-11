import 'dart:convert';

import 'package:crypto_trading_app/data/models/chain_picker_options_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists last successful [GET /treasury/chain-picker-options] payload so
/// chain pickers stay server-aligned when the network request fails.
class ChainPickerOptionsCache {
  ChainPickerOptionsCache(this._prefs);

  final SharedPreferences _prefs;

  static const storageKey = 'chain_picker_options_v1';

  ChainPickerOptionsModel? readSync() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return ChainPickerOptionsModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(ChainPickerOptionsModel model) async {
    await _prefs.setString(storageKey, jsonEncode(model.toJson()));
  }
}
