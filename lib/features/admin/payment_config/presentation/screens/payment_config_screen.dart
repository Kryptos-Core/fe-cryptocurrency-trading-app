import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/utils/treasury_api_error_localization.dart';
import 'package:crypto_trading_app/features/admin/payment_config/data/models/payment_method_config_model.dart';
import 'package:crypto_trading_app/core/utils/currency_amount_input.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/providers/payment_config_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/onchain_chain_picker_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/treasury_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/treasury_main_wallet_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/screens/treasury_main_wallets/treasury_main_wallets_panel.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/screens/widgets/treasury_create_wallet_sheet.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/screens/widgets/treasury_history_tab_view.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/screens/widgets/treasury_wallets_tab_view.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/providers/treasury_e2e_config_provider.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/screens/widgets/treasury_e2e_config_form_sheet.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/screens/widgets/treasury_e2e_config_tab_view.dart';
import 'package:crypto_trading_app/features/admin/shared/presentation/providers/admin_enums_provider.dart';

String _paymentConfigDetailStr(dynamic v) {
  if (v == null) return '';
  if (v is num) return v.toString();
  return v.toString();
}

String _paymentConfigGraceLine(PaymentMethodConfigModel config, AppLocalizations l10n) {
  if (!config.isTransitioning) return '';
  final cd = config.graceCountdown;
  if (cd == null) return l10n.paymentConfigGraceUnknown;
  if (cd <= Duration.zero) return l10n.paymentConfigGraceFinalizePending;
  if (cd.inMinutes >= 1) return l10n.paymentConfigTransitioningRemaining(cd.inMinutes);
  return l10n.paymentConfigGraceUnderOneMinute;
}

/// Payment Method Config Screen — accessible only to ADMIN and FINANCE_MANAGER.
/// Allows dynamic management of PayOS credentials, blockchain hot wallet keys,
/// and network settings without restarting the server.
/// The Treasury ops tab lists `/treasury` transaction wallets, not `/managed-wallets`.
class PaymentConfigScreen extends StatefulWidget {
  const PaymentConfigScreen({super.key});

  @override
  State<PaymentConfigScreen> createState() => _PaymentConfigScreenState();
}

