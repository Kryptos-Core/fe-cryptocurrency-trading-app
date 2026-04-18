import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/admin/market_maker/presentation/screens/market_maker_config_screen.dart';

/// Market Maker Hub entry screen.
///
/// This is a lightweight navigation hub for MM workflows while feature
/// screens are being implemented incrementally.
///
/// Styling matches operational drawer entries (deepOrange icons, plain [ListTile]).
class MarketMakerHubScreen extends StatelessWidget {
  const MarketMakerHubScreen({super.key});

  static const _opsIconColor = Colors.deepOrange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.marketMakerHubTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: const Icon(Icons.tune, color: _opsIconColor),
            title: Text(
              l10n.marketMakerConfigCardTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              l10n.marketMakerConfigCardSubtitle,
              style: const TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.chevron_right),
            mouseCursor: SystemMouseCursors.click,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MarketMakerConfigScreen(
                    mode: MarketMakerScreenMode.configuration,
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.auto_graph, color: _opsIconColor),
            title: Text(
              l10n.marketMakerPlaceOrdersCardTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              l10n.marketMakerPlaceOrdersCardSubtitle,
              style: const TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MarketMakerConfigScreen(
                    mode: MarketMakerScreenMode.placeOrders,
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.dashboard_customize, color: _opsIconColor),
            title: Text(
              l10n.marketMakerPositionDashboardCardTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              l10n.marketMakerPositionDashboardCardSubtitle,
              style: const TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.chevron_right),
            mouseCursor: SystemMouseCursors.click,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.marketMakerDashboardComingSoon),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
