import 'dart:async';

import 'package:flutter/material.dart';

/// Snackbar type for styling (replaces ToastType).
enum SnackBarType { success, error, warning, info }

OverlayEntry? _activeToastEntry;
Timer? _activeToastTimer;
bool _toastIsHovered = false;
bool _toastHasFocus = false;

void _dismissActiveToast() {
  _activeToastTimer?.cancel();
  _activeToastTimer = null;
  _activeToastEntry?.remove();
  _activeToastEntry = null;
  _toastIsHovered = false;
  _toastHasFocus = false;
}

void _scheduleToastDismiss(Duration duration) {
  _activeToastTimer?.cancel();
  _activeToastTimer = Timer(duration, () {
    if (!_toastIsHovered && !_toastHasFocus) {
      _dismissActiveToast();
    }
  });
}

/// Shows a floating toast overlay.
/// The toast auto-dismisses by default and stays visible only while hovered/focused.
void showAppSnackBar(
  BuildContext context, {
  required String message,
  required SnackBarType type,
  Duration duration = const Duration(seconds: 5),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);

  _dismissActiveToast();

  final color = _colorForType(type);
  final focusNode = FocusNode(debugLabel: 'app-toast-focus');

  _activeToastEntry = OverlayEntry(
    builder: (overlayContext) => Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: MouseRegion(
            onEnter: (_) {
              _toastIsHovered = true;
              _activeToastTimer?.cancel();
            },
            onExit: (_) {
              _toastIsHovered = false;
              _scheduleToastDismiss(const Duration(milliseconds: 250));
            },
            child: Focus(
              focusNode: focusNode,
              onFocusChange: (hasFocus) {
                _toastHasFocus = hasFocus;
                if (hasFocus) {
                  _activeToastTimer?.cancel();
                } else {
                  _scheduleToastDismiss(const Duration(milliseconds: 250));
                }
              },
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
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
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
