import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _localeKey = 'app_locale';

/// Holds current [Locale] and persists choice via SharedPreferences.
/// Best practice: locale lives on FE; BE returns error codes, FE maps to localized strings.
class LocaleProvider extends ChangeNotifier {
  LocaleProvider(this._prefs) : _locale = _localeFromCode(_prefs.getString(_localeKey)) {}

  final SharedPreferences _prefs;
  Locale _locale;

  Locale get locale => _locale;

  static Locale _localeFromCode(String? code) {
    if (code == null) return const Locale('en');
    if (code == 'vi') return const Locale('vi');
    return const Locale('en');
  }

  static String _codeFromLocale(Locale l) {
    if (l.languageCode == 'vi') return 'vi';
    return 'en';
  }

  Future<void> setLocale(Locale value) async {
    if (_locale == value) return;
    _locale = value;
    await _prefs.setString(_localeKey, _codeFromLocale(value));
    notifyListeners();
  }

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('vi'),
  ];
}
