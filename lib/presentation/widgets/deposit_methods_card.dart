import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/domain/entities/managed_wallet/deposit_method.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/managed_wallets_provider.dart';
import 'package:crypto_trading_app/presentation/providers/onchain_chain_picker_provider.dart';
import 'package:crypto_trading_app/presentation/providers/payment_config_provider.dart';
import 'package:crypto_trading_app/presentation/utils/deposit_methods_recommended_chain.dart';

/// Public widget — shows platform deposit methods (no auth required).
/// Embeds in OnchainDepositScreen above the submission form.
class DepositMethodsCard extends StatefulWidget {
  const DepositMethodsCard({super.key});

  @override
  State<DepositMethodsCard> createState() => _DepositMethodsCardState();
}

class _DepositMethodsCardState extends State<DepositMethodsCard> {
  PaymentConfigProvider? _paymentConfigProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagedWalletsProvider>().fetchDepositMethods();
      context.read<OnchainChainPickerProvider>().ensureLoaded();
      _paymentConfigProvider = context.read<PaymentConfigProvider>();
      _paymentConfigProvider!.addListener(_onPaymentConfigChanged);
    });
  }

  @override
  void dispose() {
    _paymentConfigProvider?.removeListener(_onPaymentConfigChanged);
    super.dispose();
  }

  void _onPaymentConfigChanged() {
    final event = _paymentConfigProvider?.latestEvent;
    if (event?.event == 'ACTIVATED' && mounted) {
      // Auto-refresh deposit addresses/QR codes when new config is active
      context.read<ManagedWalletsProvider>().fetchDepositMethods();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ManagedWalletsProvider, OnchainChainPickerProvider>(
      builder: (context, provider, chainPicker, _) {
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

        final headerRecommended = resolveDepositMethodsHeaderRecommendedChain(
          apiRecommended: methods.recommendedChain,
          onchainDepositWithdrawCodes: chainPicker.onchainDepositWithdrawChainCodes,
          tronDefaultFromPickerApi: chainPicker.rawOptions?.tronDefaultNetwork,
        );

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(
                recommendedChain: headerRecommended,
              ),
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
                _ChainBadge.shortTagForApiChain(recommendedChain!),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
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

    final canExpand = method.depositEnabled && method.hasAddress;

    return Column(
      children: [
        InkWell(
          onTap: canExpand ? () => setState(() => _expanded = !_expanded) : null,
          mouseCursor: canExpand ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _ChainBadge(apiChain: method.chain),
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
                                    color: method.depositEnabled ? null : colorScheme.onSurfaceVariant,
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
                      if (!method.depositEnabled)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            AppLocalizations.of(context).depositMethodUnavailable,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                          ),
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
                if (canExpand)
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 20,
                    color: colorScheme.outline,
                  ),
              ],
            ),
          ),
        ),
        if (_expanded && canExpand) _QrSection(address: method.depositAddress!),
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
  final String apiChain;

  const _ChainBadge({required this.apiChain});

  /// Compact label for headers and row badges (API chain code → short UI tag).
  static String shortTagForApiChain(String raw) => _palette(raw).label;

  /// Short tag for API chain codes (must not infer "Shasta" for every non-Nile row).
  static ({String label, Color bg, Color border, Color fg}) _palette(String raw) {
    switch (raw.toUpperCase()) {
      case 'TRON_MAINNET':
        return (
          label: 'MAINNET',
          bg: Colors.blue.shade50,
          border: Colors.blue.shade200,
          fg: Colors.blue.shade800,
        );
      case 'TRON_NILE':
        return (
          label: 'NILE',
          bg: Colors.teal.shade50,
          border: Colors.teal.shade200,
          fg: Colors.teal.shade700,
        );
      case 'TRON_SHASTA':
        return (
          label: 'SHASTA',
          bg: Colors.orange.shade50,
          border: Colors.orange.shade200,
          fg: Colors.orange.shade700,
        );
      case 'ETH_MAINNET':
        return (
          label: 'ETH',
          bg: Colors.blueGrey.shade50,
          border: Colors.blueGrey.shade200,
          fg: Colors.blueGrey.shade800,
        );
      case 'BSC_CHAPEL':
        return (
          label: 'CHAPEL',
          bg: Colors.amber.shade50,
          border: Colors.amber.shade200,
          fg: Colors.amber.shade900,
        );
      case 'BSC_MAINNET':
        return (
          label: 'BSC',
          bg: Colors.amber.shade50,
          border: Colors.amber.shade300,
          fg: Colors.amber.shade900,
        );
      case 'SOLANA_DEVNET':
        return (
          label: 'DEVNET',
          bg: Colors.purple.shade50,
          border: Colors.purple.shade200,
          fg: Colors.purple.shade800,
        );
      case 'SOLANA_MAINNET':
        return (
          label: 'SOL',
          bg: Colors.deepPurple.shade50,
          border: Colors.deepPurple.shade200,
          fg: Colors.deepPurple.shade800,
        );
      default:
        final short = raw.length > 10 ? raw.substring(0, 10) : raw;
        return (
          label: short,
          bg: Colors.grey.shade100,
          border: Colors.grey.shade300,
          fg: Colors.grey.shade800,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _palette(apiChain);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: p.bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: p.border),
      ),
      child: Text(
        p.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: p.fg,
        ),
      ),
    );
  }
}
