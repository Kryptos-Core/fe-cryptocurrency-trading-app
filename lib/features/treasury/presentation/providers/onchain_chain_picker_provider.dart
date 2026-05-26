import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crypto_trading_app/core/services/chain_picker_options_cache.dart';
import 'package:crypto_trading_app/features/treasury/domain/entities/chain_network_catalog_item_model.dart';
import 'package:crypto_trading_app/features/treasury/domain/entities/chain_picker_options_model.dart';
import 'package:crypto_trading_app/features/treasury/domain/repositories/treasury_repository.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/onchain_wallet_link_networks.dart';
import 'package:crypto_trading_app/features/treasury/presentation/constants/treasury_chains.dart';

/// Loads [ChainPickerOptionsModel] from GET /treasury/chain-picker-options.
/// On failure, reuses the last successful response from [ChainPickerOptionsCache].
/// Getters fall back to [treasury_chains.dart] only when there is no API data and no cache.
class OnchainChainPickerProvider extends ChangeNotifier {
  OnchainChainPickerProvider({
    required TreasuryRepository repository,
    required SharedPreferences prefs,
  })  : _repository = repository,
        _cache = ChainPickerOptionsCache(prefs);

  final TreasuryRepository _repository;
  final ChainPickerOptionsCache _cache;
  ChainPickerOptionsModel? _options;
  bool _loadAttempted = false;

  ChainPickerOptionsModel? get rawOptions => _options;

  Future<void> ensureLoaded({bool force = false}) async {
    if (_loadAttempted && !force) return;
    _loadAttempted = true;
    try {
      _options = await _repository.getChainPickerOptions();
      final opts = _options;
      if (opts != null) {
        await _cache.write(opts);
      }
    } catch (e, st) {
      _options = _cache.readSync();
      if (_options != null) {
        debugPrint(
          'OnchainChainPickerProvider: API failed, using cached chain-picker-options ($e)',
        );
      } else {
        debugPrint(
          'OnchainChainPickerProvider: API failed, no cache — treasury_chains fallback ($e)\n$st',
        );
      }
    }
    notifyListeners();
  }

  void invalidate() {
    _options = null;
    _loadAttempted = false;
    notifyListeners();
  }

  List<String> _orFallback(List<String> fromApi, List<String> Function() fallback) {
    if (fromApi.isNotEmpty) return fromApi;
    return fallback();
  }

  List<String> get treasuryOpsChains =>
      _orFallback(_options?.treasuryOps ?? const [], treasuryOpsWalletCreationChainsForCurrentEnv);

  /// `pickers.treasury_ops` from GET /treasury/chain-picker-options (or disk cache).
  /// No env-based fallback — use for operator UI that must mirror the server contract.
  List<String> get treasuryOpsChainsFromApi => _options?.treasuryOps ?? const [];

  /// `pickers.treasury_e2e` — chains for E2E config form (no env fallback).
  List<String> get treasuryE2eChainsFromApi => _options?.treasuryE2e ?? const [];

  List<String> get treasuryMainWalletChains =>
      _orFallback(_options?.treasuryMainWallet ?? const [], treasuryMainWalletChainsForCurrentEnv);

  /// `pickers.treasury_main_wallet` from GET /treasury/chain-picker-options (or cache); no env fallback.
  List<String> get treasuryMainWalletChainsFromApi => _options?.treasuryMainWallet ?? const [];

  List<String> get treasuryHistoryFilterChains =>
      _orFallback(_options?.treasuryHistoryFilter ?? const [], treasuryHistoryFilterChainsForCurrentEnv);

  List<String> get withdrawalAdminFilterChains =>
      _orFallback(_options?.withdrawalAdminFilter ?? const [], withdrawalFilterChainsForCurrentEnv);

  List<String> get managedWalletsChains =>
      _orFallback(_options?.managedWallets ?? const [], managedWalletsChainsForCurrentEnv);

  List<String> _onchainDepositWithdrawCodesFallback() => onchainDepositWithdrawNetworksForCurrentEnv()
      .map((n) => n.apiValue)
      .toList(growable: false);

