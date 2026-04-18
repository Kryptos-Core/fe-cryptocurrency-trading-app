import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pointer for interactive controls (web/desktop); disabled uses [SystemMouseCursors.basic].
MouseCursor _clickOrBasic(Set<WidgetState> states) {
  if (states.contains(WidgetState.disabled)) {
    return SystemMouseCursors.basic;
  }
  return SystemMouseCursors.click;
}

final WidgetStateProperty<MouseCursor> _clickCursor =
    WidgetStateProperty.resolveWith(_clickOrBasic);

const String _seedColorKey = 'app_seed_color';
const String _themeModeKey = 'app_theme_mode';

/// Preset seed colors — each generates a full Material 3 color scheme via
/// [ColorScheme.fromSeed], which applies the HCT color space algorithm used
/// by Material You to produce 40+ harmonious tonal roles automatically.
typedef Preset = ({String name, Color seed});

/// Manages app-wide [ThemeMode] and seed [Color], persisting choices via
/// SharedPreferences.  Follows the same ChangeNotifier + SharedPreferences
/// pattern used by [LocaleProvider].
class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._prefs)
      : _seedColor = _colorFromInt(_prefs.getInt(_seedColorKey)),
        _themeMode = _modeFromString(_prefs.getString(_themeModeKey));

  final SharedPreferences _prefs;
  Color _seedColor;
  ThemeMode _themeMode;

  // ── Public getters ──────────────────────────────────────────────────────

  Color get seedColor => _seedColor;
  ThemeMode get themeMode => _themeMode;

  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
        scrollbarTheme: const ScrollbarThemeData(
          thumbVisibility: WidgetStatePropertyAll(false),
          trackVisibility: WidgetStatePropertyAll(false),
          thickness: WidgetStatePropertyAll(0.0),
          crossAxisMargin: 0,
          mainAxisMargin: 0,
        ),
      ).copyWith(
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(mouseCursor: _clickCursor),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(mouseCursor: _clickCursor),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(mouseCursor: _clickCursor),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(mouseCursor: _clickCursor),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(mouseCursor: _clickCursor),
        ),
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        scrollbarTheme: const ScrollbarThemeData(
          thumbVisibility: WidgetStatePropertyAll(false),
          trackVisibility: WidgetStatePropertyAll(false),
          thickness: WidgetStatePropertyAll(0.0),
          crossAxisMargin: 0,
          mainAxisMargin: 0,
        ),
      ).copyWith(
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(mouseCursor: _clickCursor),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(mouseCursor: _clickCursor),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(mouseCursor: _clickCursor),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(mouseCursor: _clickCursor),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(mouseCursor: _clickCursor),
        ),
      );

  // ── Preset palette ──────────────────────────────────────────────────────

  /// 8 curated seed colors — picked to span the hue wheel evenly so every
  /// generated palette is visually distinct and aesthetically balanced.
  static const List<Preset> presetSeeds = [
    (name: 'Chàm',       seed: Color(0xFF3F51B5)),
    (name: 'Tím',        seed: Color(0xFF9C27B0)),
    (name: 'Xanh dương', seed: Color(0xFF2196F3)),
    (name: 'Xanh ngọc',  seed: Color(0xFF009688)),
    (name: 'Xanh lá',   seed: Color(0xFF4CAF50)),
    (name: 'Cam',        seed: Color(0xFFFF9800)),
    (name: 'Đỏ',         seed: Color(0xFFF44336)),
    (name: 'Nâu',        seed: Color(0xFF795548)),
  ];

  // ── Setters ─────────────────────────────────────────────────────────────

  Future<void> setSeedColor(Color color) async {
    if (_seedColor.toARGB32() == color.toARGB32()) return;
    _seedColor = color;
    await _prefs.setInt(_seedColorKey, color.toARGB32());
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _prefs.setString(_themeModeKey, _stringFromMode(mode));
    notifyListeners();
  }

  // ── Private helpers ─────────────────────────────────────────────────────

  static Color _colorFromInt(int? value) {
    if (value == null) return presetSeeds.first.seed;
    return Color(value);
  }

  static ThemeMode _modeFromString(String? value) {
    switch (value) {
      case 'light':  return ThemeMode.light;
      case 'dark':   return ThemeMode.dark;
      default:       return ThemeMode.system;
    }
  }

  static String _stringFromMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:  return 'light';
      case ThemeMode.dark:   return 'dark';
      case ThemeMode.system: return 'system';
    }
  }
}
