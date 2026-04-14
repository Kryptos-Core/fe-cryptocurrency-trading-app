import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_trading_app/core/utils/tradingview_pro_chart_html.dart';

void main() {
  group('TradingViewProChartHtml.widgetIntervalFromApi', () {
    test('maps 1m–1d to TradingView interval strings', () {
      expect(TradingViewProChartHtml.widgetIntervalFromApi('1m'), '1');
      expect(TradingViewProChartHtml.widgetIntervalFromApi('5m'), '5');
      expect(TradingViewProChartHtml.widgetIntervalFromApi('15m'), '15');
      expect(TradingViewProChartHtml.widgetIntervalFromApi('1h'), '60');
      expect(TradingViewProChartHtml.widgetIntervalFromApi('4h'), '240');
      expect(TradingViewProChartHtml.widgetIntervalFromApi('1d'), 'D');
    });

    test('defaults unknown interval to 60 (1h)', () {
      expect(TradingViewProChartHtml.widgetIntervalFromApi('2h'), '60');
      expect(TradingViewProChartHtml.widgetIntervalFromApi(''), '60');
    });
  });

  group('TradingViewProChartHtml.tradingViewLocaleFromTag', () {
    test('maps Vietnamese and English', () {
      expect(TradingViewProChartHtml.tradingViewLocaleFromTag('vi-VN'), 'vi_VN');
      expect(TradingViewProChartHtml.tradingViewLocaleFromTag('vi'), 'vi_VN');
      expect(TradingViewProChartHtml.tradingViewLocaleFromTag('en-US'), 'en');
    });

    test('falls back to en', () {
      expect(TradingViewProChartHtml.tradingViewLocaleFromTag('fr-FR'), 'en');
    });
  });

  group('TradingViewProChartHtml.build', () {
    test('embeds symbol, interval, theme, locale and tv.js script', () {
      final html = TradingViewProChartHtml.build(
        tvSymbol: 'BINANCE:BTCUSDT',
        apiInterval: '1h',
        isDarkTheme: true,
        localeLanguageTag: 'vi-VN',
      );
      expect(html, contains('https://s3.tradingview.com/tv.js'));
      expect(html, contains('BINANCE:BTCUSDT'));
      expect(html, contains("'60'"));
      expect(html, contains("'dark'"));
      expect(html, contains("'vi_VN'"));
      expect(html, contains('new TradingView.widget'));
      expect(html, contains('tv_container'));
    });

    test('escapes single quotes in symbol for JS string', () {
      final html = TradingViewProChartHtml.build(
        tvSymbol: "BINANCE:O'OPS",
        apiInterval: '1d',
        isDarkTheme: false,
        localeLanguageTag: 'en',
      );
      expect(html, contains(r"BINANCE:O\'OPS"));
    });

    // Phase 4 – browser zoom prevention & legend fixes
    test('injects JS to prevent Ctrl+Scroll browser zoom', () {
      final html = TradingViewProChartHtml.build(
        tvSymbol: 'BINANCE:BTCUSDT',
        apiInterval: '1h',
        isDarkTheme: false,
        localeLanguageTag: 'en',
      );
      // Must block wheel events with ctrlKey so the browser does not
      // zoom the entire WebView instead of zooming the chart content.
      expect(html, contains('e.ctrlKey'));
      expect(html, contains('preventDefault'));
    });

    test('hides legend so it does not obscure chart content', () {
      final html = TradingViewProChartHtml.build(
        tvSymbol: 'BINANCE:BTCUSDT',
        apiInterval: '1h',
        isDarkTheme: false,
        localeLanguageTag: 'en',
      );
      expect(html, contains('hide_legend: true'));
    });

    test('does not disable crosshair-related features', () {
      final html = TradingViewProChartHtml.build(
        tvSymbol: 'BINANCE:BTCUSDT',
        apiInterval: '1h',
        isDarkTheme: false,
        localeLanguageTag: 'en',
      );
      // The crosshair must not be suppressed via disabled_features.
      expect(html, isNot(contains('hide_price_scale')));
      expect(html, isNot(contains('no_crosshair')));
    });

    test('dark theme uses dark background colour', () {
      final htmlDark = TradingViewProChartHtml.build(
        tvSymbol: 'BINANCE:ETHUSDT',
        apiInterval: '5m',
        isDarkTheme: true,
        localeLanguageTag: 'en',
      );
      expect(htmlDark, contains('#131722'));
    });

    test('light theme uses white background colour', () {
      final htmlLight = TradingViewProChartHtml.build(
        tvSymbol: 'BINANCE:ETHUSDT',
        apiInterval: '5m',
        isDarkTheme: false,
        localeLanguageTag: 'en',
      );
      expect(htmlLight, contains('#ffffff'));
    });
  });
}
