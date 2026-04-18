import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BlockchainNetworkX.resolveFromApiValue', () {
    test('returns fallback when code is unknown', () {
      expect(
        BlockchainNetworkX.resolveFromApiValue(
          'CHAIN_NOT_IN_APP_YET',
          fallback: BlockchainNetwork.ethMainnet,
        ),
        BlockchainNetwork.ethMainnet,
      );
    });

    test('returns parsed network when code is known', () {
      expect(
        BlockchainNetworkX.resolveFromApiValue(
          'BSC_CHAPEL',
          fallback: BlockchainNetwork.ethMainnet,
        ),
        BlockchainNetwork.bscChapel,
      );
    });

    test('null or empty raw uses fallback', () {
      expect(
        BlockchainNetworkX.resolveFromApiValue(
          null,
          fallback: BlockchainNetwork.solanaDevnet,
        ),
        BlockchainNetwork.solanaDevnet,
      );
      expect(
        BlockchainNetworkX.resolveFromApiValue(
          '',
          fallback: BlockchainNetwork.solanaDevnet,
        ),
        BlockchainNetwork.solanaDevnet,
      );
    });
  });
}
