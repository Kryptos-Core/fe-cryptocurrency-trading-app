import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/data/models/treasury_model.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/app_dropdown_field.dart';

class TreasuryWalletsTabView extends StatefulWidget {
  const TreasuryWalletsTabView({super.key});

  @override
  State<TreasuryWalletsTabView> createState() => _TreasuryWalletsTabViewState();
}

class _TreasuryWalletsTabViewState extends State<TreasuryWalletsTabView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TreasuryProvider>().loadWallets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<TreasuryProvider>(
      builder: (context, provider, _) {
        final wallets = provider.wallets;
        return RefreshIndicator(
          onRefresh: provider.loadWallets,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              _TreasuryWalletFilterRow(provider: provider),
              const SizedBox(height: 12),
              if (provider.isLoadingWallets && wallets.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (wallets.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    l10n.treasuryNoWalletsYet,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              else
                ...wallets.map((wallet) => _TreasuryWalletCard(wallet: wallet)),
            ],
          ),
        );
      },
    );
  }
}

class _TreasuryWalletFilterRow extends StatelessWidget {
  final TreasuryProvider provider;

  const _TreasuryWalletFilterRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: AppDropdownField<String>(
            value: provider.walletChain,
            labelText: l10n.treasuryChainLabel,
            hintText: l10n.treasuryFilterAll,
            items: const [
              DropdownMenuItem(value: 'TRON_NILE', child: Text('TRON_NILE')),
              DropdownMenuItem(value: 'TRON_SHASTA', child: Text('TRON_SHASTA')),
              DropdownMenuItem(value: 'ETH_SEPOLIA', child: Text('ETH_SEPOLIA')),
            ],
            onChanged: (value) async {
              provider.setWalletFilters(chain: value, purpose: provider.walletPurpose);
              await provider.loadWallets();
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppDropdownField<String>(
            value: provider.walletPurpose,
            labelText: l10n.treasuryPurposeLabel,
            hintText: l10n.treasuryFilterAll,
            items: const [
              DropdownMenuItem(value: 'DEPOSIT', child: Text('DEPOSIT')),
              DropdownMenuItem(value: 'WITHDRAWAL', child: Text('WITHDRAWAL')),
              DropdownMenuItem(value: 'BOTH', child: Text('BOTH')),
            ],
            onChanged: (value) async {
              provider.setWalletFilters(chain: provider.walletChain, purpose: value);
              await provider.loadWallets();
            },
          ),
        ),
      ],
    );
  }
}

class _TreasuryWalletCard extends StatelessWidget {
  final TreasuryWalletModel wallet;

  const _TreasuryWalletCard({required this.wallet});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TreasuryProvider>();
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    wallet.label?.isNotEmpty == true ? wallet.label! : wallet.shortAddress,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: wallet.isActive
                        ? Colors.green.withValues(alpha: 0.12)
                        : Colors.grey.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    wallet.isActive ? l10n.treasuryStatusActive : l10n.treasuryStatusInactive,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('${wallet.chain} · ${wallet.purpose}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 2),
            Text(wallet.address, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
            if (wallet.balance != null) ...[
              const SizedBox(height: 4),
              Text('${l10n.treasuryBalanceLabel}: ${wallet.balance} ${wallet.symbol ?? ''}'),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final ok = await provider.sweepWallet(wallet.walletId);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? l10n.treasurySweepQueued : (provider.error ?? l10n.treasurySweepFailed)),
                          backgroundColor: ok ? Colors.green : Colors.red,
                        ),
                      );
                    },
                    icon: const Icon(Icons.call_made, size: 16),
                    label: Text(l10n.treasurySweepAction),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      final amountCtrl = TextEditingController();
                      final amount = await showDialog<String>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.treasuryFundDialogTitle),
                          content: TextField(
                            controller: amountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: l10n.treasuryAmountLabel,
                              hintText: l10n.treasuryAmountHint,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.treasuryCancelAction)),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, amountCtrl.text.trim()),
                              child: Text(l10n.treasuryConfirmAction),
                            ),
                          ],
                        ),
                      );

                      if (amount == null || amount.isEmpty) return;
                      final ok = await provider.fundWallet(walletId: wallet.walletId, amount: amount);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? l10n.treasuryFundQueued : (provider.error ?? l10n.treasuryFundFailed)),
                          backgroundColor: ok ? Colors.green : Colors.red,
                        ),
                      );
                    },
                    icon: const Icon(Icons.south_west, size: 16),
                    label: Text(l10n.treasuryFundAction),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
