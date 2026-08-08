import 'package:flutter/material.dart';

import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

import '../../domain/entities/currency.dart';

/// Visual variants for [CurrencyStatusBadge].
enum CurrencyStatusKind {
  /// Whether the currency is enabled for users.
  active,

  /// Whether the currency can be traded on markets.
  tradable,
}

/// Small pill badge representing a boolean currency flag (active/tradable).
///
/// Uses theme-driven semantic colors so it adapts to light/dark mode and
/// the user's selected seed color. Reused by the list card, detail screen
/// and any future surface that needs to communicate currency status.
class CurrencyStatusBadge extends StatelessWidget {
  const CurrencyStatusBadge({
    super.key,
    required this.kind,
    required this.value,
    this.dense = false,
  });

  final CurrencyStatusKind kind;
  final bool value;
  final bool dense;

  IconData get _icon {
    if (value) {
      return switch (kind) {
        CurrencyStatusKind.active => Icons.check_circle_outline,
        CurrencyStatusKind.tradable => Icons.swap_horiz,
      };
    }
    return switch (kind) {
      CurrencyStatusKind.active => Icons.cancel_outlined,
      CurrencyStatusKind.tradable => Icons.pause_circle_outline,
    };
  }

  /// Resolves the (background, foreground) color pair for the badge.
  ///
  /// Active/Tradable use the primary tonal role; inactive/paused use the
  /// surface container role. This keeps badges legible without hard-coding
  /// colors and matches the rest of the markets feature.
  ({Color background, Color foreground}) _resolveColors(ColorScheme scheme) {
    if (value) {
      return (
        background: scheme.primaryContainer,
        foreground: scheme.onPrimaryContainer,
      );
    }
    return (
      background: scheme.surfaceContainerHighest,
      foreground: scheme.onSurfaceVariant,
    );
  }

  String _labelFor(AppLocalizations l10n) {
    return switch (kind) {
      CurrencyStatusKind.active => value ? l10n.active : l10n.inactive,
      CurrencyStatusKind.tradable =>
        value ? l10n.currenciesTradable : l10n.currenciesPaused,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final colors = _resolveColors(scheme);

    final fontSize = dense ? 11.0 : 12.0;
    final iconSize = dense ? 12.0 : 14.0;
    final hPad = dense ? 6.0 : 8.0;
    final vPad = dense ? 2.0 : 4.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(dense ? 6 : 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: iconSize, color: colors.foreground),
          const SizedBox(width: 4),
          Text(
            _labelFor(l10n),
            style: textTheme.labelSmall?.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper to map an [Currency] status flag into a badge.
extension CurrencyStatusBadgeFactory on Currency {
  CurrencyStatusBadge badgeFor(CurrencyStatusKind kind) =>
      CurrencyStatusBadge(kind: kind, value: switch (kind) {
        CurrencyStatusKind.active => isActive,
        CurrencyStatusKind.tradable => isTradable,
      });
}
