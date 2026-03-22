import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_trading_app/data/models/currency_model.dart';

/// Lightweight refs for recent / favorite wallet currencies.
class CurrencyRef {
  final String currencyId;
  final String symbol;

  const CurrencyRef({required this.currencyId, required this.symbol});

  Map<String, dynamic> toJson() =>
      {'currencyId': currencyId, 'symbol': symbol};

  static CurrencyRef? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final id = json['currencyId'] as String?;
    final sym = json['symbol'] as String?;
    if (id == null || sym == null) return null;
    return CurrencyRef(currencyId: id, symbol: sym);
  }
}

/// Persists recent selections and favorites for the wallet currency picker.
class CurrencyBookmarkStore {
  CurrencyBookmarkStore([SharedPreferences? prefs]) : _prefs = prefs;

  final SharedPreferences? _prefs;
  static const _recentKey = 'wallet_currency_recent_v1';
  static const _favoritesKey = 'wallet_currency_favorites_v1';
  static const _maxItems = 10;

  final List<CurrencyRef> _memRecent = [];
  final List<CurrencyRef> _memFavorites = [];

  List<CurrencyRef> get recent {
    if (_prefs == null) return List.unmodifiable(_memRecent);
    final raw = _prefs!.getString(_recentKey);
    return _decodeList(raw);
  }

  List<CurrencyRef> get favorites {
    if (_prefs == null) return List.unmodifiable(_memFavorites);
    final raw = _prefs!.getString(_favoritesKey);
    return _decodeList(raw);
  }

  bool isFavorite(String currencyId) {
    return favorites.any((e) => e.currencyId == currencyId);
  }

  List<CurrencyRef> _decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => CurrencyRef.fromJson(e as Map<String, dynamic>?))
          .whereType<CurrencyRef>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeRecent(List<CurrencyRef> items) async {
    if (_prefs == null) {
      _memRecent
        ..clear()
        ..addAll(items);
      return;
    }
    await _prefs!.setString(
      _recentKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _writeFavorites(List<CurrencyRef> items) async {
    if (_prefs == null) {
      _memFavorites
        ..clear()
        ..addAll(items);
      return;
    }
    await _prefs!.setString(
      _favoritesKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  /// Most-recent first, capped at [_maxItems].
  Future<void> addRecent(CurrencyModel currency) async {
    final next = [
      CurrencyRef(currencyId: currency.currencyId, symbol: currency.symbol),
      ...recent.where((e) => e.currencyId != currency.currencyId),
    ].take(_maxItems).toList();
    await _writeRecent(next);
  }

  Future<void> removeRecent(String currencyId) async {
    final next =
        recent.where((e) => e.currencyId != currencyId).toList();
    await _writeRecent(next);
  }

  Future<void> toggleFavorite(CurrencyModel currency) async {
    final ref =
        CurrencyRef(currencyId: currency.currencyId, symbol: currency.symbol);
    final current = List<CurrencyRef>.from(favorites);
    final idx = current.indexWhere((e) => e.currencyId == currency.currencyId);
    if (idx >= 0) {
      current.removeAt(idx);
    } else {
      current.insert(0, ref);
      while (current.length > _maxItems) {
        current.removeLast();
      }
    }
    await _writeFavorites(current);
  }
}
