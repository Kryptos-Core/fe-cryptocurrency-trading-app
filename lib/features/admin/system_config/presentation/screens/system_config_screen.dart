import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/screens/widgets/runtime_settings_tab_view.dart';

/// System-wide runtime settings screen — accessible from the admin drawer.
///
/// Groups environment variables into 4 role-gated tabs:
/// Tech / Finance / Ops / Core. Guards are enforced by [RuntimeSettingsTabView].
class SystemConfigScreen extends StatelessWidget {
  const SystemConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.systemConfigScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refresh(context),
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: const RuntimeSettingsTabView(),
    );
  }

  void _refresh(BuildContext context) {
    // RuntimeSettingsCategoryView widgets handle their own refresh via
    // RefreshIndicator — no external action needed.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).systemConfigRefreshHint),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
