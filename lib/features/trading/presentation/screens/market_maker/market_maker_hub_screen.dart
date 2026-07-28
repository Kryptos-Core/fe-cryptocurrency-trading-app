import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/features/admin/market_maker/presentation/screens/market_maker_config_screen.dart';
import 'package:crypto_trading_app/features/admin/market_maker/presentation/screens/market_maker_place_orders_screen.dart';
import 'package:crypto_trading_app/features/admin/market_maker/presentation/screens/market_maker_screen_mode.dart';

/// Market Maker Hub entry screen.
///
/// Header banner summarizes the MM workspace; each workflow is rendered as a
/// bordered card tile matching the list-tile pattern used by other admin
/// hubs (withdrawal management, admin transactions).
///
/// All accent colors derive from the active [ColorScheme] so the hub
/// automatically follows the seed color the user picked in Settings.
class MarketMakerHubScreen extends StatelessWidget {
  const MarketMakerHubScreen({super.key});

  void _openConfigScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MarketMakerConfigScreen(
          mode: MarketMakerScreenMode.configuration,
        ),
      ),
    );
  }

  void _openPlaceOrdersScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MarketMakerPlaceOrdersScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.marketMakerHubTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          const _HubWelcomeCard(),
          const SizedBox(height: 16),
          _WorkflowTile(
            icon: Icons.tune,
            title: l10n.marketMakerConfigCardTitle,
            subtitle: l10n.marketMakerConfigCardSubtitle,
            badgeLabel: l10n.marketMakerHubBadgeReady,
            state: _TileState.ready,
            scheme: scheme,
            onTap: () => _openConfigScreen(context),
          ),
          const SizedBox(height: 10),
          _WorkflowTile(
            icon: Icons.auto_graph,
            title: l10n.marketMakerPlaceOrdersCardTitle,
            subtitle: l10n.marketMakerPlaceOrdersCardSubtitle,
            badgeLabel: l10n.marketMakerHubBadgeReady,
            state: _TileState.ready,
            scheme: scheme,
            onTap: () => _openPlaceOrdersScreen(context),
          ),
          const SizedBox(height: 10),
          _WorkflowTile(
            icon: Icons.dashboard_customize,
            title: l10n.marketMakerPositionDashboardCardTitle,
            subtitle: l10n.marketMakerPositionDashboardCardSubtitle,
            badgeLabel: l10n.marketMakerHubBadgeComingSoon,
            state: _TileState.comingSoon,
            scheme: scheme,
            onTap: () {
              showAppSnackBar(
                context,
                message: l10n.marketMakerDashboardComingSoon,
                type: SnackBarType.info,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// State determines the accent color applied to the tile and its badge.
enum _TileState { ready, comingSoon }

/// Accent color used for both the icon avatar and the status badge.
class _TileAccent {
  const _TileAccent({required this.icon, required this.badgeBg, required this.badgeFg});

  final Color icon;
  final Color badgeBg;
  final Color badgeFg;

  static _TileAccent ready(ColorScheme scheme) {
    final primary = scheme.primary;
    return _TileAccent(
      icon: primary,
      badgeBg: primary.withValues(alpha: 0.12),
      badgeFg: primary,
    );
  }

  static _TileAccent comingSoon(ColorScheme scheme) {
    final tertiary = scheme.tertiary;
    return _TileAccent(
      icon: scheme.onSurfaceVariant,
      badgeBg: tertiary.withValues(alpha: 0.14),
      badgeFg: scheme.onSurfaceVariant,
    );
  }
}

class _HubWelcomeCard extends StatelessWidget {
  const _HubWelcomeCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final primary = scheme.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: primary.withValues(alpha: 0.12),
            child: Icon(Icons.auto_awesome, color: primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.marketMakerHubWelcomeTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.marketMakerHubWelcomeSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkflowTile extends StatelessWidget {
  const _WorkflowTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    required this.state,
    required this.scheme,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badgeLabel;
  final _TileState state;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = switch (state) {
      _TileState.ready => _TileAccent.ready(scheme),
      _TileState.comingSoon => _TileAccent.comingSoon(scheme),
    };
    final theme = Theme.of(context);
    return Material(
      color: scheme.surfaceContainerLow.withValues(alpha: 0.85),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.45)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: accent.icon.withValues(alpha: 0.12),
                child: Icon(icon, color: accent.icon, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                              height: 1.2,
                            ),
                          ),
                        ),
                        _StatusBadge(
                          label: badgeLabel,
                          bgColor: accent.badgeBg,
                          fgColor: accent.badgeFg,
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 22,
                          color: scheme.outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.bgColor,
    required this.fgColor,
  });

  final String label;
  final Color bgColor;
  final Color fgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fgColor,
        ),
      ),
    );
  }
}