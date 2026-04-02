import 'package:flutter/material.dart';
import '../../domain/models/system_config.dart';
import '../../data/repositories/system_config_repository.dart';
import '../../core/services/notifications_socket_service.dart';

class SystemConfigProvider with ChangeNotifier {
  final SystemConfigRepository _repository;
  final NotificationsSocketService? _socketService;

  List<SystemConfig> _configs = [];
  bool _isLoading = false;
  String? _error;

  SystemConfigProvider({
    required SystemConfigRepository repository,
    NotificationsSocketService? socketService,
  })  : _repository = repository,
        _socketService = socketService {
    _initSocket();
  }

  List<SystemConfig> get configs => _configs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String getConfigValue(String key, {String defaultValue = ''}) {
    try {
      final config = _configs.firstWhere((c) => c.key == key);
      return config.value;
    } catch (_) {
      return defaultValue;
    }
  }

  Future<void> loadConfigs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _configs = await _repository.getAllConfigs();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateConfig(String key, String value) async {
    try {
      final updatedConfig = await _repository.updateConfig(key, value);
      final index = _configs.indexWhere((c) => c.key == key);
      if (index != -1) {
        _configs[index] = updatedConfig;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Update failed: $e');
    }
  }

  void _initSocket() {
    if (_socketService == null) return;
    _socketService!.messageStream.listen((message) {
      if (message.type == 'system_config:updated') {
        final payload = message.data;
        final updatedKey = payload['key'];
        final updatedValue = payload['value'];

        final index = _configs.indexWhere((c) => c.key == updatedKey);
        if (index != -1) {
          final oldConfig = _configs[index];
          _configs[index] = SystemConfig(
            key: oldConfig.key,
            value: updatedValue,
            type: oldConfig.type,
            category: oldConfig.category,
            name: oldConfig.name,
            description: oldConfig.description,
            isReadOnly: oldConfig.isReadOnly,
          );
          notifyListeners();
          debugPrint('Real-time config update: $updatedKey -> $updatedValue');
        } else {
          // New config or not loaded yet, just reload all
          loadConfigs();
        }
      }
    });
  }
}
