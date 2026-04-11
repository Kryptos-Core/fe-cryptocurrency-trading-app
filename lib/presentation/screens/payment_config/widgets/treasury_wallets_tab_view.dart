import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/utils/amount_input_formatter.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/core/utils/treasury_api_error_localization.dart';
import 'package:crypto_trading_app/data/models/treasury_model.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/onchain_chain_picker_provider.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_provider.dart';
import 'package:crypto_trading_app/presentation/providers/admin_enums_provider.dart';
import 'package:crypto_trading_app/presentation/constants/treasury_chains.dart';
import 'package:crypto_trading_app/presentation/widgets/app_dropdown_field.dart';
import 'package:crypto_trading_app/presentation/widgets/treasury_chain_dropdown.dart';

String _formatBalance(String? balance) {
  if (balance == null || balance.isEmpty) return '—';
  final parsed = double.tryParse(balance);
  if (parsed == null) return balance;
  return NumberFormat('#,###.##').format(parsed);
}

String _treasuryOnChainPendingTooltip(AppLocalizations l10n, String? operationId) {
  if (operationId != null && operationId.isNotEmpty) {
    return l10n.treasuryPendingOnChainTooltipWithId(operationId);
  }
  return l10n.treasuryPendingOnChainTooltipGeneric;
}

Future<void> _confirmDeleteTransactionWallet(
  BuildContext context,
  TreasuryWalletModel wallet,
  TreasuryProvider provider,
) async {
  final l10n = AppLocalizations.of(context);
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.treasuryOpsDeleteWalletTitle),
      content: Text(l10n.treasuryOpsDeleteWalletBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.treasuryCancelAction),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.treasuryOpsDeleteWalletAction),
        ),
      ],
    ),
  );
  if (confirm != true || !context.mounted) return;
  final ok = await provider.deleteTransactionWallet(wallet.walletId);
  if (!context.mounted) return;
  if (ok) {
    showAppSnackBar(
      context,
      message: l10n.treasuryOpsDeleteWalletSuccessSnack,
      type: SnackBarType.success,
    );
  } else {
    showAppSnackBar(
      context,
      message: localizeTreasuryApiError(
        l10n,
        code: provider.apiErrorCode,
        message: provider.error ?? l10n.treasuryFundFailed,
      ),
      type: SnackBarType.error,
    );
  }
}

