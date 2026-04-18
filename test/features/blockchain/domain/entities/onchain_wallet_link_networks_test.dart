import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/onchain_wallet_link_networks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('walletConnectRelayNetworksInApiOrder', () {
    test('preserves BE sandbox order: BSC, Solana, Tron (native includes Tron for WC QR)', () {
      const ordered = [
        BlockchainNetwork.bscChapel,
        BlockchainNetwork.solanaDevnet,
        BlockchainNetwork.tronNile,
      ];
      expect(
        walletConnectRelayNetworksInApiOrder(ordered),
        ordered,
      );
    });

    test('production mainnets: EVM + Solana + Tron in API order', () {
      const ordered = [
        BlockchainNetwork.ethMainnet,
        BlockchainNetwork.bscMainnet,
        BlockchainNetwork.solanaMainnet,
        BlockchainNetwork.tronMainnet,
      ];
      expect(
        walletConnectRelayNetworksInApiOrder(ordered),
        ordered,
      );
    });
  });

  group('tronExtensionNetworksInApiOrder', () {
    test('on VM/native (kIsWeb false) returns empty — Tron only in WC list', () {
      const ordered = [
        BlockchainNetwork.bscChapel,
        BlockchainNetwork.solanaDevnet,
        BlockchainNetwork.tronNile,
      ];
      expect(tronExtensionNetworksInApiOrder(ordered), <BlockchainNetwork>[]);
    });
  });
}