class _PaymentConfigScreenState extends State<PaymentConfigScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _tabIndex = 0;
  int _lastEnsuredTabIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabIndex = _tabController.index;
    _tabController.addListener(_onTabControllerTick);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminEnumsProvider>().ensureLoaded();
      _lastEnsuredTabIndex = _tabController.index;
      _ensureTabData(_tabController.index);
    });
  }

  void _onTabControllerTick() {
    if (_tabController.indexIsChanging) return;
    final idx = _tabController.index;
    if (idx != _tabIndex) {
      setState(() => _tabIndex = idx);
    }
    if (_lastEnsuredTabIndex == idx) return;
    _lastEnsuredTabIndex = idx;
    _ensureTabData(idx);
  }

  Future<void> _ensureTabData(int index) async {
    if (!mounted) return;
    switch (index) {
      case 0:
        await context.read<PaymentConfigProvider>().loadConfigs();
        break;
      case 1:
        await context.read<OnchainChainPickerProvider>().ensureLoaded();
        if (!mounted) return;
        await context.read<TreasuryMainWalletProvider>().refreshAllWallets();
        break;
      case 2:
        await context.read<OnchainChainPickerProvider>().ensureLoaded();
        if (!mounted) return;
        await context.read<TreasuryProvider>().loadWallets();
        break;
      case 3:
        await context.read<OnchainChainPickerProvider>().ensureLoaded();
        if (!mounted) return;
        await context.read<TreasuryProvider>().loadHistory();
        break;
      case 4:
        await context.read<TreasuryE2EConfigProvider>().loadConfigs();
        break;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabControllerTick);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.paymentConfigTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCurrentTab,
            tooltip: l10n.refresh,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.paymentConfigMethodsTab),
            Tab(text: l10n.paymentConfigMasterWalletTab),
            Tab(text: l10n.paymentConfigTreasuryWalletsTab),
            Tab(text: l10n.paymentConfigHistoryTab),
            Tab(text: l10n.treasuryE2eTabTitle),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _PaymentConfigTabView(),
          const TreasuryMainWalletsPanel(),
          const TreasuryWalletsTabView(),
          const TreasuryHistoryTabView(),
          TreasuryE2EConfigTabView(
            onCreate: () => _showTreasuryE2ECreateSheet(context),
            onEdit: (config) => _showTreasuryE2EEditSheet(context, config),
            onActivate: (config) => _confirmTreasuryE2EActivate(context, config),
            onDeactivate: (config) => _confirmTreasuryE2EDeactivate(context, config),
            onArchive: (config) => _confirmTreasuryE2EArchive(context, config),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_tabIndex == 0) {
      return FloatingActionButton.extended(
        onPressed: () => _showCreateConfigSheet(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.paymentConfigAddMethod),
      );
    }

    if (_tabIndex == 2) {
      return FloatingActionButton.extended(
        onPressed: () => _showCreateTreasuryWalletSheet(context),
        icon: const Icon(Icons.account_balance_wallet_outlined),
        label: Text(l10n.treasuryCreateWalletFab),
      );
    }

    return null;
  }

  Future<void> _refreshCurrentTab() async {
    if (_tabIndex == 0) {
      await context.read<PaymentConfigProvider>().loadConfigs(force: true);
      return;
    }

    if (_tabIndex == 1) {
      await context.read<OnchainChainPickerProvider>().ensureLoaded(force: true);
      if (!mounted) return;
      await context.read<TreasuryMainWalletProvider>().refreshAllWallets();
      return;
    }

    final treasuryProvider = context.read<TreasuryProvider>();
    if (_tabIndex == 2) {
      // Must reload operations too so TreasuryProvider can clear optimistic
      // pending state when sweep/fund is already COMPLETED (prune runs in loadHistory).
      await treasuryProvider.refreshAll(force: true);
      return;
    }

    if (_tabIndex == 3) {
      await treasuryProvider.loadHistory(force: true);
      return;
    }

    if (_tabIndex == 4) {
      await context.read<TreasuryE2EConfigProvider>().loadConfigs(force: true);
      return;
    }
  }

  void _showCreateConfigSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<PaymentConfigProvider>(),
        child: const _ConfigFormSheet(configId: null),
      ),
    );
  }

  void _showEditConfigSheet(BuildContext context, PaymentMethodConfigModel config) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<PaymentConfigProvider>(),
        child: _ConfigFormSheet(configId: config.configId, existing: config),
      ),
    );
  }

  Future<void> _showCreateTreasuryWalletSheet(BuildContext context) async {
    final provider = context.read<TreasuryProvider>();
    final l10n = AppLocalizations.of(context);

    await context.read<OnchainChainPickerProvider>().ensureLoaded();
    if (!context.mounted) return;

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const TreasuryCreateWalletSheet(),
    );

    if (!context.mounted) return;
    if (created == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.treasuryWalletCreatedSuccess)),
      );
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizeTreasuryApiError(
              l10n,
              code: provider.apiErrorCode,
              message: provider.error,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmActivate(BuildContext context, PaymentMethodConfigModel config) async {
    final provider = context.read<PaymentConfigProvider>();
    final l10n = AppLocalizations.of(context);
    final graceMinsController = TextEditingController(
      text: config.gracePeriodMinutes.toString(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.paymentConfigActivateDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.paymentConfigActivateTarget(config.displayName)),
            const SizedBox(height: 4),
            Text(
              l10n.paymentConfigActivateWarning,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: graceMinsController,
              decoration: InputDecoration(
                labelText: l10n.paymentConfigGracePeriodLabel,
                border: const OutlineInputBorder(),
                helperText: l10n.paymentConfigGracePeriodHelper,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.paymentConfigActivateAction),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final graceMins = int.tryParse(graceMinsController.text) ?? config.gracePeriodMinutes;
    final result = await provider.activateConfig(config.configId, gracePeriodMinutes: graceMins);

    if (!context.mounted) return;
    if (result != null) {
      final activatesAt = result['activatesAt'] as String?;
      final activationInfo = activatesAt != null
          ? '. ${l10n.paymentConfigActivationAt(activatesAt.substring(0, 16).replaceAll('T', ' '))}'
          : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.paymentConfigActivationStartedMinutes(graceMins)}$activationInfo',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? l10n.paymentConfigActivateFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDeactivate(BuildContext context, PaymentMethodConfigModel config) async {
    final provider = context.read<PaymentConfigProvider>();
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.paymentConfigDeactivateDialogTitle),
        content: Text(
          l10n.paymentConfigDeactivateDialogContent(config.displayName),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.paymentConfigDeactivateAction),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await provider.deactivateConfig(config.configId);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? l10n.paymentConfigDeactivatedSuccess : (provider.error ?? l10n.error)),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  void _showTreasuryE2ECreateSheet(BuildContext context) {
    _showTreasuryE2EFormSheet(context);
  }

  Future<void> _showTreasuryE2EFormSheet(BuildContext context) async {
    final provider = context.read<TreasuryE2EConfigProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 600;

    if (isWideScreen) {
      await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 560,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: ChangeNotifierProvider.value(
              value: provider,
              child: TreasuryE2EConfigFormSheet(
                existing: null,
                onSaved: () => Navigator.pop(context, true),
              ),
            ),
          ),
        ),
      );
    } else {
      await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: TreasuryE2EConfigFormSheet(
            existing: null,
            onSaved: () => Navigator.pop(context, true),
          ),
        ),
      );
    }
  }

  Future<void> _showTreasuryE2EEditSheet(BuildContext context, dynamic config) async {
    final provider = context.read<TreasuryE2EConfigProvider>();
    final detail = await provider.fetchDetail(config.configId);
    if (!context.mounted || detail == null) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 600;

    if (isWideScreen) {
      await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 560,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: ChangeNotifierProvider.value(
              value: provider,
              child: TreasuryE2EConfigFormSheet(
                existing: detail,
                onSaved: () => Navigator.pop(context, true),
              ),
            ),
          ),
        ),
      );
    } else {
      await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: TreasuryE2EConfigFormSheet(
            existing: detail,
            onSaved: () => Navigator.pop(context, true),
          ),
        ),
      );
    }
  }

  Future<void> _confirmTreasuryE2EActivate(BuildContext context, dynamic config) async {
    final provider = context.read<TreasuryE2EConfigProvider>();
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(AppLocalizations.of(context).treasuryE2eActivateDialogTitle),
            content: Text(AppLocalizations.of(context).treasuryE2eActivateDialogContent(config.displayName, config.environment)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context).cancel)),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppLocalizations.of(context).treasuryE2eActivateAction)),
            ],
          ),
        ) ??
        false;
    if (!ok || !context.mounted) return;
    await provider.activateConfig(config.configId);
  }

  Future<void> _confirmTreasuryE2EDeactivate(BuildContext context, dynamic config) async {
    final provider = context.read<TreasuryE2EConfigProvider>();
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(AppLocalizations.of(context).treasuryE2eDeactivateDialogTitle),
            content: Text(AppLocalizations.of(context).treasuryE2eDeactivateDialogContent(config.displayName)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context).cancel)),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppLocalizations.of(context).treasuryE2eDeactivateAction)),
            ],
          ),
        ) ??
        false;
    if (!ok || !context.mounted) return;
    await provider.deactivateConfig(config.configId);
  }

  Future<void> _confirmTreasuryE2EArchive(BuildContext context, dynamic config) async {
    final provider = context.read<TreasuryE2EConfigProvider>();
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(AppLocalizations.of(context).treasuryE2eArchiveDialogTitle),
            content: Text(AppLocalizations.of(context).treasuryE2eArchiveDialogContent(config.displayName)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context).cancel)),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppLocalizations.of(context).treasuryE2eArchiveAction)),
            ],
          ),
        ) ??
        false;
    if (!ok || !context.mounted) return;
    await provider.archiveConfig(config.configId);
  }

}

