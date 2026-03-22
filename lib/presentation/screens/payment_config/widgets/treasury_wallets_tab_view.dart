import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/utils/amount_input_formatter.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/data/models/treasury_model.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/app_dropdown_field.dart';

String _formatBalance(String? balance) {
  if (balance == null || balance.isEmpty) return '—';
  final parsed = double.tryParse(balance);
  if (parsed == null) return balance;
  return NumberFormat('#,###.##').format(parsed);
}

Future<String?> _showSweepDialog(
  BuildContext context,
  TreasuryWalletModel wallet,
  TreasuryProvider provider,
) async {
  final l10n = AppLocalizations.of(context);
  await provider.loadMainWallets(wallet.chain);
  if (!context.mounted) return null;
  final mainWallets = provider.mainWallets;
  String? selectedId = mainWallets.isEmpty
      ? null
      : (mainWallets.firstWhere(
          (m) => m.isDefault,
          orElse: () => mainWallets.first,
        ).mainWalletId);

  return showDialog<String>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(l10n.treasurySweepDialogTitle),
            content: mainWallets.isEmpty
                ? Text(
                    'No main wallets configured for ${wallet.chain}. Sweep will use default.',
                    style: const TextStyle(fontSize: 12),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.treasurySweepTargetLabel),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedId,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: mainWallets
                            .map(
                              (m) => DropdownMenuItem(
                                value: m.mainWalletId,
                                child: Text(
                                  m.label ?? '${m.address.substring(0, 10)}... (${m.balance} ${m.symbol})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => selectedId = v),
                      ),
                    ],
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.treasuryCancelAction),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, selectedId ?? ''),
                child: Text(l10n.treasuryConfirmAction),
              ),
            ],
          );
        },
      );
    },
  );
}

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
              const _TreasuryOpsScopeBanner(),
              const SizedBox(height: 12),
              _TreasuryOpsGuideCard(),
              const SizedBox(height: 12),
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
              DropdownMenuItem(value: 'TRON_MAINNET', child: Text('TRON_MAINNET')),
              DropdownMenuItem(value: 'ETH_SEPOLIA', child: Text('ETH_SEPOLIA')),
              DropdownMenuItem(value: 'ETH_MAINNET', child: Text('ETH_MAINNET')),
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

class _TreasuryOpsScopeBanner extends StatelessWidget {
  const _TreasuryOpsScopeBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 18, color: colorScheme.tertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.treasuryOpsScopeBanner,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _TreasuryOpsGuideCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.treasuryOpsGuideTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(l10n.treasurySweepMeaning),
          const SizedBox(height: 6),
          Text(l10n.treasuryFundMeaning),
          const SizedBox(height: 6),
          Text(
            l10n.treasuryOpsHowTo,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    wallet.address,
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
                InkWell(
                  onTap: () => _copyAddress(context),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.copy,
                      size: 14,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.treasuryBalanceLabel}: ${_formatBalance(wallet.balance)} ${wallet.symbol ?? ''}',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Tooltip(
                    message: l10n.treasurySweepTooltip,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final mainWalletId = await _showSweepDialog(context, wallet, provider);
                        if (mainWalletId == null) return;
                        final ok = await provider.sweepWallet(
                          wallet.walletId,
                          mainWalletId: mainWalletId.isEmpty ? null : mainWalletId,
                        );
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
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Tooltip(
                    message: l10n.treasuryFundTooltip,
                    child: FilledButton.icon(
                    onPressed: () async {
                      await provider.loadMainWallets(wallet.chain);
                      if (!context.mounted) return;
                      final mainWallet = provider.mainWallets.isNotEmpty
                          ? provider.mainWallets.firstWhere(
                              (m) => m.isDefault,
                              orElse: () => provider.mainWallets.first,
                            )
                          : null;
                      final amountCtrl = TextEditingController();
                      final amount = await showDialog<String>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.treasuryFundDialogTitle),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (mainWallet != null) ...[
                                Text(
                                  '${l10n.treasuryBalanceLabel}: ${_formatBalance(mainWallet.balance)} ${mainWallet.symbol}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 12),
                              ],
                              TextField(
                                controller: amountCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [AmountInputFormatter()],
                                decoration: InputDecoration(
                                  labelText: l10n.treasuryAmountLabel,
                                  hintText: l10n.treasuryAmountHint,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ],
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
                      final parsedAmount = parseAmountInput(amount);
                      if (parsedAmount.isEmpty) return;
                      final ok = await provider.fundWallet(walletId: wallet.walletId, amount: parsedAmount);
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyAddress(BuildContext context) {
    Clipboard.setData(ClipboardData(text: wallet.address));
    showAppSnackBar(
      context,
      message: AppLocalizations.of(context).createWalletAddressCopied,
      type: SnackBarType.success,
      duration: const Duration(seconds: 2),
    );
  }
}
