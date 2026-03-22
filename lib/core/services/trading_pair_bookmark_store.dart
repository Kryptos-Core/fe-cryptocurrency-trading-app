import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';

/// Lightweight refs for recent / favorite pairs (pairId + symbol for display).
class TradingPairRef {
  final String pairId;
  final String symbol;

  const TradingPairRef({required this.pairId, required this.symbol});

  Map<String, dynamic> toJson() => {'pairId': pairId, 'symbol': symbol};

  static TradingPairRef? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final id = json['pairId'] as String?;
    final sym = json['symbol'] as String?;
    if (id == null || sym == null) return null;
    return TradingPairRef(pairId: id, symbol: sym);
  }
}

/// Persists recent selections and favorites. Uses [SharedPreferences] when
/// provided; otherwise keeps data in memory (e.g. tests).
class TradingPairBookmarkStore {
  TradingPairBookmarkStore([SharedPreferences? prefs]) : _prefs = prefs;

  final SharedPreferences? _prefs;
  static const _recentKey = 'trading_pair_recent_v1';
  static const _favoritesKey = 'trading_pair_favorites_v1';
  static const _maxItems = 10;

  final List<TradingPairRef> _memRecent = [];
  final List<TradingPairRef> _memFavorites = [];

  List<TradingPairRef> get recent {
    if (_prefs == null) return List.unmodifiable(_memRecent);
    final raw = _prefs!.getString(_recentKey);
    return _decodeList(raw);
  }

  List<TradingPairRef> get favorites {
    if (_prefs == null) return List.unmodifiable(_memFavorites);
    final raw = _prefs!.getString(_favoritesKey);
    return _decodeList(raw);
  }

  bool isFavorite(String pairId) {
    return favorites.any((e) => e.pairId == pairId);
  }

  List<TradingPairRef> _decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => TradingPairRef.fromJson(e as Map<String, dynamic>?))
          .whereType<TradingPairRef>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeRecent(List<TradingPairRef> items) async {
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

  Future<void> _writeFavorites(List<TradingPairRef> items) async {
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
  Future<void> addRecent(MarketPair pair) async {
    final next = [
      TradingPairRef(pairId: pair.pairId, symbol: pair.symbol),
      ...recent.where((e) => e.pairId != pair.pairId),
    ].take(_maxItems).toList();
    await _writeRecent(next);
  }

  Future<void> toggleFavorite(MarketPair pair) async {
    final ref = TradingPairRef(pairId: pair.pairId, symbol: pair.symbol);
    final current = List<TradingPairRef>.from(favorites);
    final idx = current.indexWhere((e) => e.pairId == pair.pairId);
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
