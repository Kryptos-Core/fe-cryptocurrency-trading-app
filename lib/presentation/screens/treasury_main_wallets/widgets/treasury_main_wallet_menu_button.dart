import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crypto_trading_app/data/models/treasury_model.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_main_wallet_provider.dart';
import 'package:crypto_trading_app/presentation/screens/treasury_main_wallets/widgets/copy_main_wallet_private_key_dialog.dart';
import 'package:crypto_trading_app/presentation/screens/treasury_main_wallets/widgets/edit_main_wallet_label_dialog.dart';

class TreasuryMainWalletMenuButton extends StatelessWidget {
  const TreasuryMainWalletMenuButton({super.key, required this.wallet});

  final TreasuryMainWalletModel wallet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        if (value == 'copy') {
          await showDialog<void>(
            context: context,
            builder: (_) => CopyMainWalletPrivateKeyDialog(mainWalletId: wallet.mainWalletId),
          );
        } else if (value == 'edit') {
          await showDialog<void>(
            context: context,
            builder: (_) => EditMainWalletLabelDialog(wallet: wallet),
          );
        } else if (value == 'delete') {
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
          final provider = context.read<TreasuryMainWalletProvider>();
          final ok = await provider.deleteMainWallet(wallet.mainWalletId);
          if (!context.mounted) return;
          if (ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.treasuryMainWalletDeleteSuccessSnack)),
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
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              const Icon(Icons.copy, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.treasuryMainWalletMenuCopyPrivateKey)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.treasuryMainWalletMenuEditLabel)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.treasuryMainWalletMenuDelete,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
