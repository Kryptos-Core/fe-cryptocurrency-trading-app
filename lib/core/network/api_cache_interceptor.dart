import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_trading_app/core/network/cache_policies.dart';

/// In-memory cache entry persisted to SharedPreferences (best effort).
/// Stores the JSON body, the ETag returned by the BE, and a fetch timestamp.
class _CacheEntry {
  _CacheEntry({
    required this.body,
    required this.etag,
    required this.fetchedAt,
  });

  final Map<String, dynamic> body;
  final String? etag;
  final DateTime fetchedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'body': body,
        'etag': etag,
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  static _CacheEntry? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final body = json['body'];
    final etag = json['etag'] as String?;
    final fetchedAtRaw = json['fetchedAt'] as String?;
    if (body is! Map<String, dynamic> || fetchedAtRaw == null) {
      return null;
    }
    return _CacheEntry(
      body: body,
      etag: etag,
      fetchedAt: DateTime.tryParse(fetchedAtRaw) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// Dio interceptor that adds stale-while-revalidate caching for hot-tab
/// endpoints. The interceptor:
///   1. Matches the request URL against [cacheableEndpointPolicies].
///   2. Returns the cached body synchronously when fresh.
///   3. Returns the cached body and fires a background refetch when stale
///      (only if SWR is enabled for the endpoint).
///   4. Forwards `If-None-Match` when the cached entry has an ETag, allowing
///      the BE to short-circuit with a 304 response.
///   5. Persists the response body + ETag to SharedPreferences for warm
///      starts and offline-friendly re-launches.
class ApiCacheInterceptor extends Interceptor {
  ApiCacheInterceptor({SharedPreferences? prefs}) : _prefsOverride = prefs;

  final SharedPreferences? _prefsOverride;

  static const String _prefsPrefix = 'api_cache_v1::';
  static const String _enabledPrefKey = 'api_cache_v1::enabled';

  // In-memory mirror of SharedPreferences values for hot-path performance.
  final Map<String, _CacheEntry> _memory = <String, _CacheEntry>{};
  final Set<String> _inflight = <String>{};
  bool _enabled = true;

  bool get isEnabled => _enabled;

  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    final prefs = await _getPrefs();
    await prefs.setBool(_enabledPrefKey, enabled);
  }

  Future<SharedPreferences> _getPrefs() async {
    final override = _prefsOverride;
    if (override != null) return override;
    return SharedPreferences.getInstance();
  }

  Future<_CacheEntry?> _readEntry(String key) async {
    final inMem = _memory[key];
    if (inMem != null) return inMem;

    final prefs = await _getPrefs();
    final raw = prefs.getString('$_prefsPrefix$key');
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final entry = _CacheEntry.fromJson(decoded);
      if (entry != null) {
        _memory[key] = entry;
      }
      return entry;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeEntry(String key, _CacheEntry entry) async {
    _memory[key] = entry;
    final prefs = await _getPrefs();
    await prefs.setString('$_prefsPrefix$key', jsonEncode(entry.toJson()));
  }

  /// Manually drop every cache entry whose key starts with [prefix].
  /// Used by the WS-driven invalidator.
  Future<int> invalidatePrefix(String prefix) async {
    final prefs = await _getPrefs();
    final keys = prefs.getKeys().where((k) => k.startsWith('$_prefsPrefix$prefix')).toList();
    for (final fullKey in keys) {
      await prefs.remove(fullKey);
      final cacheKey = fullKey.substring(_prefsPrefix.length);
      _memory.remove(cacheKey);
    }
    if (kDebugMode) {
      debugPrint('[ApiCache] invalidate prefix=$prefix entries=${keys.length}');
    }
    return keys.length;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_enabled) {
      return handler.next(options);
    }
    if (options.method.toUpperCase() != 'GET') {
      return handler.next(options);
    }

    final match = matchEndpointPolicy(
      method: options.method,
      path: options.path,
      queryParameters: options.queryParameters,
    );
    if (match == null) {
      return handler.next(options);
    }

    final cacheKey = match.key;
    final entry = await _readEntry(cacheKey);

    if (entry == null) {
      // No cached entry → forward and let onResponse populate it.
      options.extra['__apiCacheKey__'] = cacheKey;
      return handler.next(options);
    }

    final age = DateTime.now().difference(entry.fetchedAt);
    if (age < match.policy.ttl) {
      // Fresh — short-circuit with cached body.
      if (kDebugMode) {
        debugPrint('[ApiCache] HIT fresh key=$cacheKey age=${age.inMilliseconds}ms');
      }
      return handler.resolve(
        Response<Map<String, dynamic>>(
          requestOptions: options,
          statusCode: 200,
          data: entry.body,
          headers: Headers.fromMap(<String, List<String>>{
            'x-cache': <String>['HIT'],
            if (entry.etag != null) 'etag': <String>[entry.etag!],
          }),
        ),
        true,
      );
    }

    if (match.policy.swr) {
      // Stale but SWR enabled → return cached body, fire background refresh.
      if (kDebugMode) {
        debugPrint('[ApiCache] SWR key=$cacheKey age=${age.inSeconds}s');
      }
      if (entry.etag != null) {
        options.headers['If-None-Match'] = entry.etag;
      }
      options.extra['__apiCacheKey__'] = cacheKey;
      options.extra['__apiCacheSWR__'] = true;
      // Schedule the background refresh — return cached body first.
      unawaited(_backgroundRevalidate(options, cacheKey));
      return handler.resolve(
        Response<Map<String, dynamic>>(
          requestOptions: options,
          statusCode: 200,
          data: entry.body,
          headers: Headers.fromMap(<String, List<String>>{
            'x-cache': <String>['STALE'],
            if (entry.etag != null) 'etag': <String>[entry.etag!],
          }),
        ),
        true,
      );
    }

    // Stale, SWR disabled → forward with conditional GET.
    if (entry.etag != null) {
      options.headers['If-None-Match'] = entry.etag;
    }
    options.extra['__apiCacheKey__'] = cacheKey;
    return handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) async {
    final cacheKey = response.requestOptions.extra['__apiCacheKey__'] as String?;
    final swr = response.requestOptions.extra['__apiCacheSWR__'] == true;
    final status = response.statusCode ?? 0;
    final etag = response.headers.value('etag');

    if (cacheKey == null) {
      return handler.next(response);
    }

    if (status == 304) {
      // BE confirmed cached version is still valid — refresh timestamp.
      final existing = await _readEntry(cacheKey);
      if (existing != null) {
        await _writeEntry(
          cacheKey,
          _CacheEntry(
            body: existing.body,
            etag: existing.etag,
            fetchedAt: DateTime.now(),
          ),
        );
      }
      if (kDebugMode) {
        debugPrint('[ApiCache] 304 refresh key=$cacheKey');
      }
      return handler.next(response);
    }

    if (status >= 200 && status < 300 && response.data is Map<String, dynamic>) {
      final body = response.data as Map<String, dynamic>;
      await _writeEntry(
        cacheKey,
        _CacheEntry(body: body, etag: etag, fetchedAt: DateTime.now()),
      );
      if (kDebugMode) {
        debugPrint('[ApiCache] STORE key=$cacheKey swr=$swr');
      }
    }

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final cacheKey = err.requestOptions.extra['__apiCacheKey__'] as String?;
    if (cacheKey != null) {
      _inflight.remove(cacheKey);
    }
    handler.next(err);
  }

  Future<void> _backgroundRevalidate(RequestOptions original, String cacheKey) async {
    if (_inflight.contains(cacheKey)) return;
    _inflight.add(cacheKey);
    try {
      final dio = Dio(BaseOptions(
        baseUrl: original.baseUrl,
        headers: Map<String, String>.from(original.headers),
        connectTimeout: original.connectTimeout,
        receiveTimeout: original.receiveTimeout,
        sendTimeout: original.sendTimeout,
      ));
      await dio.fetch<dynamic>(original);
    } catch (_) {
      // Background refresh errors are best-effort — the user keeps seeing the
      // stale body until the next foreground request retries.
    } finally {
      _inflight.remove(cacheKey);
    }
  }
}
