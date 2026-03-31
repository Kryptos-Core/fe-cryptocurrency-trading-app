import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_main_wallet_provider.dart';

class PendingMainWalletsTabView extends StatefulWidget {
  const PendingMainWalletsTabView({super.key});

  @override
  State<PendingMainWalletsTabView> createState() => _PendingMainWalletsTabViewState();
}

class _PendingMainWalletsTabViewState extends State<PendingMainWalletsTabView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TreasuryMainWalletProvider>().loadPendingWallets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TreasuryMainWalletProvider>();
    final wallets = provider.pendingWallets;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (wallets.isEmpty) {
      return Center(child: Text(l10n.treasuryMainWalletsEmptyPending));
    }

    return RefreshIndicator(
      onRefresh: provider.loadPendingWallets,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: wallets.length,
        itemBuilder: (context, index) {
          final wallet = wallets[index];
          final created = wallet.createdAt?.toLocal();
          final locale = Localizations.localeOf(context).toString();
          final dateStr = created != null
              ? DateFormat.yMMMd(locale).add_Hm().format(created)
              : l10n.treasuryMainWalletUnknownTime;
          return Card(
            child: ListTile(
              title: Text('${wallet.chain} - ${wallet.address}'),
              subtitle: Text(l10n.treasuryMainWalletPendingSubtitle(dateStr)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    tooltip: l10n.treasuryMainWalletTooltipApprove,
                    onPressed: () {
                      provider.approveWallet(wallet.mainWalletId);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    tooltip: l10n.treasuryMainWalletTooltipReject,
                    onPressed: () {
                      provider.rejectWallet(wallet.mainWalletId);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
