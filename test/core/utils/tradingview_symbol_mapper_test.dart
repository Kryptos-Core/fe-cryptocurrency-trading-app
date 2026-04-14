import 'package:crypto_trading_app/core/utils/tradingview_symbol_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TradingViewSymbolMapper.toTradingView', () {
    test('plain symbol: prepends BINANCE:', () {
      expect(
        TradingViewSymbolMapper.toTradingView('BTCUSDT'),
        'BINANCE:BTCUSDT',
      );
    });

    test('slash-separated symbol is normalised', () {
      expect(
        TradingViewSymbolMapper.toTradingView('BTC/USDT'),
        'BINANCE:BTCUSDT',
      );
    });

    test('dash-separated symbol is normalised', () {
      expect(
        TradingViewSymbolMapper.toTradingView('BTC-USDT'),
        'BINANCE:BTCUSDT',
      );
    });

    test('underscore-separated symbol is normalised', () {
      expect(
        TradingViewSymbolMapper.toTradingView('BTC_USDT'),
        'BINANCE:BTCUSDT',
      );
    });

    test('lowercase input is uppercased', () {
      expect(
        TradingViewSymbolMapper.toTradingView('btcusdt'),
        'BINANCE:BTCUSDT',
      );
    });

    test('empty string returns null', () {
      expect(TradingViewSymbolMapper.toTradingView(''), isNull);
    });

    test('too short (< 4 chars) returns null', () {
      expect(TradingViewSymbolMapper.toTradingView('BTC'), isNull);
    });

    test('symbol with invalid characters returns null', () {
      expect(TradingViewSymbolMapper.toTradingView('BTC@USDT'), isNull);
    });
  });
}
