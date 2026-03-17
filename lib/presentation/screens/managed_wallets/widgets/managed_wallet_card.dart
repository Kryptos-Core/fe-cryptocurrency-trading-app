import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/domain/entities/managed_wallet/managed_wallet.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';

class ManagedWalletCard extends StatelessWidget {
  final ManagedWallet wallet;
  final VoidCallback? onTap;

  const ManagedWalletCard({super.key, required this.wallet, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _ChainChip(chain: wallet.chain),
                        const SizedBox(width: 8),
                        if (wallet.isDefaultDeposit)
                          _DefaultBadge(colorScheme: colorScheme),
                        if (!wallet.isActive) ...[
                          const SizedBox(width: 8),
                          _InactiveBadge(colorScheme: colorScheme),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      wallet.displayLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            wallet.truncatedAddress,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                  color: colorScheme.outline,
                                ),
                          ),
                        ),
                        InkWell(
                          onTap: () => _copyAddress(context),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(Icons.copy, size: 14, color: colorScheme.outline),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: colorScheme.outline),
            ],
          ),
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

class _ChainChip extends StatelessWidget {
  final BlockchainNetwork chain;

  const _ChainChip({required this.chain});

  @override
  Widget build(BuildContext context) {
    final isNile = chain == BlockchainNetwork.tronNile;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isNile ? Colors.teal.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isNile ? Colors.teal.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Text(
        chain.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isNile ? Colors.teal.shade700 : Colors.orange.shade700,
        ),
      ),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  final ColorScheme colorScheme;

  const _DefaultBadge({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            AppLocalizations.of(context).walletBadgeDefault,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade700),
          ),
        ],
      ),
    );
  }
}

class _InactiveBadge extends StatelessWidget {
  final ColorScheme colorScheme;

  const _InactiveBadge({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        AppLocalizations.of(context).walletBadgeInactive,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
      ),
    );
  }
}