  List<String> get onchainDepositWithdrawChainCodes => _orFallback(
        _options?.onchainDepositWithdraw ?? const [],
        _onchainDepositWithdrawCodesFallback,
      );

  /// Resolved enums for user on-chain deposit / withdraw tabs (from API codes).
  List<BlockchainNetwork> get onchainDepositWithdrawNetworks {
    final codes = onchainDepositWithdrawChainCodes;
    final out = <BlockchainNetwork>[];
    for (final c in codes) {
      final n = BlockchainNetworkX.tryFromApiValue(c);
      if (n != null) out.add(n);
    }
    if (out.isNotEmpty) return out;
    return onchainDepositWithdrawNetworksForCurrentEnv();
  }

  /// Same chain universe as nap/rút — EVM + Solana subset for WalletConnect (BE order).
  List<BlockchainNetwork> get walletConnectLinkNetworksFromApi =>
      walletConnectRelayNetworksInApiOrder(onchainDepositWithdrawNetworks);

  /// Tron subset in BE order (extension / TronLink), aligned with nap/rút list.
  List<BlockchainNetwork> get tronExtensionLinkNetworksFromApi =>
      tronExtensionNetworksInApiOrder(onchainDepositWithdrawNetworks);

  /// Full network sheet from API (includes TON with `deposit: false` until Phase 2).
  List<ChainNetworkCatalogItemModel> get networkCatalog {
    final c = _options?.networkCatalog;
    if (c != null && c.isNotEmpty) return c;
    return const [];
  }

  /// Map of chain code → blockchain label from BE.
  /// Single source of truth for all chain dropdown labels.
  Map<String, String> get chainLabels => _options?.chainLabels ?? const {};

  /// Whether the UI should show the network dropdown (two-dropdown UX).
  /// Server returns `false` in production — network is implicit mainnet.
  bool get showNetworkSelector => _options?.showNetworkSelector ?? true;

  ChainNetworkCatalogItemModel? catalogItemForCode(String code) {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return null;
    for (final item in networkCatalog) {
      if (item.code.trim().toUpperCase() == normalized) return item;
    }
    return null;
  }

  ChainNetworkCatalogItemModel? catalogItemForNetwork(
    BlockchainNetwork network,
  ) =>
      catalogItemForCode(network.apiValue);

  String blockchainLabelForNetwork(BlockchainNetwork network) {
    final label = catalogItemForNetwork(network)?.blockchainLabel.trim();
    if (label != null && label.isNotEmpty) return label;
    return network.label;
  }

  String networkLabelForNetwork(BlockchainNetwork network) {
    final label = catalogItemForNetwork(network)?.networkLabel.trim();
    if (label != null && label.isNotEmpty) return label;
    return network.label;
  }

  String displayLabelForNetwork(
    BlockchainNetwork network, {
    bool compact = false,
  }) {
    return displayLabelForCode(network.apiValue, compact: compact);
  }

  /// Returns the user-facing label for a chain code.
  ///
  /// Priority:
  /// 1. [chainLabels] map from BE — contains pre-computed `blockchainLabel` per chain,
  ///    already stripped of network suffix in production mode.
  /// 2. Fallback to [treasuryChainsUseMainnetOnly] mode:
  ///    - production: return blockchain name only (e.g. "Tron", "Ethereum")
  ///    - sandbox: return full label (e.g. "Tron (mainnet)", "Ethereum (mainnet)")
  String displayLabelForCode(
    String code, {
    bool compact = false,
  }) {
    // Primary: use blockchainLabel from BE API.
    final apiLabel = chainLabels[code];
    if (apiLabel != null && apiLabel.trim().isNotEmpty) {
      return apiLabel.trim();
    }

    // Fallback: resolve from local network enum.
    final network = BlockchainNetworkX.tryFromApiValue(code);
    if (network == null) return code;

    // production mode: blockchain name only, no network suffix.
    if (treasuryChainsUseMainnetOnly) {
      return network.label;
    }

    // sandbox mode: show full label (with network).
    if (compact) {
      return network.label.replaceAll(RegExp(r' \(mainnet\)$', caseSensitive: false), '');
    }
    return network.label;
  }
}
