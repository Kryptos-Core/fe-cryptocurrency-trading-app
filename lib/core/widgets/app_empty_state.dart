import 'package:flutter/material.dart';

/// Reusable empty state widget aligned with Material 3 design system.
/// Uses theme-aware colors so it adapts seamlessly to light/dark mode
/// and the app's seed color.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.title,
    this.action,
    this.actionLabel,
  });

  /// Primary message text.
  final String message;

  /// Icon to display (default: inbox outline).
  final IconData icon;

  /// Optional title text (bold, larger than message).
  final String? title;

  /// Optional callback for action button.
  final VoidCallback? action;

  /// Label for the optional action button.
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 56,
              color: scheme.outline,
            ),
            if (title != null) ...[
              const SizedBox(height: 16),
              Text(
                title!,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonal(
                onPressed: action,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact inline empty placeholder for cards/list items.
/// Lighter visual weight — icon + short message only.
class AppEmptyStateInline extends StatelessWidget {
  const AppEmptyStateInline({
    super.key,
    required this.message,
    this.icon = Icons.search_off_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: scheme.outline),
          const SizedBox(height: 10),
          Text(
            message,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
