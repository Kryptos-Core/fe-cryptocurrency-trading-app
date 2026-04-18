import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/features/managed_wallets/domain/entities/managed_wallet/managed_wallet.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';

/// List tile for managed deposit wallet — layout aligned with treasury / payment-config wallet cards.
class ManagedWalletCard extends StatelessWidget {
  final ManagedWallet wallet;
  final VoidCallback? onTap;

  const ManagedWalletCard({super.key, required this.wallet, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final currentUserId = context.watch<AuthProvider>().currentUser?.id;
    final showOwnerHint = currentUserId != null &&
        wallet.userId.isNotEmpty &&
        wallet.userId != currentUserId;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: scheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.9)),
      ),
      child: InkWell(
        onTap: onTap,
        mouseCursor:
            onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
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
                          wallet.displayLabel,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _ManagedChainCapsule(
                              label: wallet.chain.apiValue,
                              scheme: scheme,
                            ),
                            if (wallet.isDefaultDeposit)
                              _ManagedStatusCapsule(
                                label: l10n.walletBadgeDefault,
                                background: scheme.primary,
                                foreground: scheme.onPrimary,
                              ),
                            if (!wallet.isActive)
                              _ManagedStatusCapsule(
                                label: l10n.walletBadgeInactive,
                                background: scheme.surfaceContainerHighest,
                                foreground: scheme.onSurfaceVariant,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, color: scheme.outline, size: 22),
                ],
              ),
              if (showOwnerHint) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.managedWalletOwnerHint(_shortUserId(wallet.userId)),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                l10n.treasuryOpsPublicAddressLabel,
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
                    onPressed: () => _copyAddress(context, l10n),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _shortUserId(String id) {
    if (id.length <= 14) return id;
    return '${id.substring(0, 8)}…${id.substring(id.length - 4)}';
  }

  void _copyAddress(BuildContext context, AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: wallet.address));
    showAppSnackBar(
      context,
      message: l10n.createWalletAddressCopied,
      type: SnackBarType.success,
      duration: const Duration(seconds: 2),
    );
  }
}

class _ManagedChainCapsule extends StatelessWidget {
  final String label;
  final ColorScheme scheme;

  const _ManagedChainCapsule({required this.label, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _ManagedStatusCapsule extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _ManagedStatusCapsule({
    required this.label,
    required this.background,
    required this.foreground,
  });

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
