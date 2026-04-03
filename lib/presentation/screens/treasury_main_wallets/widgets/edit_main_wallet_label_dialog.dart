import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crypto_trading_app/data/models/treasury_model.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_main_wallet_provider.dart';

class EditMainWalletLabelDialog extends StatefulWidget {
  const EditMainWalletLabelDialog({super.key, required this.wallet});

  final TreasuryMainWalletModel wallet;

  @override
  State<EditMainWalletLabelDialog> createState() => _EditMainWalletLabelDialogState();
}

class _EditMainWalletLabelDialogState extends State<EditMainWalletLabelDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.wallet.label ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<TreasuryMainWalletProvider>();
    final trimmed = _controller.text.trim();
    final label = trimmed.isEmpty ? null : trimmed;
    final ok = await provider.updateMainWalletLabel(widget.wallet.mainWalletId, label);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.treasuryMainWalletLabelUpdatedSnack)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.treasuryImportWalletErrorSnack(provider.error ?? ''),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSubmitting = context.watch<TreasuryMainWalletProvider>().isSubmitting;

    return AlertDialog(
      title: Text(l10n.treasuryMainWalletEditLabelTitle),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: l10n.treasuryImportWalletLabelOptional,
        ),
        maxLength: 100,
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: isSubmitting ? null : _save,
          child: isSubmitting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.treasuryMainWalletEditLabelSave),
        ),
      ],
    );
  }
}
