import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';

/// WalletConnect relay: EVM (CAIP-2) + Solana + Tron on native (QR → TronLink mobile).
///
/// Same technical split as [LinkWalletDialog]: web still uses TronLink extension flow separately.
List<BlockchainNetwork> walletConnectRelayNetworksInApiOrder(
  List<BlockchainNetwork> onchainDepositWithdrawInOrder,
) {
  return onchainDepositWithdrawInOrder
      .where(
        (n) =>
            n.evmCaip2 != null ||
            n.networkFamily == OnChainNetworkFamily.solana ||
            (!kIsWeb && n.isTronFamily),
      )
      .toList(growable: false);
}

/// TronLink extension flow (web only) — Tron variants from the BE-ordered list.
///
/// On native, Tron is offered via [walletConnectRelayNetworksInApiOrder] instead (no duplicate chips).
List<BlockchainNetwork> tronExtensionNetworksInApiOrder(
  List<BlockchainNetwork> onchainDepositWithdrawInOrder,
) {
  if (!kIsWeb) return const [];
  return onchainDepositWithdrawInOrder
      .where((n) => n.isTronFamily)
      .toList(growable: false);
}
