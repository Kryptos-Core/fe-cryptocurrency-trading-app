import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_trading_app/core/services/websocket_service.dart'
    show OHLCData;
import 'package:crypto_trading_app/core/utils/ohlcv_to_chart.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';

void main() {
  group('ohlcvRowsToChartCandles', () {
    test('maps rows using intervalSec for closeTime', () {
      final open = DateTime.utc(2024, 1, 1, 12);
      final rows = [
        OHLCV(
          pairId: 'p1',
          intervalSec: 3600,
          openTime: open,
          open: '1',
          high: '2',
          low: '0.5',
          close: '1.5',
          volume: '100',
        ),
      ];
      final candles = ohlcvRowsToChartCandles(
        pairId: 'pair-x',
        intervalLabel: '1h',
        rows: rows,
      );
      expect(candles, hasLength(1));
      final c = candles.single;
      expect(c.pairId, 'pair-x');
      expect(c.interval, '1h');
      expect(c.openTime, open.millisecondsSinceEpoch);
      expect(
        c.closeTime,
        open.add(const Duration(seconds: 3600)).millisecondsSinceEpoch,
      );
      expect(c.open, 1);
      expect(c.high, 2);
      expect(c.low, 0.5);
      expect(c.close, 1.5);
      expect(c.volume, 100);
      expect(c.quoteVolume, 0);
      expect(c.tradesCount, 0);
      expect(c.isClosed, true);
    });

    test('returns empty list for empty input', () {
      expect(
        ohlcvRowsToChartCandles(
          pairId: 'p',
          intervalLabel: '5m',
          rows: const [],
        ),
        isEmpty,
      );
    });
  });
}
