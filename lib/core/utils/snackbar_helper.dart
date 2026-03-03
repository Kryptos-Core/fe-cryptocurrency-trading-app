import 'package:flutter/material.dart';

/// Snackbar type for styling (replaces ToastType).
enum SnackBarType { success, error, warning, info }

/// Shows a Material SnackBar (framework built-in). Replaces custom ToastService.
void showAppSnackBar(
  BuildContext context, {
  required String message,
  required SnackBarType type,
  Duration duration = const Duration(seconds: 3),
}) {
  final color = _colorForType(type);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      action: SnackBarAction(
        label: 'OK',
        textColor: Colors.white,
        onPressed: () =>
            ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      ),
    ),
  );
}

Color _colorForType(SnackBarType type) {
  switch (type) {
    case SnackBarType.success:
      return const Color(0xFF10B981);
    case SnackBarType.error:
      return const Color(0xFFEF4444);
    case SnackBarType.warning:
      return const Color(0xFFF59E0B);
    case SnackBarType.info:
      return const Color(0xFF3B82F6);
  }
}
