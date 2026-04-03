import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_main_wallet_provider.dart';
import 'package:crypto_trading_app/presentation/screens/treasury_main_wallets/widgets/import_wallet_dialog.dart';
import 'package:crypto_trading_app/presentation/screens/treasury_main_wallets/widgets/treasury_main_wallet_card.dart';

class MainWalletsTabView extends StatelessWidget {
  const MainWalletsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TreasuryMainWalletProvider>();
    final auth = context.watch<AuthProvider>();
    final canFinanceTreasuryOps = auth.canManagePaymentConfigs;
    final wallets = provider.mainWallets;

    return Stack(
      children: [
        if (provider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (wallets.isEmpty)
          Center(child: Text(l10n.treasuryMainWalletsEmptyActive))
        else
          RefreshIndicator(
            onRefresh: provider.refreshAllWallets,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
              itemCount: wallets.length,
              itemBuilder: (context, index) {
                return TreasuryMainWalletCard(wallet: wallets[index]);
              },
            ),
          ),
        if (canFinanceTreasuryOps)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'importWalletBtn',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const ImportWalletDialog(),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }
}
