enum ConfigCategory {
  tech,
  finance,
  core,
}

class SystemConfig {
  final String key;
  final String value;
  final String type;
  final ConfigCategory category;
  final String name;
  final String? description;
  final bool isReadOnly;

  SystemConfig({
    required this.key,
    required this.value,
    required this.type,
    required this.category,
    required this.name,
    this.description,
    this.isReadOnly = false,
  });

  factory SystemConfig.fromJson(Map<String, dynamic> json) {
    return SystemConfig(
      key: json['key'] ?? '',
      value: json['value'] ?? '',
      type: json['type'] ?? 'string',
      category: _parseCategory(json['category']),
      name: json['name'] ?? '',
      description: json['description'],
      isReadOnly: json['isReadOnly'] ?? false,
    );
  }

  static ConfigCategory _parseCategory(String? cat) {
    if (cat == 'tech') return ConfigCategory.tech;
    if (cat == 'finance') return ConfigCategory.finance;
    return ConfigCategory.core;
  }
}
