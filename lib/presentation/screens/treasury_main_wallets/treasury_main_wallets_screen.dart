import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_main_wallet_provider.dart';
import 'package:crypto_trading_app/presentation/constants/treasury_chains.dart';
import 'package:crypto_trading_app/presentation/screens/treasury_main_wallets/widgets/main_wallets_tab_view.dart';
import 'package:crypto_trading_app/presentation/screens/treasury_main_wallets/widgets/pending_main_wallets_tab_view.dart';
import 'package:crypto_trading_app/presentation/widgets/treasury_chain_dropdown.dart';

/// Matches default [IconButton] tap target so row 2 lines up with title text (not screen edge).
const double _kToolbarIconWidth = 48;

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

    final menuMaxHeight = MediaQuery.sizeOf(context).height * 0.4;
    final theme = Theme.of(context);

    final screenW = MediaQuery.sizeOf(context).width;
    final chainMaxWidth = (screenW - _kToolbarIconWidth * 2 - 16).clamp(220.0, 520.0);

    final chainDropdown = TreasuryChainDropdown(
      dense: true,
      chains: treasuryMainWalletChainsForCurrentEnv(),
      value: provider.currentChain,
      labelText: l10n.treasuryChainLabel,
      menuMaxHeight: menuMaxHeight,
      onChanged: (val) {
        if (val != null) provider.setChain(val);
      },
    );

    final tabBar = TabBar(
      controller: _tabController,
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
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(168),
        child: Material(
          elevation: theme.appBarTheme.elevation ?? 4,
          shadowColor: theme.appBarTheme.shadowColor,
          surfaceTintColor: theme.appBarTheme.surfaceTintColor,
          color: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: kToolbarHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Text(
                          l10n.treasuryMainWalletsTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: l10n.refresh,
                        onPressed: () => provider.refreshAllWallets(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: _kToolbarIconWidth,
                    end: _kToolbarIconWidth,
                    bottom: 8,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: chainMaxWidth),
                      child: chainDropdown,
                    ),
                  ),
                ),
                tabBar,
              ],
            ),
          ),
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
