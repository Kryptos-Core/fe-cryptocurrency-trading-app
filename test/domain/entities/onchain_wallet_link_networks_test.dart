import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/onchain_wallet_link_networks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('walletConnectRelayNetworksInApiOrder', () {
    test('preserves BE sandbox order: BSC, Solana from combined list (no Sepolia)', () {
      const ordered = [
        BlockchainNetwork.bscChapel,
        BlockchainNetwork.solanaDevnet,
        BlockchainNetwork.tronNile,
      ];
      expect(
        walletConnectRelayNetworksInApiOrder(ordered),
        [
          BlockchainNetwork.bscChapel,
          BlockchainNetwork.solanaDevnet,
        ],
      );
    });

    test('production mainnets: three WC families before Tron', () {
      const ordered = [
        BlockchainNetwork.ethMainnet,
        BlockchainNetwork.bscMainnet,
        BlockchainNetwork.solanaMainnet,
        BlockchainNetwork.tronMainnet,
      ];
      expect(
        walletConnectRelayNetworksInApiOrder(ordered),
        [
          BlockchainNetwork.ethMainnet,
          BlockchainNetwork.bscMainnet,
          BlockchainNetwork.solanaMainnet,
        ],
      );
    });
  });

  group('tronExtensionNetworksInApiOrder', () {
    test('extracts Tron rows in same order as deposit/withdraw list', () {
      const ordered = [
        BlockchainNetwork.bscChapel,
        BlockchainNetwork.solanaDevnet,
        BlockchainNetwork.tronNile,
      ];
      expect(
        tronExtensionNetworksInApiOrder(ordered),
        [BlockchainNetwork.tronNile],
      );
    });
  });
}
