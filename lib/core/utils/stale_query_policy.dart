/// Default freshness window for payment-config tabs (similar to TanStack Query `staleTime`).
const kPaymentConfigTabStaleDuration = Duration(minutes: 2);

bool isStaleQueryFresh(DateTime? fetchedAt, [Duration stale = kPaymentConfigTabStaleDuration]) {
  if (fetchedAt == null) return false;
  return DateTime.now().difference(fetchedAt) < stale;
}
