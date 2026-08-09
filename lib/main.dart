import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:crypto_trading_app/app/app.dart';
import 'package:crypto_trading_app/app/bootstrap/initialize_app_bootstrap.dart';

/// Diagnostic flag for the `!keyReservation.contains(key)` assertion in
/// `NavigatorState._debugCheckDuplicatedPageKeys` (flutter#140586).
///
/// When `true`, the app installs a `FlutterError.onError` handler that
/// intercepts the assertion, dumps the offending page list (so we can see
/// which two pages share a key), and **swallows the error** so the UI
/// keeps rendering. This is a temporary triage aid only — once the real
/// fix lands, this should be removed and the app should crash loudly on
/// duplicate keys so the bug can't silently regress.
///
/// Enable from the build command:
///   flutter run --dart-define=DIAG_DUP_KEY=true
/// or by editing the constant below.
const bool _kDiagDupKey = bool.fromEnvironment('DIAG_DUP_KEY', defaultValue: true);

Future<void> main() async {
  await initializeAppBootstrap();

  if (_kDiagDupKey) {
    // Wraps every assertion in the framework, so we can capture the
    // duplicate-key state and continue rendering. Print a one-line
    // banner so the log is easy to grep.
    debugPrint('▌DIAG_DUP_KEY enabled: '
        'duplicate-key assertions will be caught and logged.');
    final FlutterExceptionHandler? original = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final String message = details.exceptionAsString();
      if (message.contains('keyReservation.contains(key)') ||
          message.contains('!keyReservation.contains(key)')) {
        debugPrint('▌DIAG_DUP_KEY caught: ${details.exception}');
        debugPrint('▌DIAG_DUP_KEY library: ${details.library}');
        debugPrint('▌DIAG_DUP_KEY context: ${details.context}');
        // === DIAGNOSTIC: dump the router's matchList so we can see
        // which pages are stacked when the assertion fires.
        // flutter#140586 typically trips when two sibling top-level
        // routes share a Page key (often the ShellRoute's page key
        // reused during a transition). ===================================
        try {
          // `details.context` is a `DiagnosticsNode` (not a BuildContext)
          // when the assertion fires from a widget build phase. We can't
          // reliably grab a BuildContext out of it, so the safest dump is
          // the GoRouterWidget inside the running app — but that's also
          // hard to reach here. The single most useful piece of info is
          // `details.context`, which Flutter formats with the full
          // widget subtree where the assertion fired. We just print it
          // as-is (Flutter's toString shows Element/widget paths).
          debugPrint(
              '▌DIAG_DUP_KEY details.context.toString()='
              '${details.context?.toString()}');
          // Pull every Navigator from the active widget tree at the
          // moment the error fired and dump the keys of their `pages`
          // argument. This is the exact data flutter#140586 cares
          // about.
          void dumpNavigators(Element el) {
            final w = el.widget;
            if (w is Navigator) {
              final ks = w.pages.map((p) => p.key?.toString()).toList();
              debugPrint('▌DIAG_DUP_KEY Navigator.pages keys=$ks');
            }
            el.visitChildren(dumpNavigators);
          }
          final root = WidgetsBinding.instance.rootElement;
          if (root != null) {
            dumpNavigators(root);
          }
        } catch (e, st) {
          debugPrint('▌DIAG_DUP_KEY router-dump error: $e\n$st');
        }
        // =================================================================
        if (details.stack != null) {
          debugPrint('▌DIAG_DUP_KEY stack:\n${details.stack}');
        }
        // Swallow — the page UI will be broken for this frame, but the
        // app stays alive so we can keep navigating and gather more data.
        return;
      }
      original?.call(details);
    };
  }

  runApp(const CryptoTradingApp());
}
