/// Builds a self-contained HTML document that loads TradingView's legacy `tv.js`
/// and instantiates [TradingView.widget](https://www.tradingview.com/widget/).
///
/// Used with [WebviewController.loadStringContent] (Windows WebView2).
abstract final class TradingViewProChartHtml {
  TradingViewProChartHtml._();

  /// Maps app OHLCV interval (`1m` … `1d`) to TradingView widget `interval` string.
  static String widgetIntervalFromApi(String apiInterval) {
    switch (apiInterval) {
      case '1m':
        return '1';
      case '5m':
        return '5';
      case '15m':
        return '15';
      case '1h':
        return '60';
      case '4h':
        return '240';
      case '1d':
        return 'D';
      default:
        return '60';
    }
  }

  /// Maps Flutter `Locale` language tag to TradingView `locale` (best-effort).
  static String tradingViewLocaleFromTag(String languageTag) {
    final lower = languageTag.toLowerCase();
    if (lower.startsWith('vi')) return 'vi_VN';
    if (lower.startsWith('en')) return 'en';
    return 'en';
  }

  static String _escapeJsSingleQuoted(String s) {
    return s
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll('\n', ' ')
        .replaceAll('\r', '');
  }

  /// Full HTML page: loads `https://s3.tradingview.com/tv.js` and creates the widget.
  static String build({
    required String tvSymbol,
    required String apiInterval,
    required bool isDarkTheme,
    required String localeLanguageTag,
  }) {
    final interval = widgetIntervalFromApi(apiInterval);
    final theme = isDarkTheme ? 'dark' : 'light';
    final sym = _escapeJsSingleQuoted(tvSymbol);
    final loc = _escapeJsSingleQuoted(
        tradingViewLocaleFromTag(localeLanguageTag));
    final bg = isDarkTheme ? '#131722' : '#ffffff';

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    html, body { margin: 0; padding: 0; height: 100%; overflow: hidden; background: $bg; }
    #tv_container { position: absolute; top: 0; left: 0; right: 0; bottom: 0; }
  </style>
</head>
<body>
  <div id="tv_container"></div>
  <script src="https://s3.tradingview.com/tv.js"></script>
  <script>
    // Prevent browser-level zoom (Ctrl+Scroll / Ctrl+±) so the WebView does not
    // scale the entire page. TradingView widget handles its own chart zoom internally.
    document.addEventListener('wheel', function(e) {
      if (e.ctrlKey) { e.preventDefault(); }
    }, { passive: false });
    document.addEventListener('keydown', function(e) {
      if (e.ctrlKey && (e.key === '+' || e.key === '-' || e.key === '=')) {
        e.preventDefault();
      }
    });

    new TradingView.widget({
      autosize: true,
      symbol: '$sym',
      interval: '$interval',
      timezone: 'Etc/UTC',
      theme: '$theme',
      style: '1',
      locale: '$loc',
      enable_publishing: false,
      hide_top_toolbar: false,
      hide_legend: true,
      save_image: false,
      container_id: 'tv_container',
      disabled_features: ['use_localstorage_for_settings']
    });
  </script>
</body>
</html>
''';
  }
}
