import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Hides platform scrollbars while keeping scroll (wheel, touch, drag) working.
///
/// [MaterialScrollBehavior] wraps scrollables with a [Scrollbar] on desktop by default;
/// this behavior skips that wrapper. Mouse/trackpad drag-to-scroll is preserved.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
