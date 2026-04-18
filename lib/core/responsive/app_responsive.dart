import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shared layout breakpoints for the app (aligned with common Material window classes).
abstract final class AppBreakpoints {
  /// Below this width, prefer compact / stacked layouts.
  static const double compact = 600;

  /// From here up, use multi-column toolbars and optional two-column lists.
  static const double medium = 840;

  /// Master–detail side-by-side (e.g. admin lists).
  static const double wideLayout = 720;

  /// Two-column market grid on markets screen.
  static const double twoColumnGrid = 900;

  /// Max readable width for centered shell content (desktop / ultrawide).
  static const double contentMax = 1200;

  /// Effective max width for a centered column: caps at [contentMax].
  static double contentMaxWidthFor(double width) {
    if (width <= 0) return width;
    return math.min(width, contentMax);
  }

  static bool isMediumOrWider(double width) => width >= medium;

  static bool isTwoColumnGrid(double width) => width >= twoColumnGrid;
}

/// Centers [child] and constrains width on large viewports.
class AppCenteredContent extends StatelessWidget {
  final Widget child;

  const AppCenteredContent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = AppBreakpoints.contentMaxWidthFor(constraints.maxWidth);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: child,
          ),
        );
      },
    );
  }
}
