import 'dart:async';

import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

/// Snackbar type for styling (replaces ToastType).
enum SnackBarType { success, error, warning, info }

OverlayEntry? _activeToastEntry;
Timer? _activeToastTimer;
bool _dismissScheduled = false;

void _dismissActiveToast() {
  if (_dismissScheduled) return;
  _dismissScheduled = true;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _dismissScheduled = false;
    _activeToastTimer?.cancel();
    _activeToastTimer = null;
    _activeToastEntry?.remove();
    _activeToastEntry = null;
  });
}

void _dismissActiveToastNow() {
  _activeToastTimer?.cancel();
  _activeToastTimer = null;
  _activeToastEntry?.remove();
  _activeToastEntry = null;
}

void _scheduleToastDismiss(Duration duration) {
  _activeToastTimer?.cancel();
  _activeToastTimer = Timer(duration, _dismissActiveToast);
}

/// Shows a floating toast overlay.
/// The toast auto-dismisses by default and stays visible only while hovered/focused.
void showAppSnackBar(
  BuildContext context, {
  required String message,
  required SnackBarType type,
  Duration duration = const Duration(seconds: 5),
}) {
  // Caller may be disposed after async work; never use this [context] inside
  // [OverlayEntry.builder] — only for Overlay lookup here while still mounted.
  if (!context.mounted) return;

  final overlay = Overlay.of(context, rootOverlay: true);
  // Resolve l10n once while [context] is guaranteed mounted — do not call
  // AppLocalizations inside [OverlayEntry.builder] (rebuilds after route pop).
  final okLabel = AppLocalizations.of(context).snackbarOk;

  _dismissActiveToastNow();

  final color = _colorForType(type);

  _activeToastEntry = OverlayEntry(
    builder: (_) => Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _dismissActiveToast,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(48, 32),
                  ),
                  child: Text(okLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(_activeToastEntry!);
  _scheduleToastDismiss(duration);
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
