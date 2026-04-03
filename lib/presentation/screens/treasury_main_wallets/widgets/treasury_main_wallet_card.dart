import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:crypto_trading_app/data/models/treasury_model.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_main_wallet_provider.dart';
import 'package:crypto_trading_app/presentation/screens/treasury_main_wallets/widgets/copy_main_wallet_private_key_dialog.dart';
import 'package:crypto_trading_app/presentation/screens/treasury_main_wallets/widgets/edit_main_wallet_label_dialog.dart';

/// Hot-wallet row: address + one-tap copy; secondary icons for OTP private key, edit, delete, set default.
class TreasuryMainWalletCard extends StatelessWidget {
  const TreasuryMainWalletCard({
    super.key,
    required this.wallet,
    this.pendingAddedAtText,
    this.showApproveReject = false,
    this.onApprove,
    this.onReject,
  });

  final TreasuryMainWalletModel wallet;
  final String? pendingAddedAtText;
  final bool showApproveReject;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  static void copyAddressToClipboard(BuildContext context, String address) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    Clipboard.setData(ClipboardData(text: address));
    messenger?.showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).treasuryMainWalletCopiedAddressSnack),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final auth = context.watch<AuthProvider>();
    final provider = context.read<TreasuryMainWalletProvider>();

    final canFinanceTreasuryOps = auth.canManagePaymentConfigs;
    final showRevealKey =
        auth.isRiskOfficer || auth.canManagePaymentConfigs;
    final showEdit = auth.canManagePaymentConfigs;
    final showDelete = auth.isAdmin;
    final isPending = pendingAddedAtText != null;

    final labelTrimmed = wallet.label?.trim();

    final secondaryActions = <Widget>[
      if (!wallet.isDefault && canFinanceTreasuryOps && !isPending)
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(Icons.star_border, color: cs.primary),
          tooltip: l10n.treasuryMainWalletTooltipSetDefault,
          onPressed: () => provider.setDefaultWallet(wallet.mainWalletId),
        ),
      if (showRevealKey)
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(Icons.vpn_key_outlined, color: cs.primary),
          tooltip: l10n.treasuryMainWalletRevealPrivateKeyTooltip,
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (_) =>
                  CopyMainWalletPrivateKeyDialog(mainWalletId: wallet.mainWalletId),
            );
          },
        ),
      if (showEdit)
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(Icons.edit_outlined, color: cs.primary),
          tooltip: l10n.treasuryMainWalletMenuEditLabel,
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (_) => EditMainWalletLabelDialog(wallet: wallet),
            );
          },
        ),
      if (showDelete)
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(Icons.delete_outline, color: cs.error),
          tooltip: l10n.treasuryMainWalletMenuDelete,
          onPressed: () => _confirmDelete(context, provider, l10n),
        ),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ChainBadge(chain: wallet.chain, colorScheme: cs),
                const Spacer(),
                if (wallet.isDefault)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 4),
                    child: Chip(
                      label: Text(
                        l10n.treasuryMainWalletChipDefault,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                if (isPending && showApproveReject) ...[
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.check, color: Colors.green),
                    tooltip: l10n.treasuryMainWalletTooltipApprove,
                    onPressed: onApprove,
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close, color: Colors.red),
                    tooltip: l10n.treasuryMainWalletTooltipReject,
                    onPressed: onReject,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    wallet.address,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.15,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.copy_outlined, color: cs.primary),
                  tooltip: l10n.treasuryMainWalletCopyAddressTooltip,
                  onPressed: () => copyAddressToClipboard(context, wallet.address),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isPending)
              Text(
                l10n.treasuryMainWalletPendingSubtitle(pendingAddedAtText!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              )
            else ...[
              Text(
                l10n.treasuryMainWalletBalanceLine(wallet.balance, wallet.symbol),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              if (labelTrimmed != null && labelTrimmed.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  l10n.treasuryMainWalletLabelLine(labelTrimmed),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ],
            if (secondaryActions.isNotEmpty) ...[
              const SizedBox(height: 4),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Wrap(
                  spacing: 0,
                  runSpacing: 0,
                  alignment: WrapAlignment.end,
                  children: secondaryActions,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TreasuryMainWalletProvider provider,
    AppLocalizations l10n,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.treasuryMainWalletDeleteTitle),
        content: Text(l10n.treasuryMainWalletDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.treasuryMainWalletDeleteAction),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    final ok = await provider.deleteMainWallet(wallet.mainWalletId);
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.treasuryMainWalletDeleteSuccessSnack)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.treasuryImportWalletErrorSnack(provider.error ?? '')),
        ),
      );
    }
  }
}

class _ChainBadge extends StatelessWidget {
  const _ChainBadge({required this.chain, required this.colorScheme});

  final String chain;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        chain,
        style: theme.textTheme.labelMedium?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
