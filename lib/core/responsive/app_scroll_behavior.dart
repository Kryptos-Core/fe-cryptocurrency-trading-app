import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Hides platform scrollbars while keeping scroll (wheel, touch, drag) working.
///
/// Uses [MaterialScrollBehavior.copyWith] `scrollbars: false` so overlays
/// (e.g. dropdown menus) also skip the desktop [Scrollbar] wrapper, in addition
/// to [ThemeData.scrollbarTheme] (thumb/track hidden, zero thickness).
final ScrollBehavior appScrollBehavior = const MaterialScrollBehavior().copyWith(
  scrollbars: false,
  dragDevices: const <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  },
);
