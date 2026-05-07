import 'package:crypto_trading_app/features/settings/domain/models/runtime_setting_row.dart';
import 'package:crypto_trading_app/features/settings/domain/models/system_config.dart';

/// Persistent + runtime system configuration (Nest `/system-configs`).
abstract class SystemConfigRepository {
  Future<List<SystemConfig>> getAllConfigs();

  Future<List<RuntimeSettingRow>> getRuntimeSettings({String? category});

  Future<void> patchRuntimeBulk(Map<String, String> updates, {String? category});

  Future<SystemConfig> updateConfig(String key, String value);
}
