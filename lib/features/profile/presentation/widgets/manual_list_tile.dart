import 'package:flutter/material.dart';

import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

/// A single row inside a [ManualSectionCard].
///
/// Visual pattern mirrors the existing Security / Navigation ListTiles in
/// [profile_screen.dart] so the manual screen feels native to the app:
///   leading semantic icon, localized title + subtitle, trailing chevron,
///   click cursor for desktop / web.
class ManualListTile extends StatelessWidget {
  const ManualListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  /// Convenience factory that resolves ARB keys through [AppLocalizations].
  ///
  /// Callers pass the l10n instance and the key getters directly so the
  /// widget stays free of hardcoded strings.
  factory ManualListTile.fromL10n({
    Key? key,
    required AppLocalizations l10n,
    required String Function(AppLocalizations l10n) titleSelector,
    required String Function(AppLocalizations l10n) subtitleSelector,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ManualListTile(
      key: key,
      icon: icon,
      title: titleSelector(l10n),
      subtitle: subtitleSelector(l10n),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: scheme.primary),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
      ),
      trailing: const Icon(Icons.chevron_right),
      mouseCursor: SystemMouseCursors.click,
      onTap: onTap,
    );
  }
}