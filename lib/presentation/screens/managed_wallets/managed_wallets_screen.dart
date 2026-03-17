import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/domain/entities/managed_wallet/managed_wallet.dart';
import 'package:crypto_trading_app/presentation/providers/managed_wallets_provider.dart';
import 'package:crypto_trading_app/presentation/screens/managed_wallets/managed_wallet_detail_screen.dart';
import 'package:crypto_trading_app/presentation/screens/managed_wallets/widgets/create_wallet_sheet.dart';
import 'package:crypto_trading_app/presentation/screens/managed_wallets/widgets/managed_wallet_card.dart';
import 'package:crypto_trading_app/presentation/widgets/app_dropdown_field.dart';

/// Treasury Management screen — only accessible to RISK_OFFICER.
/// Provides: deposit defaults overview, recommended chain control, wallet list.
class ManagedWalletsScreen extends StatefulWidget {
  const ManagedWalletsScreen({super.key});

  @override
  State<ManagedWalletsScreen> createState() => _ManagedWalletsScreenState();
}

class _ManagedWalletsScreenState extends State<ManagedWalletsScreen> {
  static const _supportedChains = [
    ('TRON_NILE', 'Tron Nile'),
    ('TRON_SHASTA', 'Tron Shasta'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAll();
    });
  }

  Future<void> _loadAll() async {
    final provider = context.read<ManagedWalletsProvider>();
    await Future.wait([
      provider.fetchWallets(),
      provider.fetchDepositDefaults(),
      provider.fetchDepositMethods(),
    ]);
    if (mounted && provider.error != null) {
      showAppSnackBar(context, message: provider.error!, type: SnackBarType.error);
      provider.clearError();
    }
  }

  Future<void> _openCreateSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const CreateWalletSheet(),
    );
    if (mounted) {
      context.read<ManagedWalletsProvider>().fetchWallets();
    }
  }

  Future<void> _onSetRecommendedChain(String? chain) async {
    if (chain == null) return;
    final provider = context.read<ManagedWalletsProvider>();
    final error = await provider.setRecommendedChain(chain);
    if (!mounted) return;
    if (error == null) {
      showAppSnackBar(context, message: 'Recommended chain updated to $chain', type: SnackBarType.success);
    } else {
      showAppSnackBar(context, message: error, type: SnackBarType.error);
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
        context.read<ManagedWalletsProvider>().fetchWallets();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treasury Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAll,
            tooltip: 'Refresh',
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
              padding: const EdgeInsets.all(16),
              children: [
                _DepositDefaultsCard(
                  depositDefaults: provider.depositDefaults,
                  allChains: _supportedChains,
                ),
                const SizedBox(height: 16),
                _RecommendedChainCard(
                  currentChain: provider.recommendedChain,
                  chains: _supportedChains,
                  isSubmitting: provider.isSubmitting,
                  onChanged: _onSetRecommendedChain,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      'Wallets',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${provider.wallets.length} total',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (provider.wallets.isEmpty)
                  _EmptyWalletsState(onAdd: _openCreateSheet)
                else
                  ...provider.wallets.map(
                    (w) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ManagedWalletCard(
                        wallet: w,
                        onTap: () => _navigateToDetail(w),
                      ),
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateSheet,
        icon: const Icon(Icons.add),
        label: const Text('New Wallet'),
      ),
    );
  }
}

class _DepositDefaultsCard extends StatelessWidget {
  final List<ManagedWallet> depositDefaults;
  final List<(String, String)> allChains;

  const _DepositDefaultsCard({required this.depositDefaults, required this.allChains});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.input, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Active Deposit Defaults',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...allChains.map((chain) {
              final defaultWallet = depositDefaults
                  .where((w) => w.chain.apiValue == chain.$1)
                  .firstOrNull;
              return _DepositDefaultRow(
                chainLabel: chain.$2,
                wallet: defaultWallet,
                colorScheme: colorScheme,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _DepositDefaultRow extends StatelessWidget {
  final String chainLabel;
  final ManagedWallet? wallet;
  final ColorScheme colorScheme;

  const _DepositDefaultRow({
    required this.chainLabel,
    required this.wallet,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              chainLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          if (wallet != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                wallet!.truncatedAddress,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: colorScheme.onSurface,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (wallet!.label != null)
              Text(
                ' (${wallet!.label})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              ),
          ] else ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Not configured',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecommendedChainCard extends StatelessWidget {
  final String? currentChain;
  final List<(String, String)> chains;
  final bool isSubmitting;
  final ValueChanged<String?> onChanged;

  const _RecommendedChainCard({
    required this.currentChain,
    required this.chains,
    required this.isSubmitting,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star_outline, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Recommended Chain for Users',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (isSubmitting)
                  const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Users will see this chain as the primary deposit option.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(height: 12),
            AppDropdownField<String>(
              value: currentChain,
              labelText: 'Recommended Chain',
              hintText: 'Select chain',
              items: chains
                  .map((c) => DropdownMenuItem(value: c.$1, child: Text(c.$2)))
                  .toList(),
              onChanged: isSubmitting ? null : onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWalletsState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyWalletsState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 56, color: colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              'No wallets yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Generate your first treasury wallet to start accepting deposits.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Create First Wallet'),
            ),
          ],
        ),
      ),
    );
  }
}
