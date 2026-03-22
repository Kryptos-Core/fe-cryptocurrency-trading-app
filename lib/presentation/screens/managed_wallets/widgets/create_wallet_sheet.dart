import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/domain/entities/managed_wallet/managed_wallet.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/managed_wallets_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/app_dropdown_field.dart';

/// Bottom sheet for creating a new treasury wallet.
/// Shows chain selector + optional label → generates wallet on-chain.
/// On success shows the new address with copy button.
class CreateWalletSheet extends StatefulWidget {
  const CreateWalletSheet({super.key});

  @override
  State<CreateWalletSheet> createState() => _CreateWalletSheetState();
}

class _CreateWalletSheetState extends State<CreateWalletSheet> {
  static const _supportedChains = [
    ('TRON_NILE', 'Tron Nile Testnet'),
    ('TRON_SHASTA', 'Tron Shasta Testnet'),
  ];

  String _selectedChain = 'TRON_NILE';
  final _labelController = TextEditingController();
  ManagedWallet? _createdWallet;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final provider = context.read<ManagedWalletsProvider>();
    final wallet = await provider.createWallet(
      chain: _selectedChain,
      label: _labelController.text.trim(),
    );
    if (!mounted) return;
    if (wallet != null) {
      setState(() => _createdWallet = wallet);
    } else {
      final errorMsg = provider.error ?? AppLocalizations.of(context).createWalletFailed;
      if (mounted) {
        showAppSnackBar(context, message: errorMsg, type: SnackBarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: _createdWallet != null
          ? _SuccessView(wallet: _createdWallet!, onDone: () => Navigator.pop(context))
          : _FormView(
              selectedChain: _selectedChain,
              labelController: _labelController,
              chains: _supportedChains,
              colorScheme: colorScheme,
              onChainChanged: (v) => setState(() => _selectedChain = v ?? _selectedChain),
              onGenerate: _generate,
            ),
    );
  }
}

class _FormView extends StatelessWidget {
  final String selectedChain;
  final TextEditingController labelController;
  final List<(String, String)> chains;
  final ColorScheme colorScheme;
  final ValueChanged<String?> onChainChanged;
  final VoidCallback onGenerate;

  const _FormView({
    required this.selectedChain,
    required this.labelController,
    required this.chains,
    required this.colorScheme,
    required this.onChainChanged,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<ManagedWalletsProvider>(
      builder: (context, provider, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.add_card_outlined),
                const SizedBox(width: 8),
                Text(
                  l10n.createWalletTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppDropdownField<String>(
              value: selectedChain,
              labelText: l10n.createWalletBlockchainLabel,
              items: chains
                  .map(
                    (chain) => DropdownMenuItem(
                      value: chain.$1,
                      child: Text(chain.$2),
                    ),
                  )
                  .toList(),
              onChanged: onChainChanged,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: labelController,
              decoration: InputDecoration(
                labelText: l10n.createWalletLabelField,
                hintText: l10n.createWalletLabelHint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: provider.isSubmitting ? null : onGenerate,
                icon: provider.isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.generating_tokens),
                label: Text(provider.isSubmitting ? l10n.createWalletGenerating : l10n.createWalletGenerate),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.createWalletSecurityNote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            ),
          ],
        );
      },
    );
  }
}

class _SuccessView extends StatelessWidget {
  final ManagedWallet wallet;
  final VoidCallback onDone;

  const _SuccessView({required this.wallet, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_outline, size: 56, color: Colors.green.shade600),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context).createWalletSuccess,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          wallet.chain.label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).createWalletAddressLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.outline),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      wallet.address,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: wallet.address));
                      showAppSnackBar(
                        context,
                        message: AppLocalizations.of(context).createWalletAddressCopied,
                        type: SnackBarType.success,
                        duration: const Duration(seconds: 2),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onDone,
            child: Text(AppLocalizations.of(context).createWalletDone),
          ),
        ),
      ],
    );
  }
}
