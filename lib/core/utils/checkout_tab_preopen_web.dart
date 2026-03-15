import 'package:web/web.dart' as web;

class PreopenedCheckoutTab {
  final web.Window? _window;

  PreopenedCheckoutTab(this._window);

  bool navigateTo(String url) {
    final window = _window;
    if (window == null) return false;

    try {
      window.location.href = url;
      return true;
    } catch (_) {
      return false;
    }
  }

  void close() {
    final window = _window;
    if (window == null) return;

    try {
      window.close();
    } catch (_) {
      // Ignore close errors for browsers that block programmatic close.
    }
  }
}

PreopenedCheckoutTab? preopenCheckoutTab() {
  final tab = web.window.open('about:blank', '_blank');
  return PreopenedCheckoutTab(tab);
}
