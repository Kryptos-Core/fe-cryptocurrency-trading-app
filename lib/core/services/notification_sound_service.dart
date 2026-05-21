import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wav_generator.dart';

/// Maps notification types to WAV tone parameters.
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
        return 'sounds/withdrawal_request.mp3';
      case NotificationSoundType.withdrawalApproved:
        return 'sounds/withdrawal_approved.mp3';
      case NotificationSoundType.withdrawalRejected:
        return 'sounds/withdrawal_rejected.mp3';
      case NotificationSoundType.alert:
        return 'sounds/alert.mp3';
      case NotificationSoundType.promo:
        return 'sounds/promo.mp3';
      case NotificationSoundType.systemDefault:
        return 'sounds/system_default.mp3';
    }
  }

  String get settingsKey => 'notification_sound_$name';
}

class NotificationSoundSetting {
  final NotificationSoundType type;
  final String assetPath;
  final bool enabled;

  const NotificationSoundSetting({
    required this.type,
    required this.assetPath,
    this.enabled = true,
  });

  NotificationSoundSetting copyWith({bool? enabled}) {
    return NotificationSoundSetting(
      type: type,
      assetPath: assetPath,
      enabled: enabled ?? this.enabled,
    );
  }
}

/// WAV tone preset — defines pitch, length, and volume for each notification type.
class _WavPreset {
  final double frequency;
  final int durationMs;
  final double volume;

  const _WavPreset({
    required this.frequency,
    required this.durationMs,
    this.volume = 0.5,
  });
}

extension _WavPresetFor on NotificationSoundType {
  _WavPreset get wavPreset {
    switch (this) {
      case NotificationSoundType.systemDefault:
        return const _WavPreset(frequency: 880, durationMs: 150, volume: 0.4);
      case NotificationSoundType.withdrawalRequest:
        return const _WavPreset(frequency: 660, durationMs: 200, volume: 0.5);
      case NotificationSoundType.withdrawalApproved:
        return const _WavPreset(frequency: 1047, durationMs: 300, volume: 0.5);
      case NotificationSoundType.withdrawalRejected:
        return const _WavPreset(frequency: 220, durationMs: 400, volume: 0.5);
      case NotificationSoundType.alert:
        return const _WavPreset(frequency: 1320, durationMs: 250, volume: 0.6);
      case NotificationSoundType.promo:
        return const _WavPreset(frequency: 1760, durationMs: 200, volume: 0.4);
    }
  }
}

/// Global service for playing notification sounds.
///
/// Attempts, in order:
///  1. Flutter asset file (when shipped with the app)
///  2. Programmatic WAV tone (pure Dart, works in all contexts)
class NotificationSoundService {
  static NotificationSoundService? _instance;

  factory NotificationSoundService() {
    _instance ??= NotificationSoundService._internal();
    return _instance!;
  }

  static NotificationSoundService get instance => NotificationSoundService();

  NotificationSoundService._internal();

  bool _isDisposing = false;
  final Map<NotificationSoundType, NotificationSoundSetting> _settings = {};
  bool _globallyEnabled = true;
  bool _initialized = false;

  bool get globallyEnabled => _globallyEnabled;
  Map<NotificationSoundType, NotificationSoundSetting> get settings =>
      Map.unmodifiable(_settings);

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();

    for (final type in NotificationSoundType.values) {
      final key = type.settingsKey;
      final enabled = prefs.getBool(key) ?? true;
      _settings[type] = NotificationSoundSetting(
        type: type,
        assetPath: type.assetPath,
        enabled: enabled,
      );
    }

