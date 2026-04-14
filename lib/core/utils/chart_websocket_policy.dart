/// Whether [ChartProvider.initializeWebSocket] should run for trading charts.
///
/// Avoids redundant reconnect when the shared [ChartProvider] is already
/// authenticated (e.g. user came from [MarketDetailScreen]).
bool chartWebSocketNeedsInitialize({
  required bool providerReportsConnected,
  required bool hasNonEmptyToken,
}) {
  return hasNonEmptyToken && !providerReportsConnected;
}
