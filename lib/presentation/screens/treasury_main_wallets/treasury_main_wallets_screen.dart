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

class _TreasuryMainWalletsScreenState extends State<TreasuryMainWalletsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

    final menuMaxHeight = MediaQuery.sizeOf(context).height * 0.4;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Text(l10n.treasuryMainWalletsTitle),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 4),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
                child: TreasuryChainDropdown(
                  chains: kTreasuryMainWalletChainValues,
                  value: provider.currentChain,
                  labelText: l10n.treasuryChainLabel,
                  menuMaxHeight: menuMaxHeight,
                  onChanged: (val) {
                    if (val != null) provider.setChain(val);
                  },
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
            onPressed: () {
              provider.loadMainWallets();
              provider.loadPendingWallets();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.treasuryMainWalletsTabActive),
            Tab(text: l10n.treasuryMainWalletsTabPending),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MainWalletsTabView(),
          PendingMainWalletsTabView(),
        ],
      ),
    );
  }
}
