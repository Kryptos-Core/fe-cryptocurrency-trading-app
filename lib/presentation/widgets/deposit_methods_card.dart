import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/domain/entities/managed_wallet/deposit_method.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/managed_wallets_provider.dart';

/// Public widget — shows platform deposit methods (no auth required).
/// Embeds in OnchainDepositScreen above the submission form.
class DepositMethodsCard extends StatefulWidget {
  const DepositMethodsCard({super.key});

  @override
  State<DepositMethodsCard> createState() => _DepositMethodsCardState();
}

class _DepositMethodsCardState extends State<DepositMethodsCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagedWalletsProvider>().fetchDepositMethods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManagedWalletsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.depositMethods == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final methods = provider.depositMethods;
        if (methods == null || methods.methods.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(recommendedChain: methods.recommendedChain),
              const Divider(height: 1),
              ...methods.methods.map(
                (method) => _DepositMethodTile(method: method),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CardHeader extends StatelessWidget {
  final String? recommendedChain;

  const _CardHeader({this.recommendedChain});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 20, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context).depositMethodsTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
          ),
          if (recommendedChain != null) ...[
            const Spacer(),
            Chip(
              label: Text(
                recommendedChain!,
                style: const TextStyle(fontSize: 11),
              ),
              avatar: const Icon(Icons.star, size: 14),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }
}

class _DepositMethodTile extends StatefulWidget {
  final DepositMethod method;

  const _DepositMethodTile({required this.method});

  @override
  State<_DepositMethodTile> createState() => _DepositMethodTileState();
}

class _DepositMethodTileState extends State<_DepositMethodTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final method = widget.method;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _ChainBadge(chain: method.chain),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              method.label,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          if (method.isRecommended)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                AppLocalizations.of(context).depositMethodRecommended,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (method.hasAddress)
                        Text(
                          method.truncatedAddress,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                                fontFamily: 'monospace',
                              ),
                        ),
                    ],
                  ),
                ),
                if (method.hasAddress)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: AppLocalizations.of(context).copyAddressTooltip,
                    onPressed: () => _copyAddress(context, method.depositAddress!),
                    visualDensity: VisualDensity.compact,
                  ),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 20,
                  color: colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
        if (_expanded && method.hasAddress) _QrSection(address: method.depositAddress!),
        const Divider(height: 1),
      ],
    );
  }

  void _copyAddress(BuildContext context, String address) {
    Clipboard.setData(ClipboardData(text: address));
    showAppSnackBar(
      context,
      message: AppLocalizations.of(context).createWalletAddressCopied,
      type: SnackBarType.success,
      duration: const Duration(seconds: 2),
    );
  }
}

class _QrSection extends StatelessWidget {
  final String address;

  const _QrSection({required this.address});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: QrImageView(
                data: address,
                version: QrVersions.auto,
                size: 140,
              ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              address,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChainBadge extends StatelessWidget {
  final String chain;

  const _ChainBadge({required this.chain});

  @override
  Widget build(BuildContext context) {
    final isNile = chain.contains('NILE');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isNile ? Colors.teal.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isNile ? Colors.teal.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Text(
        isNile ? 'NILE' : 'SHASTA',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isNile ? Colors.teal.shade700 : Colors.orange.shade700,
        ),
      ),
    );
  }
}
