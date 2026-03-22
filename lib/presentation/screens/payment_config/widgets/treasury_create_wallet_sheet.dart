import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/app_dropdown_field.dart';

class TreasuryCreateWalletSheet extends StatefulWidget {
  const TreasuryCreateWalletSheet({super.key});

  @override
  State<TreasuryCreateWalletSheet> createState() => _TreasuryCreateWalletSheetState();
}

class _TreasuryCreateWalletSheetState extends State<TreasuryCreateWalletSheet> {
  final _formKey = GlobalKey<FormState>();
  String _chain = 'TRON_NILE'; // Default to testnet
  String _purpose = 'BOTH';
  final TextEditingController _labelCtrl = TextEditingController();

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            AppDropdownField<String>(
              value: _chain,
              labelText: l10n.treasuryChainLabel,
              items: const [
                DropdownMenuItem(value: 'TRON_NILE', child: Text('TRON_NILE')),
                DropdownMenuItem(value: 'TRON_SHASTA', child: Text('TRON_SHASTA')),
                DropdownMenuItem(value: 'TRON_MAINNET', child: Text('TRON_MAINNET')),
                DropdownMenuItem(value: 'ETH_SEPOLIA', child: Text('ETH_SEPOLIA')),
                DropdownMenuItem(value: 'ETH_MAINNET', child: Text('ETH_MAINNET')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _chain = v);
              },
            ),
            const SizedBox(height: 12),
            AppDropdownField<String>(
              value: _purpose,
              labelText: l10n.treasuryPurposeLabel,
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
                    chain: _chain,
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
