import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/treasury_main_wallet_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/screens/treasury_main_wallets/treasury_main_wallets_panel.dart';

/// Standalone route (`/treasury`) — same content as Payment config → Master wallet tab.
class TreasuryMainWalletsScreen extends StatelessWidget {
  const TreasuryMainWalletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.paymentConfigMasterWalletTab),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
            onPressed: () => context.read<TreasuryMainWalletProvider>().refreshAllWallets(),
          ),
        ],
      ),
      body: const TreasuryMainWalletsPanel(),
    );
  }
}
