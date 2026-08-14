/// Per-endpoint HTTP cache policy used by [ApiCacheInterceptor].
///
/// The interceptor matches incoming requests against the patterns in
/// [cacheableEndpointPolicies] and decides whether to:
///  - skip caching entirely (mutating verbs),
///  - return the cached body immediately (synchronous cache HIT),
///  - return cached body and refetch in background (stale-while-revalidate).
class CachePolicy {
  const CachePolicy({
    required this.ttl,
    this.swr = false,
    this.varyBy = const <String>[],
    this.noStore = false,
  });

  /// How long a cached entry is considered fresh.
  final Duration ttl;

  /// When true and the entry is past its TTL, the cached body is returned
  /// synchronously and a background revalidation request is fired.
  final bool swr;

  /// Cache key discriminators. Use this when the URL alone is not enough
  /// to separate distinct responses (e.g. wallets?include_zero=true vs false).
  final List<String> varyBy;

  /// When true, never cache this endpoint (mutations, realtime endpoints).
  final bool noStore;
}

/// Endpoint policies tuned for the 4 bottom-nav hot tabs + Trade FAB Orders.
///
/// Conventions:
///  - dashboard / markets / wallets / users/me have short TTLs and SWR enabled
///    because they are re-hit on every tab tap and combined with WS push for
///    live updates.
///  - mutations are noStore.
const List<EndpointCachePolicy> cacheableEndpointPolicies = <EndpointCachePolicy>[
  EndpointCachePolicy(
    method: 'GET',
    pattern: r'/api/v1/dashboard$',
    policy: CachePolicy(ttl: Duration(seconds: 30), swr: true),
  ),
  EndpointCachePolicy(
    method: 'GET',
    pattern: r'/api/v1/users/me$',
    policy: CachePolicy(ttl: Duration(minutes: 5), swr: true),
  ),
  EndpointCachePolicy(
    method: 'GET',
    pattern: r'/api/v1/wallets(\?|$)',
    policy: CachePolicy(
      ttl: Duration(seconds: 20),
      swr: true,
      varyBy: <String>['query.include_zero'],
    ),
  ),
  EndpointCachePolicy(
    method: 'GET',
    pattern: r'/api/v1/wallets/balance(\?|$)',
    policy: CachePolicy(
      ttl: Duration(seconds: 10),
      swr: true,
      varyBy: <String>['query.currencyId'],
    ),
  ),
  EndpointCachePolicy(
    method: 'GET',
    pattern: r'/api/v1/markets(\?.*page=1(&|$)|$)',
    policy: CachePolicy(ttl: Duration(seconds: 60), swr: true),
  ),
  EndpointCachePolicy(
    method: 'GET',
    pattern: r'/api/v1/markets/active$',
    policy: CachePolicy(ttl: Duration(seconds: 60), swr: true),
  ),
  EndpointCachePolicy(
    method: 'GET',
    pattern: r'/api/v1/markets/tickers/all$',
    policy: CachePolicy(ttl: Duration(seconds: 5), swr: true),
  ),
  EndpointCachePolicy(
    method: 'GET',
    pattern: r'/api/v1/currencies(\?|$)',
    policy: CachePolicy(ttl: Duration(seconds: 30), swr: true),
  ),
  EndpointCachePolicy(
    method: 'GET',
    pattern: r'/api/v1/orders/my(\?|$)',
    policy: CachePolicy(ttl: Duration(seconds: 10), swr: true),
  ),
];

class EndpointCachePolicy {
  const EndpointCachePolicy({
    required this.method,
    required this.pattern,
    required this.policy,
  });

  final String method;
  final String pattern;
  final CachePolicy policy;
}

/// Match [path] against the registered [cacheableEndpointPolicies].
/// Returns the most specific match (first match wins).
({CachePolicy policy, String key})? matchEndpointPolicy({
  required String method,
  required String path,
  required Map<String, dynamic> queryParameters,
}) {
  for (final entry in cacheableEndpointPolicies) {
    if (entry.method.toUpperCase() != method.toUpperCase()) continue;
    final regex = RegExp(entry.pattern);
    if (!regex.hasMatch(path)) continue;
    final policy = entry.policy;
    if (policy.noStore) {
      return null;
    }

    final key = _buildCacheKey(
      method: method,
      path: path,
      queryParameters: queryParameters,
      varyBy: policy.varyBy,
    );
    return (policy: policy, key: key);
  }
  return null;
}

String _buildCacheKey({
  required String method,
  required String path,
  required Map<String, dynamic> queryParameters,
  required List<String> varyBy,
}) {
  final buffer = StringBuffer()
    ..write(method.toUpperCase())
    ..write(' ')
    ..write(path);

  if (varyBy.isEmpty) {
    return buffer.toString();
  }

  final sortedKeys = queryParameters.keys.toList()..sort();
  for (final key in sortedKeys) {
    if (!varyBy.contains(key)) continue;
    final valuesRaw = queryParameters[key];
    final values = valuesRaw is List
        ? valuesRaw.map((e) => e.toString()).toList()
        : <String>[valuesRaw?.toString() ?? ''];
    final sortedValues = List<String>.from(values)..sort();
    buffer
      ..write('&')
      ..write(key)
      ..write('=')
      ..write(sortedValues.join(','));
  }
  return buffer.toString();
}
