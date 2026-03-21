import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/domain/entities/managed_wallet/managed_wallet.dart';
import 'package:crypto_trading_app/core/utils/currency_amount_input.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/managed_wallets_provider.dart';

/// Bottom sheet for sending TRX from a managed wallet.
class SendTrxSheet extends StatefulWidget {
  final ManagedWallet wallet;

  const SendTrxSheet({super.key, required this.wallet});

  @override
  State<SendTrxSheet> createState() => _SendTrxSheetState();
}

class _SendTrxSheetState extends State<SendTrxSheet> {
  final _formKey = GlobalKey<FormState>();
  final _toAddressController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _toAddressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _onSend(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return AlertDialog(
          icon: const Icon(Icons.send_outlined),
          title: Text(l10n.sendTrxConfirmTitle),
          content: Text(l10n.sendTrxConfirmContent(_amountController.text.trim(), _toAddressController.text.trim())),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.sendTrxConfirm)),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<ManagedWalletsProvider>();
    final error = await provider.sendTrx(
      walletId: widget.wallet.walletId,
      toAddress: _toAddressController.text.trim(),
      amount: _amountController.text.trim(),
    );

    if (!mounted) return;
    if (error == null) {
      showAppSnackBar(context, message: AppLocalizations.of(context).sendTrxSuccess, type: SnackBarType.success);
      if (mounted) Navigator.pop(context, true);
    } else {
      showAppSnackBar(context, message: error, type: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Consumer<ManagedWalletsProvider>(
        builder: (context, provider, _) {
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.send_outlined),
                    const SizedBox(width: 8),
                    Text(
                      l10n.sendTrxTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'From: ${widget.wallet.displayLabel} (${widget.wallet.truncatedAddress})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _toAddressController,
                  decoration: InputDecoration(
                    labelText: l10n.sendTrxRecipientLabel,
                    hintText: l10n.sendTrxRecipientHint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.sendTrxAddressRequired;
                    if (v.trim().length < 20) return l10n.sendTrxInvalidAddress;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: CurrencyAmountInput.withCurrencySuffix(
                    context,
                    InputDecoration(
                      labelText: l10n.sendTrxAmountLabel,
                      hintText: l10n.sendTrxAmountHint,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                    currencySymbol: 'TRX',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.sendTrxAmountRequired;
                    final amount = double.tryParse(v.trim());
                    if (amount == null || amount <= 0) return l10n.sendTrxAmountInvalid;
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: provider.isSubmitting ? null : () => _onSend(context),
                    icon: provider.isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send),
                    label: Text(provider.isSubmitting ? l10n.sendTrxSending : l10n.sendTrxSend),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
