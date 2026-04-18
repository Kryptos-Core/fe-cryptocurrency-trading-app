import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';

/// WalletConnect relay: EVM (CAIP-2) + Solana — same technical split as [LinkWalletDialog].
List<BlockchainNetwork> walletConnectRelayNetworksInApiOrder(
  List<BlockchainNetwork> onchainDepositWithdrawInOrder,
) {
  return onchainDepositWithdrawInOrder
      .where(
        (n) =>
            n.evmCaip2 != null ||
            n.networkFamily == OnChainNetworkFamily.solana,
      )
      .toList(growable: false);
}

/// TronLink / extension flow — rows are whatever Tron variants appear in the BE-ordered list.
List<BlockchainNetwork> tronExtensionNetworksInApiOrder(
  List<BlockchainNetwork> onchainDepositWithdrawInOrder,
) {
  return onchainDepositWithdrawInOrder
      .where((n) => n.isTronFamily)
      .toList(growable: false);
}
