import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:crypto_trading_app/features/treasury/domain/entities/treasury_model.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/treasury_main_wallet_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/screens/treasury_main_wallets/widgets/copy_main_wallet_private_key_dialog.dart';
import 'package:crypto_trading_app/features/treasury/presentation/screens/treasury_main_wallets/widgets/edit_main_wallet_label_dialog.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/onchain_chain_picker_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/constants/treasury_chains.dart';

/// Hot-wallet card — layout aligned with payment-config [TreasuryWalletsTabView] wallet rows.
class TreasuryMainWalletCard extends StatelessWidget {
  const TreasuryMainWalletCard({
    super.key,
    required this.wallet,
    this.pendingAddedAtText,
    this.showApproveReject = false,
    this.onApprove,
    this.onReject,
    this.approveReviewTooltip,
    this.rejectReviewTooltip,
  });

  final TreasuryMainWalletModel wallet;
  final String? pendingAddedAtText;
  final bool showApproveReject;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final String? approveReviewTooltip;
  final String? rejectReviewTooltip;

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

  static String _displayTitle(TreasuryMainWalletModel wallet) {
    final label = wallet.label?.trim();
    if (label != null && label.isNotEmpty) return label;
    return _shortAddress(wallet.address);
  }

  static String _shortAddress(String address) {
    if (address.length <= 14) return address;
    return '${address.substring(0, 8)}…${address.substring(address.length - 6)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final auth = context.watch<AuthProvider>();
    final provider = context.read<TreasuryMainWalletProvider>();

    final canFinanceTreasuryOps = auth.canManagePaymentConfigs;
    final showRevealKey = auth.isRiskOfficer || auth.canManagePaymentConfigs;
    final showEdit = auth.canManagePaymentConfigs;
    final showRequestDeletion = canFinanceTreasuryOps;
    final isPendingTab = pendingAddedAtText != null;
    final isPendingDeletion = wallet.status.toUpperCase() == 'PENDING_DELETION';

    final secondaryActions = <Widget>[
      if (!wallet.isDefault && canFinanceTreasuryOps && !isPendingDeletion)
        IconButton(
          visualDensity: VisualDensity.compact,
          style: IconButton.styleFrom(
            foregroundColor: scheme.primary,
            backgroundColor: scheme.primaryContainer.withValues(alpha: 0.35),
          ),
          icon: const Icon(Icons.star_border_rounded, size: 20),
          tooltip: l10n.treasuryMainWalletTooltipSetDefault,
          onPressed: () => provider.setDefaultWallet(wallet.mainWalletId),
        ),
      if (showRevealKey)
        IconButton(
          visualDensity: VisualDensity.compact,
          style: IconButton.styleFrom(
            foregroundColor: scheme.primary,
            backgroundColor: scheme.primaryContainer.withValues(alpha: 0.35),
          ),
          icon: const Icon(Icons.vpn_key_outlined, size: 20),
          tooltip: l10n.treasuryMainWalletRevealPrivateKeyTooltip,
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (_) => CopyMainWalletPrivateKeyDialog(mainWalletId: wallet.mainWalletId),
            );
          },
        ),
      if (showEdit && !isPendingDeletion)
        IconButton(
          visualDensity: VisualDensity.compact,
          style: IconButton.styleFrom(
            foregroundColor: scheme.primary,
            backgroundColor: scheme.primaryContainer.withValues(alpha: 0.35),
          ),
          icon: const Icon(Icons.edit_outlined, size: 20),
          tooltip: l10n.treasuryMainWalletMenuEditLabel,
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (_) => EditMainWalletLabelDialog(wallet: wallet),
            );
          },
        ),
      if (showRequestDeletion && !isPendingTab && !isPendingDeletion)
        IconButton(
          visualDensity: VisualDensity.compact,
          style: IconButton.styleFrom(
            foregroundColor: scheme.error,
            backgroundColor: scheme.errorContainer.withValues(alpha: 0.45),
          ),
          icon: const Icon(Icons.delete_outline_rounded, size: 20),
          tooltip: l10n.treasuryMainWalletMenuDelete,
          onPressed: () => _confirmRequestDeletion(context, provider, l10n),
        ),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: scheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.9)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _displayTitle(wallet),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                if (wallet.isDefault)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: _StatusCapsule(
                      label: l10n.treasuryMainWalletChipDefault,
                      foreground: scheme.onPrimary,
                      background: scheme.primary,
                    ),
                  ),
                if (isPendingDeletion)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: _StatusCapsule(
                      label: l10n.treasuryMainWalletChipPendingDeletion,
                      foreground: scheme.onErrorContainer,
                      background: scheme.errorContainer.withValues(alpha: 0.85),
                    ),
                  ),
                if (isPendingTab && showApproveReject) ...[
                  const SizedBox(width: 4),
                  IconButton.filledTonal(
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      backgroundColor: scheme.primaryContainer.withValues(alpha: 0.65),
                      foregroundColor: scheme.onPrimaryContainer,
                    ),
                    icon: const Icon(Icons.check_rounded, size: 22),
                    tooltip: approveReviewTooltip ?? l10n.treasuryMainWalletTooltipApprove,
                    onPressed: onApprove,
                  ),
                  IconButton.filledTonal(
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      backgroundColor: scheme.errorContainer.withValues(alpha: 0.65),
                      foregroundColor: scheme.onErrorContainer,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 22),
                    tooltip: rejectReviewTooltip ?? l10n.treasuryMainWalletTooltipReject,
                    onPressed: onReject,
                  ),
                ],
                if (isPendingDeletion && !isPendingTab && auth.isAdmin) ...[
                  const SizedBox(width: 4),
                  IconButton.filledTonal(
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      backgroundColor: scheme.primaryContainer.withValues(alpha: 0.65),
                      foregroundColor: scheme.onPrimaryContainer,
                    ),
                    icon: const Icon(Icons.check_rounded, size: 22),
                    tooltip: l10n.treasuryMainWalletTooltipApproveDeletion,
                    onPressed: () => provider.approveMainWalletDeletion(wallet.mainWalletId),
                  ),
                  IconButton.filledTonal(
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      backgroundColor: scheme.errorContainer.withValues(alpha: 0.65),
                      foregroundColor: scheme.onErrorContainer,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 22),
                    tooltip: l10n.treasuryMainWalletTooltipRejectDeletion,
                    onPressed: () => provider.rejectMainWalletDeletion(wallet.mainWalletId),
                  ),
                ],
              ],
            ),
            // In production (ONCHAIN_OPERATOR_MODE=production), all available chains are mainnets —
            // the chain label is self-evident and redundant; hide it to reduce visual noise.
            if (!treasuryChainsUseMainnetOnly) ...[
              const SizedBox(height: 6),
              _ChainLine(chain: wallet.chain, scheme: scheme),
              const SizedBox(height: 10),
            ]
            else
              const SizedBox(height: 12),
            Text(
              l10n.treasuryMainWalletPublicAddressLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SelectableText(
                    wallet.address,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      height: 1.45,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.treasuryMainWalletCopyAddressTooltip,
                  icon: Icon(Icons.copy_rounded, size: 18, color: scheme.outline),
                  onPressed: () => copyAddressToClipboard(context, wallet.address),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (isPendingTab)
              Text(
                l10n.treasuryMainWalletPendingSubtitle(pendingAddedAtText!),
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, height: 1.35),
              )
            else if (isPendingDeletion)
              Text(
                l10n.treasuryMainWalletPendingDeletionHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onErrorContainer,
                  height: 1.35,
                ),
              )
            else ...[
              Text(
                l10n.treasuryMainWalletBalanceLine(
                  _formatTreasuryAmount(wallet.balance),
                  wallet.symbol,
                ),
                style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              if (wallet.usdtTrc20Balance != null && wallet.chain.startsWith('TRON_')) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.treasuryTrc20UsdtBalanceLine(_formatTreasuryAmount(wallet.usdtTrc20Balance!)),
                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ],
            if (secondaryActions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.65)),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 4,
                runSpacing: 4,
                children: secondaryActions,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatTreasuryAmount(String raw) {
    if (raw.isEmpty) return '—';
    final parsed = double.tryParse(raw);
    if (parsed == null) return raw;
    return NumberFormat('#,###.######').format(parsed);
  }

  Future<void> _confirmRequestDeletion(
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
    final ok = await provider.requestMainWalletDeletion(wallet.mainWalletId);
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

class _ChainLine extends StatelessWidget {
  const _ChainLine({required this.chain, required this.scheme});

  final String chain;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final label = context.watch<OnchainChainPickerProvider>().displayLabelForCode(chain);
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

class _StatusCapsule extends StatelessWidget {
  const _StatusCapsule({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}
