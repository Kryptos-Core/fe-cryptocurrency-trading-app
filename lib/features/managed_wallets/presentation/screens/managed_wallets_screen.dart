import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/features/managed_wallets/domain/entities/managed_wallet/deposit_method.dart';
import 'package:crypto_trading_app/features/managed_wallets/domain/entities/managed_wallet/managed_wallet.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/managed_wallets/presentation/providers/managed_wallets_provider.dart';
import 'package:crypto_trading_app/features/managed_wallets/presentation/screens/managed_wallet_detail_screen.dart';
import 'package:crypto_trading_app/features/managed_wallets/presentation/screens/widgets/managed_wallet_card.dart';

/// User-facing deposit & managed wallets (`/managed-wallets`).
/// Chain list matches Ví On-chain → Nạp tiền (same `managed_wallets` / `onchain_deposit_withdraw` picker).
/// Operational hot wallets remain under Payment configuration → Treasury.
class ManagedWalletsScreen extends StatefulWidget {
  const ManagedWalletsScreen({super.key});

  @override
  State<ManagedWalletsScreen> createState() => _ManagedWalletsScreenState();
}

class _ManagedWalletsScreenState extends State<ManagedWalletsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _loadAll();
    });
  }

  Future<void> _loadAll() async {
    final provider = context.read<ManagedWalletsProvider>();
    await Future.wait([
      provider.fetchWallets(),
      provider.fetchDepositMethods(),
    ]);
    if (mounted && provider.error != null) {
      showAppSnackBar(context, message: provider.error!, type: SnackBarType.error);
      provider.clearError();
    }
  }

  void _navigateToDetail(ManagedWallet wallet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManagedWalletDetailScreen(wallet: wallet),
      ),
    ).then((_) {
      if (mounted) {
        Future.wait([
          context.read<ManagedWalletsProvider>().fetchWallets(),
          context.read<ManagedWalletsProvider>().fetchDepositMethods(),
        ]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.treasuryTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAll,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: Consumer<ManagedWalletsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.wallets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _loadAll,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                const _ManagedScopeBanner(),
                const SizedBox(height: 12),
                _ManagedSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ManagedCardHeader(
                        icon: Icons.south_west_rounded,
                        title: l10n.managedWalletsActiveDefaults,
                      ),
                      const SizedBox(height: 4),
                      ..._depositDefaultBlocks(
                        context,
                        provider.depositMethods?.methods ?? const [],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      l10n.managedWalletsSection,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      l10n.managedWalletsTotalCount(provider.wallets.length),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (provider.wallets.isEmpty)
                  const _EmptyWalletsState()
                else
                  ...provider.wallets.map(
                    (w) => ManagedWalletCard(
                      wallet: w,
                      onTap: () => _navigateToDetail(w),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

List<Widget> _depositDefaultBlocks(
  BuildContext context,
  List<DepositMethod> methods,
) {
  final l10n = AppLocalizations.of(context);
  final scheme = Theme.of(context).colorScheme;
  final configuredMethods = methods.where((m) => m.depositEnabled && m.hasAddress).toList();

  if (configuredMethods.isEmpty) {
    return [
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Icon(Icons.radio_button_unchecked_rounded, size: 18, color: scheme.outline),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.managedWalletsNotConfigured,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  final widgets = <Widget>[];
  for (var i = 0; i < configuredMethods.length; i++) {
    final method = configuredMethods[i];

    if (i > 0) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.65)),
        ),
      );
    }

    widgets.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ManagedChainCapsule(label: method.label, scheme: scheme),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_rounded, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      method.truncatedAddress,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            height: 1.4,
                          ),
                    ),
                    if (method.label.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          method.label.trim(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  return widgets;
}

class _ManagedScopeBanner extends StatelessWidget {
  const _ManagedScopeBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 20, color: scheme.tertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.treasuryManageSubtitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.treasuryManagedScopeBanner,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
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

class _ManagedSurfaceCard extends StatelessWidget {
  final Widget child;

  const _ManagedSurfaceCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.9)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}

class _ManagedCardHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ManagedCardHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
          ),
        ),
      ],
    );
  }
}

class _ManagedChainCapsule extends StatelessWidget {
  final String label;
  final ColorScheme scheme;

  const _ManagedChainCapsule({required this.label, required this.scheme});

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
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onTertiaryContainer,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
        ),
      ),
    );
  }
}

class _EmptyWalletsState extends StatelessWidget {
  const _EmptyWalletsState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 48, color: scheme.outline),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).managedWalletsNoWallets,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              AppLocalizations.of(context).managedWalletsNoWalletsDesc,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