class _PaymentConfigTabView extends StatelessWidget {
  const _PaymentConfigTabView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Consumer<PaymentConfigProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.configs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.configs.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => provider.loadConfigs(force: true),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline_rounded, size: 48, color: scheme.error),
                          const SizedBox(height: 16),
                          Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.tonalIcon(
                            onPressed: () => provider.loadConfigs(force: true),
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(l10n.retry),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (provider.configs.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => provider.loadConfigs(force: true),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment_outlined, size: 48, color: scheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            l10n.paymentConfigEmptyMessage,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadConfigs(force: true),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: provider.configs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final screenState = context.findAncestorStateOfType<_PaymentConfigScreenState>();
              final config = provider.configs[index];
              return _PaymentConfigCard(
                config: config,
                onEdit: () => screenState?._showEditConfigSheet(context, config),
                onActivate: () => screenState?._confirmActivate(context, config),
                onDeactivate: () => screenState?._confirmDeactivate(context, config),
              );
            },
          ),
        );
      },
    );
  }
}

// ── Payment Config Card ──────────────────────────────────────────────────────

class _PaymentConfigCard extends StatelessWidget {
  final PaymentMethodConfigModel config;
  final VoidCallback onEdit;
  final VoidCallback onActivate;
  final VoidCallback onDeactivate;

