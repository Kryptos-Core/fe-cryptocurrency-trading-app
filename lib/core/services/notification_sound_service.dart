import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Maps notification types to audio asset paths
enum NotificationSoundType {
  systemDefault,
  withdrawalRequest,
  withdrawalApproved,
  withdrawalRejected,
  alert,
  promo,
}

extension NotificationSoundTypeX on NotificationSoundType {
  String get assetPath {
    switch (this) {
      case NotificationSoundType.withdrawalRequest:
        return 'assets/sounds/withdrawal_request.mp3';
      case NotificationSoundType.withdrawalApproved:
        return 'assets/sounds/withdrawal_approved.mp3';
      case NotificationSoundType.withdrawalRejected:
        return 'assets/sounds/withdrawal_rejected.mp3';
      case NotificationSoundType.alert:
        return 'assets/sounds/alert.mp3';
      case NotificationSoundType.promo:
        return 'assets/sounds/promo.mp3';
      case NotificationSoundType.systemDefault:
        return 'assets/sounds/system_default.mp3';
    }
  }
}

/// Per-type sound setting stored in SharedPreferences
class NotificationSoundSetting {
  final NotificationSoundType type;
  final String assetPath;
  final bool enabled;

  const NotificationSoundSetting({
    required this.type,
    required this.assetPath,
    this.enabled = true,
  });
}

/// Global service for playing notification sounds.
/// Uses a single AudioPlayer instance to avoid resource contention.
class NotificationSoundService {
  static final NotificationSoundService _instance = NotificationSoundService._();
  static NotificationSoundService get instance => _instance;

  NotificationSoundService._();

  final AudioPlayer _player = AudioPlayer();
  final Map<NotificationSoundType, NotificationSoundSetting> _settings = {};
  bool _globallyEnabled = true;

  bool get globallyEnabled => _globallyEnabled;
  Map<NotificationSoundType, NotificationSoundSetting> get settings =>
      Map.unmodifiable(_settings);

  /// Initialize defaults. Call once at app startup.
  void initialize() {
    for (final type in NotificationSoundType.values) {
      _settings[type] = NotificationSoundSetting(
        type: type,
        assetPath: type.assetPath,
        enabled: true,
      );
    }
  }

  /// Play sound for a given notification type string (matches backend type).
  Future<void> playForNotificationType(String backendType) async {
    if (!_globallyEnabled) return;

    final soundType = _mapBackendType(backendType);
    final setting = _settings[soundType];
    if (setting == null || !setting.enabled) return;

    try {
      await _player.play(AssetSource(setting.assetPath.replaceFirst('assets/', '')));
    } catch (e) {
      debugPrint('[NotificationSound] Failed to play ${setting.assetPath}: $e');
    }
  }

  /// Enable/disable a specific notification type sound
  void setEnabled(NotificationSoundType type, bool enabled) {
    _settings[type] = NotificationSoundSetting(
      type: type,
      assetPath: type.assetPath,
      enabled: enabled,
    );
  }

  /// Enable/disable all notification sounds
  void setGloballyEnabled(bool enabled) {
    _globallyEnabled = enabled;
  }

  /// Toggle mute/unmute (shortcut for globallyEnabled)
  void toggleMute() {
    _globallyEnabled = !_globallyEnabled;
  }

  NotificationSoundType _mapBackendType(String backendType) {
    switch (backendType) {
      case 'withdrawal_request':
        return NotificationSoundType.withdrawalRequest;
      case 'withdrawal_approved':
        return NotificationSoundType.withdrawalApproved;
      case 'withdrawal_rejected':
        return NotificationSoundType.withdrawalRejected;
      case 'alert':
        return NotificationSoundType.alert;
      case 'promo':
        return NotificationSoundType.promo;
      default:
        return NotificationSoundType.systemDefault;
    }
  }

  void dispose() {
    _player.dispose();
  }
}
