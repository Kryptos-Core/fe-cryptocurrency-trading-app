import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/screens/widgets/runtime_settings_category_view.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

/// Nested TabBar for runtime settings — one tab per [ConfigCategory].
/// Only renders tabs the current user has edit permission for.
/// Falls back to read-only when the user lacks edit permission.
class RuntimeSettingsTabView extends StatefulWidget {
  const RuntimeSettingsTabView({super.key});

  @override
  State<RuntimeSettingsTabView> createState() => _RuntimeSettingsTabViewState();
}

class _RuntimeSettingsTabViewState extends State<RuntimeSettingsTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Default 4 (tech, finance, ops, core); grows to 5 when auth_security tab is also visible.
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();

    final tabs = <Widget>[];
    final views = <Widget>[];

    if (auth.canEditSystemConfigTech) {
      tabs.add(Tab(text: l10n.paymentConfigRuntimeSectionTech));
      views.add(const RuntimeSettingsCategoryView(category: 'tech'));
    }

    if (auth.canEditSystemConfigFinance) {
      tabs.add(Tab(text: l10n.paymentConfigRuntimeSectionFinance));
      views.add(const RuntimeSettingsCategoryView(category: 'finance'));
    }

    if (auth.canEditSystemConfigOps) {
      tabs.add(Tab(text: l10n.paymentConfigRuntimeSectionOps));
      views.add(const RuntimeSettingsCategoryView(category: 'ops'));
    }

    if (auth.canEditSystemConfigCore) {
      tabs.add(Tab(text: l10n.paymentConfigRuntimeSectionCore));
      views.add(const RuntimeSettingsCategoryView(category: 'core'));
    }

    if (auth.canEditSystemConfigAuthSecurity) {
      tabs.add(Tab(text: l10n.paymentConfigRuntimeSectionAuthSecurity));
      views.add(const RuntimeSettingsCategoryView(category: 'auth_security'));
    }

    // If no tabs are visible, show an empty state.
    if (tabs.isEmpty) {
      return _NoPermissionView(l10n: l10n);
    }

    // Sync tab controller length with actual visible tabs.
    if (_tabController.length != tabs.length) {
      _tabController.dispose();
      _tabController = TabController(length: tabs.length, vsync: this);
    }

    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            isScrollable: tabs.length > 3,
            tabs: tabs,
            tabAlignment: tabs.length > 3 ? TabAlignment.start : null,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: views,
          ),
        ),
      ],
    );
  }
}

class _NoPermissionView extends StatelessWidget {
  const _NoPermissionView({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded, size: 56, color: scheme.outline),
            const SizedBox(height: 16),
            Text(
              l10n.paymentConfigRuntimeNoPermission,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
