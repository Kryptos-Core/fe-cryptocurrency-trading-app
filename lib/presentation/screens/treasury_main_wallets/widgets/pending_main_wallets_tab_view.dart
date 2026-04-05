import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_main_wallet_provider.dart';
import 'package:crypto_trading_app/presentation/screens/treasury_main_wallets/widgets/treasury_main_wallet_card.dart';
import 'package:crypto_trading_app/presentation/screens/treasury_main_wallets/widgets/treasury_main_wallets_empty_placeholder.dart';

class PendingMainWalletsTabView extends StatelessWidget {
  const PendingMainWalletsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TreasuryMainWalletProvider>();
    final auth = context.watch<AuthProvider>();
    final canApprovePending = auth.isRiskOfficer;
    final wallets = provider.pendingWallets;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (wallets.isEmpty) {
      return RefreshIndicator(
        onRefresh: provider.refreshAllWallets,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: TreasuryMainWalletsEmptyPlaceholder(
                message: l10n.treasuryMainWalletsEmptyPending,
                icon: Icons.hourglass_empty_outlined,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refreshAllWallets,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: wallets.length,
        itemBuilder: (context, index) {
          final wallet = wallets[index];
          final created = wallet.createdAt?.toLocal();
          final locale = Localizations.localeOf(context).toString();
          final dateStr = created != null
              ? DateFormat.yMMMd(locale).add_Hm().format(created)
              : l10n.treasuryMainWalletUnknownTime;
          final isDeletionPending = wallet.status.toUpperCase() == 'PENDING_DELETION';
          return TreasuryMainWalletCard(
            wallet: wallet,
            pendingAddedAtText: dateStr,
            showApproveReject: canApprovePending,
            approveReviewTooltip: isDeletionPending
                ? l10n.treasuryMainWalletTooltipApproveDeletion
                : null,
            rejectReviewTooltip: isDeletionPending
                ? l10n.treasuryMainWalletTooltipRejectDeletion
                : null,
            onApprove: () => isDeletionPending
                ? provider.approveMainWalletDeletion(wallet.mainWalletId)
                : provider.approveWallet(wallet.mainWalletId),
            onReject: () => isDeletionPending
                ? provider.rejectMainWalletDeletion(wallet.mainWalletId)
                : provider.rejectWallet(wallet.mainWalletId),
          );
        },
      ),
    );
  }
}
