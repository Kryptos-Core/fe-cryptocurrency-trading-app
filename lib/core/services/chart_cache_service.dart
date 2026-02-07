import 'package:crypto_trading_app/core/services/websocket_service.dart';

/// Cache key: "pairId_interval" (e.g. "1_1m")
String _cacheKey(int pairId, String interval) => '${pairId}_$interval';

/// Max candles to keep per (pairId, interval).
/// ~1 month: 1m = 43200, 1h = 720, 1d = 31. Use single cap for simplicity.
const int _maxCandlesPerKey = 43200;

/// Chart cache service – lưu dữ liệu OHLC đã nhận (REST + WebSocket)
/// để mỗi lần vào detail không load từ đầu, giữ tối đa ~1 tháng (43200 nến cho 1m).
/// Singleton, in-memory.
class ChartCacheService {
  final Map<String, List<OHLCData>> _cache = {};

  /// Lấy bản copy danh sách nến đã cache cho (pairId, interval).
  List<OHLCData> getCandles(int pairId, String interval) {
    final key = _cacheKey(pairId, interval);
    final list = _cache[key];
    if (list == null || list.isEmpty) return [];
    return List.from(list);
  }

  /// Ghi/merge danh sách nến vào cache: merge theo openTime, sort tăng dần, giữ tối đa [_maxCandlesPerKey] nến.
  void putCandles(int pairId, String interval, List<OHLCData> candles) {
    if (candles.isEmpty) return;
    final key = _cacheKey(pairId, interval);
    final existing = _cache[key] ?? [];
    final byTime = <int, OHLCData>{};
    for (final c in existing) {
      byTime[c.openTime] = c;
    }
    for (final c in candles) {
      byTime[c.openTime] = c;
    }
    final merged = byTime.values.toList()..sort((a, b) => a.openTime.compareTo(b.openTime));
    final trimmed = merged.length > _maxCandlesPerKey
        ? merged.sublist(merged.length - _maxCandlesPerKey)
        : merged;
    _cache[key] = trimmed;
  }

  /// Xóa cache cho một pair (optional, khi cần giải phóng bộ nhớ).
  void clearPair(int pairId, String interval) {
    _cache.remove(_cacheKey(pairId, interval));
  }

  /// Xóa toàn bộ cache.
  void clearAll() {
    _cache.clear();
  }
}
