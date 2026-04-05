import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_main_wallet_provider.dart';
import 'package:crypto_trading_app/presentation/constants/treasury_chains.dart';
import 'package:crypto_trading_app/presentation/screens/treasury_main_wallets/widgets/main_wallets_tab_view.dart';
import 'package:crypto_trading_app/presentation/screens/treasury_main_wallets/widgets/pending_main_wallets_tab_view.dart';
import 'package:crypto_trading_app/presentation/widgets/treasury_chain_dropdown.dart';

class TreasuryMainWalletsScreen extends StatefulWidget {
  const TreasuryMainWalletsScreen({super.key});

  @override
  State<TreasuryMainWalletsScreen> createState() => _TreasuryMainWalletsScreenState();
}

class _TreasuryMainWalletsScreenState extends State<TreasuryMainWalletsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TreasuryMainWalletProvider>().refreshAllWallets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TreasuryMainWalletProvider>();
    final scheme = Theme.of(context).colorScheme;
    final menuMaxHeight = MediaQuery.sizeOf(context).height * 0.4;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.treasuryMainWalletsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
            onPressed: () => provider.refreshAllWallets(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TreasuryChainDropdown(
              chains: treasuryMainWalletChainsForCurrentEnv(),
              value: provider.currentChain,
              labelText: l10n.treasuryChainLabel,
              menuMaxHeight: menuMaxHeight,
              onChanged: (val) {
                if (val != null) provider.setChain(val);
              },
            ),
          ),
          const SizedBox(height: 8),
          Material(
            color: scheme.surface,
            child: TabBar(
              controller: _tabController,
              dividerColor: scheme.outlineVariant.withValues(alpha: 0.5),
              tabs: [
                Tab(
                  child: Text(
                    l10n.treasuryMainWalletsTabActive,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                Tab(
                  child: Text(
                    l10n.treasuryMainWalletsTabPending,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                MainWalletsTabView(),
                PendingMainWalletsTabView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
