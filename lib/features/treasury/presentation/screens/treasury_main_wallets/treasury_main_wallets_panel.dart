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
import 'package:crypto_trading_app/features/treasury/presentation/utils/treasury_dropdown_menu_layout.dart';
import 'package:crypto_trading_app/core/widgets/app_dropdown_field.dart';

/// Whether the UI should hide chain/network selectors and default to mainnet automatically.
/// When true (ONCHAIN_OPERATOR_MODE=production), the ecosystem/network dropdowns are
/// replaced with a static label showing the current ecosystem name.
bool get _treasuryHidesNetworkSelector => treasuryChainsUseMainnetOnly;

/// Main / hot wallet UI: **Chain** (ecosystem) + **Network** pickers from
/// GET /treasury/chain-picker-options → `pickers.treasury_main_wallet` only.
class TreasuryMainWalletsPanel extends StatefulWidget {
  const TreasuryMainWalletsPanel({super.key});

  @override
  State<TreasuryMainWalletsPanel> createState() => _TreasuryMainWalletsPanelState();
}

class _TreasuryMainWalletsPanelState extends State<TreasuryMainWalletsPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final chainPicker = context.read<OnchainChainPickerProvider>();
      final mainWallet = context.read<TreasuryMainWalletProvider>();
      await chainPicker.ensureLoaded();
      if (!mounted) return;
      final allowed = chainPicker.treasuryMainWalletChainsFromApi;
      if (allowed.isNotEmpty && !allowed.contains(mainWallet.currentChain)) {
        mainWallet.setChain(allowed.first);
      }
      if (!mounted) return;
      await mainWallet.refreshAllWallets();
    });
  }

  Widget _buildPickerUnavailable(
    BuildContext context,
    AppLocalizations l10n,
    OnchainChainPickerProvider chainPicker,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.treasuryCreateWalletNoChainListFromApi,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () async {
              await chainPicker.ensureLoaded(force: true);
            },
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<TreasuryMainWalletProvider>();
    final auth = context.watch<AuthProvider>();
    final chainPicker = context.watch<OnchainChainPickerProvider>();
    final chains = chainPicker.treasuryMainWalletChainsFromApi;
    final apiTronDefault = chainPicker.rawOptions?.tronDefaultNetwork;
    final scheme = Theme.of(context).colorScheme;
    final showPendingTab = treasuryMainWalletsShowsPendingTab(auth.role);
    final menuMax = defaultTreasuryDropdownMenuMaxHeight(MediaQuery.sizeOf(context).height);

    if (chains.isEmpty) {
      return showPendingTab
          ? DefaultTabController(
              length: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPickerUnavailable(context, l10n, chainPicker),
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
                _buildPickerUnavailable(context, l10n, chainPicker),
                const Expanded(child: MainWalletsTabView()),
              ],
            );
    }

    final ecosystems = treasuryOpsEcosystems(chains);
    if (ecosystems.isEmpty) {
      return _buildPickerUnavailable(context, l10n, chainPicker);
    }

    TreasuryChainEcosystem effectiveEco;
    try {
      effectiveEco = ecosystemForChain(provider.currentChain);
    } catch (_) {
      effectiveEco = ecosystems.first;
    }
    if (!ecosystems.contains(effectiveEco)) {
      effectiveEco = ecosystems.first;
    }

    final netsForEco = treasuryOpsNetworksForEcosystem(effectiveEco, chains);
    var effectiveNet = provider.currentChain;
    if (!netsForEco.contains(effectiveNet)) {
      effectiveNet = preferredTreasuryOpsNetworkCode(
            effectiveEco,
            netsForEco,
            apiTronDefaultNetwork: apiTronDefault,
          ) ??
          netsForEco.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (provider.currentChain != effectiveNet) {
          provider.setChain(effectiveNet);
        }
      });
    }

    // In production (ONCHAIN_OPERATOR_MODE=production), the network is implicit mainnet.
    // Only the ecosystem dropdown is shown; the network dropdown is removed.
    // In sandbox, both ecosystem + network dropdowns are shown.
    final chainSelectors = _treasuryHidesNetworkSelector
        ? Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AppDropdownField<TreasuryChainEcosystem>(
              value: effectiveEco,
              labelText: l10n.treasuryChainLabel,
              menuMaxHeight: menuMax,
              items: ecosystems
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(treasuryEcosystemLabel(l10n, e)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                final nets = treasuryOpsNetworksForEcosystem(v, chains);
                final net = preferredTreasuryOpsNetworkCode(
                      v,
                      nets,
                      apiTronDefaultNetwork: apiTronDefault,
                    ) ??
                    nets.first;
                provider.setChain(net);
              },
            ),
          )
        : Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppDropdownField<TreasuryChainEcosystem>(
                  value: effectiveEco,
                  labelText: l10n.treasuryChainLabel,
                  menuMaxHeight: menuMax,
                  items: ecosystems
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(treasuryEcosystemLabel(l10n, e)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    final nets = treasuryOpsNetworksForEcosystem(v, chains);
                    final net = preferredTreasuryOpsNetworkCode(
                          v,
                          nets,
                          apiTronDefaultNetwork: apiTronDefault,
                        ) ??
                        nets.first;
                    provider.setChain(net);
                  },
                ),
                const SizedBox(height: 12),
                AppDropdownField<String>(
                  value: effectiveNet,
                  labelText: l10n.treasuryNetworkLabel,
                  menuMaxHeight: menuMax,
                  items: netsForEco
                      .map(
                        (code) => DropdownMenuItem(
                          value: code,
                          child: Text(
                            treasuryChainDisplayLabel(
                              l10n,
                              code,
                              apiLabelResolver: context.read<OnchainChainPickerProvider>().displayLabelForCode,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: netsForEco.isEmpty
                      ? null
                      : (v) {
                          if (v == null) return;
                          provider.setChain(v);
                        },
                ),
              ],
            ),
          );

    return showPendingTab
        ? DefaultTabController(
            length: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                chainSelectors,
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
              chainSelectors,
              const SizedBox(height: 8),
              const Expanded(child: MainWalletsTabView()),
            ],
          );
  }
}