    _globallyEnabled =
        prefs.getBool('notification_sound_globally_enabled') ?? true;
  }

  /// Resolves the flutter_assets absolute path.
  String _resolveFlutterAssetPath(String relativePath) {
    final execDir = File(Platform.resolvedExecutable).parent.path;
    final assetDir = '$execDir\\data\\flutter_assets';
    return '$assetDir\\$relativePath'.replaceAll('/', '\\');
  }

  Future<void> _safePlay(NotificationSoundType type) async {
    if (_isDisposing) return;
    if (!(_settings[type]?.enabled ?? false)) return;
    if (!_globallyEnabled) return;

    try {
      debugPrint('[NotificationSound] Playing: $type');

      // 1. Try Flutter asset first (bundled MP3/WAV sounds).
      if (Platform.isWindows) {
        final flutterPath = _resolveFlutterAssetPath(type.assetPath);
        final flutterFile = File(flutterPath);

        if (await flutterFile.exists()) {
          debugPrint('[NotificationSound] Found asset: $flutterPath');
          await _playWavFile(flutterPath);
          return;
        }
      }

      // 2. Fallback: generate and play a WAV tone (pure Dart + Python WinMM).
      debugPrint('[NotificationSound] Generating WAV tone for: $type');
      await _playWavTone(type);
    } catch (e, stack) {
      debugPrint('[NotificationSound] Play failed for "$type": $e\n$stack');
    }
  }

  /// Plays a WAV file by calling a Python script that uses WinMM waveOut API.
  /// This approach uses ctypes/WinDLL to bypass all .NET/Flutter audio stack issues.
  Future<void> _playWavFile(String absPath) async {
    try {
      // Find python3 in PATH
      final pythonCmd = _findPython();
      if (pythonCmd == null) {
        debugPrint('[NotificationSound] Python not found in PATH');
        return;
      }

      final scriptPath = _resolvePythonScriptPath();
      final scriptFile = File(scriptPath);
      if (!await scriptFile.exists()) {
        debugPrint('[NotificationSound] Python script not found: $scriptPath');
        return;
      }

      debugPrint('[NotificationSound] WinMM playing: $absPath');

      final result = await Process.run(
        pythonCmd,
        [scriptPath, absPath],
      );

      final stdout = result.stdout.toString().trim();
      final stderr = result.stderr.toString().trim();

      if (stdout.contains('OK')) {
        debugPrint('[NotificationSound] WinMM: played OK');
      } else if (stdout.contains('NO_DEVICE')) {
        debugPrint('[NotificationSound] WinMM: no audio device');
      } else if (stdout.startsWith('OPEN_ERR') ||
          stdout.startsWith('WAV_OPEN_ERR') ||
          stdout.startsWith('PREP_ERR') ||
          stdout.startsWith('WRITE_ERR')) {
        debugPrint('[NotificationSound] WinMM error: $stdout');
      } else if (stderr.isNotEmpty) {
        debugPrint('[NotificationSound] WinMM stderr: $stderr');
      }
    } catch (e) {
      debugPrint('[NotificationSound] WinMM failed: $e');
    }
  }

  String? _findPython() {
    final candidates = [
      'python',
      'python3',
      'py',
      'C:\\Python312\\python.exe',
      'C:\\Python311\\python.exe',
      'C:\\Python310\\python.exe',
      'C:\\Program Files\\Python312\\python.exe',
      'C:\\Program Files\\Python311\\python.exe',
    ];
    for (final cmd in candidates) {
      try {
        final r = Process.runSync(cmd, ['--version'], runInShell: true);
        if (r.exitCode == 0) {
          debugPrint('[NotificationSound] Using Python: $cmd');
          return cmd;
        }
      } catch (_) {}
    }
    return null;
  }

  String _resolvePythonScriptPath() {
    final execDir = File(Platform.resolvedExecutable).parent.path;
    return '$execDir\\data\\flutter_assets\\scripts\\winmm_player.py';
  }

  /// Generates a WAV tone in Dart and plays it via Python WinMM.
  Future<void> _playWavTone(NotificationSoundType type) async {
    final preset = type.wavPreset;
    final wavBytes = WavToneGenerator.buildWav(
      frequency: preset.frequency,
      durationMs: preset.durationMs,
      volume: preset.volume,
    );

    final tempDir = Directory.systemTemp;
    final wavFile = File(
      '${tempDir.path}\\crypto_ntf_${DateTime.now().millisecondsSinceEpoch}.wav',
    );

    await wavFile.writeAsBytes(wavBytes);
    debugPrint('[NotificationSound] WAV written: ${wavFile.path}');

    await _playWavFile(wavFile.path);

    // Clean up temp WAV.
    try {
      await wavFile.delete();
    } catch (_) {}
  }

  Future<void> playForNotificationType(String backendType) async {
    final soundType = _mapBackendType(backendType);
    await _safePlay(soundType);
  }

  Future<void> playForSoundType(NotificationSoundType soundType) async {
    await _safePlay(soundType);
  }

  Future<void> setEnabled(NotificationSoundType type, bool enabled) async {
    _settings[type] = NotificationSoundSetting(
      type: type,
      assetPath: type.assetPath,
      enabled: enabled,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(type.settingsKey, enabled);
  }

  Future<void> setGloballyEnabled(bool enabled) async {
    _globallyEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_sound_globally_enabled', enabled);
  }

  Future<void> toggleMute() async {
    await setGloballyEnabled(!_globallyEnabled);
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

  Future<void> dispose() async {
    _isDisposing = true;
    _initialized = false;
    _isDisposing = false;
  }
}
