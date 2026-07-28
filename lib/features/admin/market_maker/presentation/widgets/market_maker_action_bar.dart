import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

/// Bottom action bar used by both Market Maker screens.
///
/// - Primary action (e.g. Save / Place orders) renders as [FilledButton].
/// - Optional secondary action (e.g. Delete) renders as [OutlinedButton].
/// - When [isSubmitting] is true, buttons render a small spinner in place of
///   the icon and disable interaction.
class MarketMakerActionBar extends StatelessWidget {
  const MarketMakerActionBar({
    super.key,
    required this.isSubmitting,
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryIcon = Icons.save,
    this.secondaryLabel,
    this.onSecondary,
    this.secondaryIcon = Icons.delete_outline,
    this.confirmSecondaryTitle,
    this.confirmSecondaryMessage,
  });

  final bool isSubmitting;
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback? onPrimary;

  final String? secondaryLabel;
  final IconData secondaryIcon;
  final VoidCallback? onSecondary;

  final String? confirmSecondaryTitle;
  final String? confirmSecondaryMessage;

  Future<void> _handlePrimary(BuildContext context) async {
    if (isSubmitting || onPrimary == null) return;
    onPrimary!();
  }

  Future<void> _handleSecondary(BuildContext context) async {
    if (isSubmitting || onSecondary == null) return;
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(secondaryIcon, color: scheme.error),
            const SizedBox(width: 10),
            Expanded(child: Text(confirmSecondaryTitle ?? l10n.confirm)),
          ],
        ),
        content: Text(confirmSecondaryMessage ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: scheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(secondaryLabel ?? l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      onSecondary!();
    }
  }

  Widget _busyIcon(Color color) => SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasSecondary = secondaryLabel != null && onSecondary != null;

    if (!hasSecondary) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: isSubmitting ? null : () => _handlePrimary(context),
          icon: isSubmitting
              ? _busyIcon(scheme.onPrimary)
              : Icon(primaryIcon),
          label: Text(primaryLabel),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: isSubmitting ? null : () => _handlePrimary(context),
            icon: isSubmitting
                ? _busyIcon(scheme.onPrimary)
                : Icon(primaryIcon),
            label: Text(primaryLabel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isSubmitting ? null : () => _handleSecondary(context),
            icon: isSubmitting
                ? _busyIcon(scheme.error)
                : Icon(secondaryIcon),
            label: Text(secondaryLabel!),
            style: OutlinedButton.styleFrom(
              foregroundColor: scheme.error,
              side: BorderSide(color: scheme.error.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }
}