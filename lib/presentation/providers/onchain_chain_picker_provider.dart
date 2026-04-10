import 'package:flutter/foundation.dart';

import 'package:crypto_trading_app/data/datasources/treasury_remote_datasource.dart';
import 'package:crypto_trading_app/data/models/chain_picker_options_model.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/onchain_wallet_link_networks.dart';
import 'package:crypto_trading_app/presentation/constants/treasury_chains.dart';

/// Loads [ChainPickerOptionsModel] from GET /treasury/chain-picker-options.
/// All getters fall back to [treasury_chains.dart] when the API fails or returns empty lists.
class OnchainChainPickerProvider extends ChangeNotifier {
  OnchainChainPickerProvider({required TreasuryRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final TreasuryRemoteDataSource _dataSource;
  ChainPickerOptionsModel? _options;
  bool _loadAttempted = false;

  ChainPickerOptionsModel? get rawOptions => _options;

  Future<void> ensureLoaded({bool force = false}) async {
    if (_loadAttempted && !force) return;
    _loadAttempted = true;
    try {
      _options = await _dataSource.getChainPickerOptions();
    } catch (e, st) {
      _options = null;
      debugPrint('OnchainChainPickerProvider: API failed, using local fallback ($e)\n$st');
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

  List<String> get treasuryMainWalletChains =>
      _orFallback(_options?.treasuryMainWallet ?? const [], treasuryMainWalletChainsForCurrentEnv);

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

  /// Same chain universe as nạp/rút — EVM + Solana subset for WalletConnect (BE order).
  List<BlockchainNetwork> get walletConnectLinkNetworksFromApi =>
      walletConnectRelayNetworksInApiOrder(onchainDepositWithdrawNetworks);

  /// Tron subset in BE order (extension / TronLink), aligned with nạp/rút list.
  List<BlockchainNetwork> get tronExtensionLinkNetworksFromApi =>
      tronExtensionNetworksInApiOrder(onchainDepositWithdrawNetworks);
}