void _showTreasuryQueuedSnackBar(
  BuildContext context, {
  required bool ok,
  required String primaryQueued,
  required String primaryFailed,
  String? errorMessage,
}) {
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  if (!ok) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(errorMessage ?? primaryFailed),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  final l10n = AppLocalizations.of(context);
  messenger.showSnackBar(
    SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(primaryQueued),
          const SizedBox(height: 6),
          Text(
            l10n.treasuryQueuedBalanceHint,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 5),
    ),
  );
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<TreasuryProvider>(
      builder: (context, provider, _) {
        final wallets = provider.wallets;
        return RefreshIndicator(
          onRefresh: () => provider.loadWallets(force: true),
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
                ...wallets.map(
                  (wallet) => _TreasuryWalletCard(
                    wallet: wallet,
                    isSubmitting: provider.isSubmitting,
                    showOnChainPending:
                        provider.isWalletPendingOnChain(wallet.walletId),
                    pendingOperationId:
                        provider.pendingOnChainOperationIdForWallet(wallet.walletId),
                  ),
                ),
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
    final chainPicker = context.watch<OnchainChainPickerProvider>();
    final enums = context.watch<AdminEnumsProvider>();
    final purposeItems = enums.treasuryWalletPurposes
        .map(
          (p) => DropdownMenuItem<String>(
            value: p,
            child: Text(p),
          ),
        )
        .toList();
    return Row(
      children: [
        Expanded(
          child: TreasuryChainDropdown(
            chains: chainPicker.treasuryOpsChains,
            value: provider.walletChain,
            allowAllOption: true,
            labelText: l10n.treasuryChainLabel,
            hintText: l10n.treasuryFilterAll,
            displayLabelForChain: treasuryWalletCreationDisplayLabel,
            onChanged: (value) async {
              provider.setWalletFilters(
                  chain: value, purpose: provider.walletPurpose);
              await provider.loadWallets(force: true);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppDropdownField<String>(
            value: provider.walletPurpose,
            labelText: l10n.treasuryPurposeLabel,
            hintText: l10n.treasuryFilterAll,
                       items: purposeItems,
            onChanged: (value) async {
              provider.setWalletFilters(chain: provider.walletChain, purpose: value);
              await provider.loadWallets(force: true);
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
          Text(
            l10n.treasuryOpsGuideSummary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _TreasuryWalletCard extends StatelessWidget {
  final TreasuryWalletModel wallet;
  final bool isSubmitting;
  final bool showOnChainPending;
  final String? pendingOperationId;

  const _TreasuryWalletCard({
    required this.wallet,
    required this.isSubmitting,
    this.showOnChainPending = false,
    this.pendingOperationId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TreasuryProvider>();
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final canDelete = !showOnChainPending &&
        !isSubmitting &&
        !wallet.isDefaultUserDeposit;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallet.shortAddress,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (wallet.label?.trim().isNotEmpty == true &&
                          wallet.label!.trim() != wallet.address)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '${l10n.treasuryLabelOptional}: ${wallet.label!.trim()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (wallet.isDefaultUserDeposit) ...[
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.green.shade600),
                        const SizedBox(width: 4),
                        Text(
                          l10n.walletBadgeDefault,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
            const SizedBox(height: 8),
            Text(
              l10n.treasuryOpsPublicAddressLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
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
                  mouseCursor: SystemMouseCursors.click,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.treasuryBalanceLabel}: ${_formatBalance(wallet.balance)} ${wallet.symbol ?? ''}',
                ),
                if (wallet.usdtTrc20Balance != null &&
                    wallet.chain.startsWith('TRON_')) ...[
                  const SizedBox(height: 2),
                  Text(
                    l10n.treasuryTrc20UsdtBalanceLine(
                      _formatBalance(wallet.usdtTrc20Balance!),
                    ),
                  ),
                ],
              ],
            ),
            if (showOnChainPending) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Tooltip(
                  message: _treasuryOnChainPendingTooltip(l10n, pendingOperationId),
                  child: Chip(
                    avatar: Icon(
                      Icons.sync,
                      size: 16,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    label: Text(
                      l10n.treasuryWalletPendingOnChainBadge,
                      style: const TextStyle(fontSize: 12),
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .tertiaryContainer
                        .withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
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
                        _showTreasuryQueuedSnackBar(
                          context,
                          ok: ok,
                          primaryQueued: l10n.treasurySweepQueued,
                          primaryFailed: l10n.treasurySweepFailed,
                          errorMessage: localizeTreasuryApiError(
                            l10n,
                            code: provider.apiErrorCode,
                            message: provider.error,
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
                                if (mainWallet.usdtTrc20Balance != null &&
                                    mainWallet.chain.startsWith('TRON_')) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.treasuryTrc20UsdtBalanceLine(
                                      _formatBalance(mainWallet.usdtTrc20Balance!),
                                    ),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
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
                      _showTreasuryQueuedSnackBar(
                        context,
                        ok: ok,
                        primaryQueued: l10n.treasuryFundQueued,
                        primaryFailed: l10n.treasuryFundFailed,
                        errorMessage: localizeTreasuryApiError(
                          l10n,
                          code: provider.apiErrorCode,
                          message: provider.error,
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
            const SizedBox(height: 8),
            Tooltip(
              message: wallet.isDefaultUserDeposit
                  ? l10n.apiErrorTxWalletDefaultDepositDelete
                  : l10n.treasuryOpsDeleteWalletTooltip,
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: canDelete
                      ? () => _confirmDeleteTransactionWallet(context, wallet, provider)
                      : null,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: canDelete
                        ? scheme.error
                        : scheme.onSurfaceVariant.withValues(alpha: 0.38),
                  ),
                  label: Text(l10n.treasuryOpsDeleteWalletAction),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: canDelete
                        ? scheme.error
                        : scheme.onSurfaceVariant.withValues(alpha: 0.38),
                    minimumSize: const Size.fromHeight(48),
                    side: BorderSide(
                      color: canDelete
                          ? scheme.error.withValues(alpha: 0.55)
                          : scheme.outline.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
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
      message: AppLocalizations.of(context).treasuryOpsAddressCopiedSnack,
      type: SnackBarType.success,
      duration: const Duration(seconds: 2),
    );
  }
}
