import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/onchain_chain_picker_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/treasury_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/constants/treasury_chains.dart';
import 'package:crypto_trading_app/features/treasury/presentation/utils/treasury_dropdown_menu_layout.dart';
import 'package:crypto_trading_app/core/widgets/app_dropdown_field.dart';

/// Create-wallet sheet: **Chain** + **Network** options come only from
/// GET /treasury/chain-picker-options → `pickers.treasury_ops` (see
/// [OnchainChainPickerProvider.treasuryOpsChainsFromApi]).
class TreasuryCreateWalletSheet extends StatefulWidget {
  const TreasuryCreateWalletSheet({super.key});

  @override
  State<TreasuryCreateWalletSheet> createState() => _TreasuryCreateWalletSheetState();
}

class _TreasuryCreateWalletSheetState extends State<TreasuryCreateWalletSheet> {
  final _formKey = GlobalKey<FormState>();
  TreasuryChainEcosystem? _ecosystem;
  String? _network;
  String _purpose = 'BOTH';
  final TextEditingController _labelCtrl = TextEditingController();

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  Widget _buildChainListUnavailable(
    BuildContext context,
    AppLocalizations l10n,
    OnchainChainPickerProvider chainPicker,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.treasuryCreateWalletDialogTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.treasuryCreateWalletNoChainListFromApi,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () async {
              await chainPicker.ensureLoaded(force: true);
            },
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chainPicker = context.watch<OnchainChainPickerProvider>();
    final chains = chainPicker.treasuryOpsChainsFromApi;
    final apiTronDefault = chainPicker.rawOptions?.tronDefaultNetwork;

    if (chains.isEmpty) {
      return _buildChainListUnavailable(context, l10n, chainPicker);
    }

    final ecosystems = treasuryOpsEcosystems(chains);
    if (ecosystems.isEmpty) {
      return _buildChainListUnavailable(context, l10n, chainPicker);
    }

    final effectiveEco = (_ecosystem != null && ecosystems.contains(_ecosystem!))
        ? _ecosystem!
        : ecosystems.first;

    final netsForEco = treasuryOpsNetworksForEcosystem(effectiveEco, chains);
    final effectiveNet = (_network != null && netsForEco.contains(_network))
        ? _network!
        : (preferredTreasuryOpsNetworkCode(
              effectiveEco,
              netsForEco,
              apiTronDefaultNetwork: apiTronDefault,
            ) ??
            netsForEco.first);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.treasuryCreateWalletDialogTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            AppDropdownField<TreasuryChainEcosystem>(
              value: effectiveEco,
              labelText: l10n.treasuryChainLabel,
              menuMaxHeight: kTreasurySheetDropdownMenuMaxHeight,
              items: ecosystems
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(treasuryEcosystemLabel(l10n, e)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _ecosystem = v;
                  final nets = treasuryOpsNetworksForEcosystem(v, chains);
                  _network = preferredTreasuryOpsNetworkCode(
                        v,
                        nets,
                        apiTronDefaultNetwork: apiTronDefault,
                      ) ??
                      nets.first;
                });
              },
            ),
            const SizedBox(height: 12),
            AppDropdownField<String>(
              value: effectiveNet,
              labelText: l10n.treasuryNetworkLabel,
              menuMaxHeight: kTreasurySheetDropdownMenuMaxHeight,
              items: netsForEco
                  .map(
                    (code) => DropdownMenuItem(
                      value: code,
                      child: Text(treasuryChainDisplayLabel(l10n, code)),
                    ),
                  )
                  .toList(),
              onChanged: netsForEco.isEmpty
                  ? null
                  : (v) {
                      if (v == null) return;
                      setState(() => _network = v);
                    },
            ),
            const SizedBox(height: 12),
            AppDropdownField<String>(
              value: _purpose,
              labelText: l10n.treasuryPurposeLabel,
              menuMaxHeight: kTreasurySheetDropdownMenuMaxHeight,
              items: const [
                DropdownMenuItem(value: 'DEPOSIT', child: Text('DEPOSIT')),
                DropdownMenuItem(value: 'WITHDRAWAL', child: Text('WITHDRAWAL')),
                DropdownMenuItem(value: 'BOTH', child: Text('BOTH')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _purpose = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _labelCtrl,
              decoration: InputDecoration(
                labelText: l10n.treasuryLabelOptional,
                border: const OutlineInputBorder(),
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  final provider = Provider.of<TreasuryProvider>(context, listen: false);
                  final ok = await provider.createWallet(
                    chain: effectiveNet,
                    purpose: _purpose,
                    label: _labelCtrl.text.trim().isEmpty ? null : _labelCtrl.text.trim(),
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context, ok);
                },
                child: Text(l10n.treasuryCreateWalletCta),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
