import 'system_config.dart';

/// One row from GET /system-configs/runtime (admin UI).
class RuntimeSettingRow {
  final String key;
  final String value;
  final String effectiveValue;
  final String valueSource;
  final String type;
  final ConfigCategory category;
  final String name;
  final String? description;
  final bool isReadOnly;

  RuntimeSettingRow({
    required this.key,
    required this.value,
    required this.effectiveValue,
    required this.valueSource,
    required this.type,
    required this.category,
    required this.name,
    this.description,
    required this.isReadOnly,
  });

  factory RuntimeSettingRow.fromJson(Map<String, dynamic> json) {
    return RuntimeSettingRow(
      key: json['key'] as String? ?? '',
      value: json['value'] as String? ?? '',
      effectiveValue: json['effectiveValue'] as String? ?? json['value'] as String? ?? '',
      valueSource: json['valueSource'] as String? ?? 'database',
      type: json['type'] as String? ?? 'string',
      category: _parseCategory(json['category'] as String?),
      name: json['name'] as String? ?? json['key'] as String? ?? '',
      description: json['description'] as String?,
      isReadOnly: json['isReadOnly'] as bool? ?? false,
    );
  }

  static ConfigCategory _parseCategory(String? cat) {
    if (cat == 'tech') return ConfigCategory.tech;
    if (cat == 'finance') return ConfigCategory.finance;
    if (cat == 'ops') return ConfigCategory.ops;
    return ConfigCategory.core;
  }
}
