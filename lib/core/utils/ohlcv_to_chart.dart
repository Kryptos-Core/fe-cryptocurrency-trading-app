import 'package:crypto_trading_app/core/services/websocket_service.dart'
    show OHLCData;
import 'package:crypto_trading_app/domain/entities/market_pair.dart';

/// Converts REST [OHLCV] rows into realtime [OHLCData] for chart widgets.
List<OHLCData> ohlcvRowsToChartCandles({
  required String pairId,
  required String intervalLabel,
  required List<OHLCV> rows,
}) {
  return rows
      .map(
        (o) => OHLCData(
          pairId: pairId,
          interval: intervalLabel,
          openTime: o.openTime.millisecondsSinceEpoch,
          closeTime: o.openTime
              .add(Duration(seconds: o.intervalSec))
              .millisecondsSinceEpoch,
          open: double.tryParse(o.open) ?? 0,
          high: double.tryParse(o.high) ?? 0,
          low: double.tryParse(o.low) ?? 0,
          close: double.tryParse(o.close) ?? 0,
          volume: double.tryParse(o.volume) ?? 0,
          quoteVolume: 0,
          tradesCount: 0,
          isClosed: true,
        ),
      )
      .toList();
}
