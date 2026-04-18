import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/treasury_main_wallets_ui_policy.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/onchain_chain_picker_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/treasury_main_wallet_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/constants/treasury_chains.dart';
import 'package:crypto_trading_app/features/treasury/presentation/screens/treasury_main_wallets/widgets/main_wallets_tab_view.dart';
import 'package:crypto_trading_app/features/treasury/presentation/screens/treasury_main_wallets/widgets/pending_main_wallets_tab_view.dart';
import 'package:crypto_trading_app/features/treasury/presentation/widgets/treasury_chain_dropdown.dart';

class TreasuryMainWalletsScreen extends StatefulWidget {
  const TreasuryMainWalletsScreen({super.key});

  @override
  State<TreasuryMainWalletsScreen> createState() => _TreasuryMainWalletsScreenState();
}

class _TreasuryMainWalletsScreenState extends State<TreasuryMainWalletsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final chainPicker = context.read<OnchainChainPickerProvider>();
      final mainWallet = context.read<TreasuryMainWalletProvider>();
      await chainPicker.ensureLoaded();
      if (!mounted) return;
      final allowed = chainPicker.treasuryMainWalletChains;
      if (allowed.isNotEmpty && !allowed.contains(mainWallet.currentChain)) {
        mainWallet.setChain(allowed.first);
      }
      if (!mounted) return;
      await mainWallet.refreshAllWallets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TreasuryMainWalletProvider>();
    final auth = context.watch<AuthProvider>();
    final chainPicker = context.watch<OnchainChainPickerProvider>();
    final mainWalletChains = chainPicker.treasuryMainWalletChains;
    final scheme = Theme.of(context).colorScheme;
    final menuMaxHeight = MediaQuery.sizeOf(context).height * 0.4;
    final showPendingTab = treasuryMainWalletsShowsPendingTab(auth.role);

    final chainDropdown = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TreasuryChainDropdown(
        chains: mainWalletChains,
        value: provider.currentChain,
        labelText: l10n.treasuryChainLabel,
        menuMaxHeight: menuMaxHeight,
        displayLabelForChain: treasuryWalletCreationDisplayLabel,
        onChanged: (val) {
          if (val != null) provider.setChain(val);
        },
      ),
    );

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
      body: showPendingTab
          ? DefaultTabController(
              length: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  chainDropdown,
                  const SizedBox(height: 8),
                  Material(
                    color: scheme.surface,
                    child: TabBar(
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
                  const Expanded(
                    child: TabBarView(
                      children: [
                        MainWalletsTabView(),
                        PendingMainWalletsTabView(),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                chainDropdown,
                const SizedBox(height: 8),
                const Expanded(child: MainWalletsTabView()),
              ],
            ),
    );
  }
}