  const _PaymentConfigCard({
    required this.config,
    required this.onEdit,
    required this.onActivate,
    required this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.9)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _PaymentTypeNetworkLine(
                        typeLabel: config.typeLabel,
                        network: config.network,
                        scheme: scheme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _PaymentConfigStatusCapsule(status: config.status, scheme: scheme),
              ],
            ),
            if (config.isTransitioning) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: scheme.outline.withValues(alpha: 0.22)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.hourglass_top_rounded, size: 18, color: scheme.onTertiaryContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _paymentConfigGraceLine(config, l10n),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onTertiaryContainer,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              l10n.paymentConfigVersionAndSort(config.configVersion, config.sortOrder),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            if (config.activatedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.paymentConfigActivatedAt(_formatDate(config.activatedAt!)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.65)),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, size: 18, color: scheme.primary),
                  label: Text(
                    l10n.paymentConfigEditAction,
                    style: TextStyle(fontWeight: FontWeight.w600, color: scheme.primary),
                  ),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
                const Spacer(),
                if (!config.isActive && !config.isTransitioning)
                  FilledButton.icon(
                    onPressed: onActivate,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: Text(l10n.paymentConfigActivateAction),
                  )
                else if (config.isActive)
                  OutlinedButton.icon(
                    onPressed: onDeactivate,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.error,
                      side: BorderSide(color: scheme.error.withValues(alpha: 0.55)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    icon: Icon(Icons.pause_circle_outline_rounded, size: 18, color: scheme.error),
                    label: Text(l10n.paymentConfigDeactivateAction),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _PaymentTypeNetworkLine extends StatelessWidget {
  const _PaymentTypeNetworkLine({
    required this.typeLabel,
    required this.network,
    required this.scheme,
  });

  final String typeLabel;
  final String network;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.28)),
        ),
        child: Text(
          '$typeLabel · $network',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onTertiaryContainer,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.15,
              ),
        ),
      ),
    );
  }
}

class _PaymentConfigStatusCapsule extends StatelessWidget {
  const _PaymentConfigStatusCapsule({required this.status, required this.scheme});

  final String status;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch (status) {
      'ACTIVE' => l10n.paymentConfigStatusActiveUpper,
      'TRANSITIONING' => l10n.paymentConfigStatusTransitioningUpper,
      _ => l10n.paymentConfigStatusInactiveUpper,
    };

    final (Color bg, Color fg) = switch (status) {
      'ACTIVE' => (scheme.primary, scheme.onPrimary),
      'TRANSITIONING' => (
          scheme.tertiaryContainer.withValues(alpha: 0.9),
          scheme.onTertiaryContainer,
        ),
      _ => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}

// ── Config Form Sheet ────────────────────────────────────────────────────────

/// Bottom sheet for creating or editing a payment method config.
/// Credentials (API keys, private keys) are masked by default.
class _ConfigFormSheet extends StatefulWidget {
  final String? configId;
  final PaymentMethodConfigModel? existing;

  const _ConfigFormSheet({this.configId, this.existing});

  @override
  State<_ConfigFormSheet> createState() => _ConfigFormSheetState();
}

class _ConfigFormSheetState extends State<_ConfigFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late String _type;
  late String _network;
  late final TextEditingController _displayNameCtrl;
  late final TextEditingController _graceMinsCtrl;

