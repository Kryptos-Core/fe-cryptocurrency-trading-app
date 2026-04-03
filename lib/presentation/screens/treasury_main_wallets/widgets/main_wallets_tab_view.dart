import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_main_wallet_provider.dart';
import 'package:crypto_trading_app/presentation/screens/treasury_main_wallets/widgets/import_wallet_dialog.dart';
import 'package:crypto_trading_app/presentation/screens/treasury_main_wallets/widgets/treasury_main_wallet_menu_button.dart';

class MainWalletsTabView extends StatelessWidget {
  const MainWalletsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TreasuryMainWalletProvider>();
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
              padding: const EdgeInsets.all(16),
              itemCount: wallets.length,
              itemBuilder: (context, index) {
                final wallet = wallets[index];
                final labelText =
                    wallet.label ?? l10n.treasuryMainWalletLabelNone;
                return Card(
                  child: ListTile(
                    title: Text('${wallet.chain} - ${wallet.address}'),
                    subtitle: Text(
                      l10n.treasuryMainWalletCardSubtitle(
                        wallet.balance,
                        wallet.symbol,
                        labelText,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (wallet.isDefault)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 4),
                            child: Chip(
                              label: Text(l10n.treasuryMainWalletChipDefault),
                              backgroundColor: Colors.green,
                            ),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.star_border),
                            onPressed: () =>
                                provider.setDefaultWallet(wallet.mainWalletId),
                            tooltip: l10n.treasuryMainWalletTooltipSetDefault,
                          ),
                        TreasuryMainWalletMenuButton(wallet: wallet),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
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