  // PayOS fields
  final _payosClientIdCtrl = TextEditingController();
  final _payosApiKeyCtrl = TextEditingController();
  final _payosChecksumKeyCtrl = TextEditingController();
  final _payosReturnUrlCtrl = TextEditingController();
  final _payosCancelUrlCtrl = TextEditingController();
  final _payosFiatSymbolCtrl = TextEditingController(text: 'VND');
  final _payosQuoteSymbolCtrl = TextEditingController(text: 'USDT');
  final _payosRateCtrl = TextEditingController(text: '0.00004');
  final _payosSpreadCtrl = TextEditingController(text: '0');
  final _payosMinDepositCtrl = TextEditingController(text: '10000');
  final _payosMaxDepositCtrl = TextEditingController();

  // Blockchain fields
  final _rpcUrlCtrl = TextEditingController();
  final _hotWalletKeyCtrl = TextEditingController();
  final _withdrawMaxCtrl = TextEditingController(text: '0.5');
  final _nativeCurrencyCtrl = TextEditingController();
  final _fxFallbackRateCtrl = TextEditingController(text: '1');
  bool _isMainnet = false;

  bool _showSensitiveFields = false;
  bool _isSubmitting = false;
  bool _loadingDetail = false;
  String? _detailLoadError;

  void _onCurrencySuffixControllersChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _type = widget.existing?.type ?? 'PAYOS';
    _network = widget.existing?.network ?? 'MAINNET';
    _displayNameCtrl = TextEditingController(text: widget.existing?.displayName ?? '');
    _graceMinsCtrl = TextEditingController(
      text: (widget.existing?.gracePeriodMinutes ?? 15).toString(),
    );
    _isMainnet = _network == 'MAINNET';
    _nativeCurrencyCtrl.text = switch (_type) {
      'ETH' => 'ETH',
      'TRON' => 'TRX',
      'SOL' => 'SOL',
      _ => '',
    };
    _payosQuoteSymbolCtrl.addListener(_onCurrencySuffixControllersChanged);
    _nativeCurrencyCtrl.addListener(_onCurrencySuffixControllersChanged);
    _loadingDetail = widget.configId != null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PaymentConfigProvider>().loadFormOptions();
      if (widget.configId != null) {
        _loadExistingDetail();
      }
    });
  }

  Future<void> _loadExistingDetail() async {
    if (widget.configId == null || !mounted) return;
    setState(() {
      _loadingDetail = true;
      _detailLoadError = null;
    });
    final provider = context.read<PaymentConfigProvider>();
    final raw = await provider.fetchConfigDetail(widget.configId!);
    if (!mounted) return;
    if (raw == null) {
      setState(() {
        _loadingDetail = false;
        _detailLoadError = provider.error;
      });
      return;
    }
    _applyRawDetail(raw);
    setState(() => _loadingDetail = false);
  }

  void _applyRawDetail(Map<String, dynamic> raw) {
    final type = raw['type'] as String? ?? _type;
    final network = raw['network'] as String? ?? _network;
    _type = type;
    _network = network;
    _isMainnet = network == 'MAINNET';

    final dn = raw['display_name'];
    if (dn != null) _displayNameCtrl.text = dn.toString();

    final gm = raw['grace_period_minutes'];
    if (gm != null) _graceMinsCtrl.text = gm.toString();

    final cfgAny = raw['config'];
    if (cfgAny is! Map) return;
    final cfg = Map<String, dynamic>.from(cfgAny);

    if (type == 'PAYOS') {
      _payosClientIdCtrl.text = _paymentConfigDetailStr(cfg['clientId']);
      _payosApiKeyCtrl.text = _paymentConfigDetailStr(cfg['apiKey']);
      _payosChecksumKeyCtrl.text = _paymentConfigDetailStr(cfg['checksumKey']);
      _payosReturnUrlCtrl.text = _paymentConfigDetailStr(cfg['returnUrl']);
      _payosCancelUrlCtrl.text = _paymentConfigDetailStr(cfg['cancelUrl']);
      _payosFiatSymbolCtrl.text = _paymentConfigDetailStr(cfg['fiatSymbol']).isEmpty
          ? 'VND'
          : _paymentConfigDetailStr(cfg['fiatSymbol']);
      _payosQuoteSymbolCtrl.text = _paymentConfigDetailStr(cfg['quoteCurrencySymbol']).isEmpty
          ? 'USDT'
          : _paymentConfigDetailStr(cfg['quoteCurrencySymbol']);
      _payosRateCtrl.text = _paymentConfigDetailStr(cfg['fiatToQuoteRate']);
      _payosSpreadCtrl.text = _paymentConfigDetailStr(cfg['fxSpreadBps']);
      final minDep = _paymentConfigDetailStr(cfg['minDepositAmountFiat']);
      _payosMinDepositCtrl.text =
          minDep.isEmpty ? '10000' : minDep;
      _payosMaxDepositCtrl.text =
          _paymentConfigDetailStr(cfg['maxDepositAmountFiat']);
    } else {
      _rpcUrlCtrl.text = _paymentConfigDetailStr(cfg['rpcUrl']);
      _hotWalletKeyCtrl.text = _paymentConfigDetailStr(cfg['hotWalletPrivateKey']);
      _nativeCurrencyCtrl.text = _paymentConfigDetailStr(cfg['nativeCurrencySymbol']);
      _withdrawMaxCtrl.text = _paymentConfigDetailStr(cfg['withdrawAutoMax']);
      _fxFallbackRateCtrl.text = _paymentConfigDetailStr(cfg['fxFallbackRate']);
      final im = cfg['isMainnet'];
      if (im is bool) {
        _isMainnet = im;
      }
    }
  }

  @override
  void dispose() {
    _payosQuoteSymbolCtrl.removeListener(_onCurrencySuffixControllersChanged);
    _nativeCurrencyCtrl.removeListener(_onCurrencySuffixControllersChanged);
    _displayNameCtrl.dispose();
    _graceMinsCtrl.dispose();
    _payosClientIdCtrl.dispose();
    _payosApiKeyCtrl.dispose();
    _payosChecksumKeyCtrl.dispose();
    _payosReturnUrlCtrl.dispose();
    _payosCancelUrlCtrl.dispose();
    _payosFiatSymbolCtrl.dispose();
    _payosQuoteSymbolCtrl.dispose();
    _payosRateCtrl.dispose();
    _payosSpreadCtrl.dispose();
    _payosMinDepositCtrl.dispose();
    _payosMaxDepositCtrl.dispose();
    _rpcUrlCtrl.dispose();
    _hotWalletKeyCtrl.dispose();
    _withdrawMaxCtrl.dispose();
    _nativeCurrencyCtrl.dispose();
    _fxFallbackRateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pm = context.watch<PaymentConfigProvider>();
    final types = pm.formTypes;
    final networks = pm.networksByType;
    final networkChoices = networks[_type] ?? const ['MAINNET'];
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Form(
          key: _formKey,
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Text(
                    widget.configId == null
                        ? l10n.paymentConfigAddMethod
                        : l10n.paymentConfigEditConfigTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              if (widget.configId != null && _loadingDetail) ...[
                const SizedBox(height: 40),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ] else if (widget.configId != null && _detailLoadError != null) ...[
                const SizedBox(height: 24),
                Text(
                  _detailLoadError!.isEmpty
                      ? l10n.paymentConfigDetailLoadFailed
                      : _detailLoadError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    setState(() => _detailLoadError = null);
                    _loadExistingDetail();
                  },
                  child: Text(l10n.retry),
                ),
              ] else ...[
              const SizedBox(height: 16),
              // Type selector
              DropdownButtonFormField<String>(
                key: ValueKey<String>('pm_cfg_type_${widget.configId ?? "new"}_$_type'),
                initialValue: types.contains(_type) ? _type : types.first,
                decoration: InputDecoration(
                  labelText: l10n.paymentConfigMethodTypeLabel,
                  border: const OutlineInputBorder(),
                  helperText: widget.configId != null ? l10n.paymentConfigEditTypeLocked : null,
                ),
                items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: widget.configId != null
                    ? null
                    : (v) {
                        if (v != null) {
                          setState(() {
                            _type = v;
                            final next = pm.networksForType(v);
                            _network = next.isNotEmpty ? next.first : 'MAINNET';
                            _nativeCurrencyCtrl.text = switch (v) {
                              'ETH' => 'ETH',
                              'TRON' => 'TRX',
                              'SOL' => 'SOL',
                              _ => '',
                            };
                          });
                        }
                      },
              ),
              const SizedBox(height: 12),
              // Network selector
              DropdownButtonFormField<String>(
                key: ValueKey<String>('pm_cfg_net_${widget.configId ?? "new"}_${_type}_$_network'),
                initialValue: networkChoices.contains(_network)
                    ? _network
                    : networkChoices.first,
                decoration: InputDecoration(
                  labelText: l10n.paymentConfigNetworkLabel,
                  border: const OutlineInputBorder(),
                ),
                items: networkChoices
                    .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                    .toList(),
                onChanged: widget.configId != null
                    ? null
                    : (v) {
                        if (v != null) {
                          setState(() {
                            _network = v;
                            _isMainnet = v == 'MAINNET';
                          });
                        }
                      },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _displayNameCtrl,
                decoration: InputDecoration(
                  labelText: l10n.paymentConfigDisplayNameLabel,
                  border: const OutlineInputBorder(),
                  hintText: l10n.paymentConfigDisplayNameHint,
                ),
                validator: (v) => (v?.isEmpty ?? true) ? l10n.paymentConfigRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _graceMinsCtrl,
                decoration: InputDecoration(
                  labelText: l10n.paymentConfigGracePeriodLabel,
                  border: const OutlineInputBorder(),
                  helperText: l10n.paymentConfigGracePeriodEffectHelper,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    l10n.paymentConfigCredentialsSectionTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => _showSensitiveFields = !_showSensitiveFields),
                    icon: Icon(
                      _showSensitiveFields ? Icons.visibility_off : Icons.visibility,
                      size: 16,
                    ),
                    label: Text(_showSensitiveFields ? l10n.paymentConfigHideAction : l10n.paymentConfigShowAction),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_type == 'PAYOS') ..._buildPayOSFields(),
              if (_type != 'PAYOS') ..._buildBlockchainFields(),
              const SizedBox(height: 24),
              if (_isMainnet)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.paymentConfigMainnetWarning,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        widget.configId == null
                            ? l10n.paymentConfigCreateConfigAction
                            : l10n.paymentConfigSaveChangesAction,
                      ),
              ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPayOSFields() {
    final l10n = AppLocalizations.of(context);
    return [
        _MaskedTextField(
          controller: _payosClientIdCtrl,
          label: 'Client ID',
          show: _showSensitiveFields,
        ),
        const SizedBox(height: 10),
        _MaskedTextField(
          controller: _payosApiKeyCtrl,
          label: 'API Key',
          show: _showSensitiveFields,
        ),
        const SizedBox(height: 10),
        _MaskedTextField(
          controller: _payosChecksumKeyCtrl,
          label: 'Checksum Key',
          show: _showSensitiveFields,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _payosReturnUrlCtrl,
          decoration: const InputDecoration(
            labelText: 'Return URL',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _payosCancelUrlCtrl,
          decoration: const InputDecoration(
            labelText: 'Cancel URL',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: _payosFiatSymbolCtrl,
              decoration: const InputDecoration(labelText: 'Fiat Symbol', border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _payosQuoteSymbolCtrl,
              decoration: const InputDecoration(labelText: 'Quote Symbol', border: OutlineInputBorder()),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: _payosRateCtrl,
              decoration: CurrencyAmountInput.withCurrencySuffix(
                context,
                InputDecoration(
                  labelText: l10n.paymentConfigRateLabel,
                  border: const OutlineInputBorder(),
                ),
                currencySymbol: _payosQuoteSymbolCtrl.text.trim().isEmpty
                    ? 'USDT'
                    : _payosQuoteSymbolCtrl.text.trim().toUpperCase(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _payosSpreadCtrl,
              decoration: const InputDecoration(labelText: 'FX Spread (bps)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: _payosMinDepositCtrl,
              decoration: const InputDecoration(
                labelText: 'Min deposit (fiat, integer)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _payosMaxDepositCtrl,
              decoration: const InputDecoration(
                labelText: 'Max deposit (fiat, optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
        ]),
      ];
  }

  List<Widget> _buildBlockchainFields() {
    final l10n = AppLocalizations.of(context);
    return [
        TextFormField(
          controller: _rpcUrlCtrl,
          decoration: const InputDecoration(
            labelText: 'RPC URL',
            border: OutlineInputBorder(),
            hintText: 'https://...',
          ),
        ),
        const SizedBox(height: 10),
        _MaskedTextField(
          controller: _hotWalletKeyCtrl,
          label: 'Hot Wallet Private Key',
          show: _showSensitiveFields,
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: _nativeCurrencyCtrl,
              decoration: const InputDecoration(labelText: 'Native Symbol', border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _withdrawMaxCtrl,
              decoration: CurrencyAmountInput.withCurrencySuffix(
                context,
                const InputDecoration(
                  labelText: 'Withdraw Auto Max',
                  border: OutlineInputBorder(),
                ),
                currencySymbol: _nativeCurrencyCtrl.text.trim().toUpperCase(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        TextFormField(
          controller: _fxFallbackRateCtrl,
          decoration: CurrencyAmountInput.withCurrencySuffix(
            context,
            const InputDecoration(
              labelText: 'FX Fallback Rate (1 Native → X USDT)',
              border: OutlineInputBorder(),
            ),
            currencySymbol: 'USDT',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 10),
        SwitchListTile(
          title: const Text('Mainnet'),
          subtitle: Text(l10n.paymentConfigMainnetSubtitle),
          value: _isMainnet,
          onChanged: (v) => setState(() => _isMainnet = v),
          contentPadding: EdgeInsets.zero,
        ),
      ];
  }

  Map<String, dynamic> _buildConfigPayload() {
    if (_type == 'PAYOS') {
      return {
        'clientId': _payosClientIdCtrl.text.trim(),
        'apiKey': _payosApiKeyCtrl.text.trim(),
        'checksumKey': _payosChecksumKeyCtrl.text.trim(),
        'returnUrl': _payosReturnUrlCtrl.text.trim(),
        'cancelUrl': _payosCancelUrlCtrl.text.trim(),
        'fiatSymbol': _payosFiatSymbolCtrl.text.trim().toUpperCase(),
        'quoteCurrencySymbol': _payosQuoteSymbolCtrl.text.trim().toUpperCase(),
        'fiatToQuoteRate': _payosRateCtrl.text.trim(),
        'fxSpreadBps': _payosSpreadCtrl.text.trim(),
        'minDepositAmountFiat': _payosMinDepositCtrl.text.trim(),
        if (_payosMaxDepositCtrl.text.trim().isNotEmpty)
          'maxDepositAmountFiat': _payosMaxDepositCtrl.text.trim(),
      };
    }
    return {
      'rpcUrl': _rpcUrlCtrl.text.trim(),
      'hotWalletPrivateKey': _hotWalletKeyCtrl.text.trim(),
      'nativeCurrencySymbol': _nativeCurrencyCtrl.text.trim().toUpperCase(),
      'withdrawAutoMax': _withdrawMaxCtrl.text.trim(),
      'fxFallbackRate': _fxFallbackRateCtrl.text.trim(),
      'isMainnet': _isMainnet,
    };
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    final provider = context.read<PaymentConfigProvider>();
    final configPayload = _buildConfigPayload();

    bool success;
    if (widget.configId == null) {
      success = await provider.createConfig(
        type: _type,
        network: _network,
        displayName: _displayNameCtrl.text.trim(),
        config: configPayload,
        gracePeriodMinutes: int.tryParse(_graceMinsCtrl.text) ?? 15,
      );
    } else {
      success = await provider.updateConfig(
        widget.configId!,
        displayName: _displayNameCtrl.text.trim(),
        config: configPayload.values.any((v) => v.toString().isNotEmpty) ? configPayload : null,
        gracePeriodMinutes: int.tryParse(_graceMinsCtrl.text),
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.configId == null
                ? l10n.paymentConfigCreatedSuccess
                : l10n.paymentConfigUpdatedSuccess,
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? l10n.paymentConfigUnknownError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _MaskedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool show;

  const _MaskedTextField({
    required this.controller,
    required this.label,
    required this.show,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: controller,
      obscureText: !show,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        helperText: show ? null : l10n.paymentConfigMaskedHelper,
      ),
    );
  }
}
