import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BlockchainNetworkX.tryFromEvmCaip2', () {
    test('maps supported CAIP-2', () {
      expect(
        BlockchainNetworkX.tryFromEvmCaip2('eip155:1'),
        BlockchainNetwork.ethMainnet,
      );
      expect(
        BlockchainNetworkX.tryFromEvmCaip2('eip155:11155111'),
        BlockchainNetwork.ethSepolia,
      );
      expect(
        BlockchainNetworkX.tryFromEvmCaip2('eip155:56'),
        BlockchainNetwork.bscMainnet,
      );
      expect(
        BlockchainNetworkX.tryFromEvmCaip2('eip155:97'),
        BlockchainNetwork.bscChapel,
      );
    });

    test('returns null for unknown or empty', () {
      expect(BlockchainNetworkX.tryFromEvmCaip2(null), isNull);
      expect(BlockchainNetworkX.tryFromEvmCaip2(''), isNull);
      expect(BlockchainNetworkX.tryFromEvmCaip2('eip155:99999'), isNull);
    });
  });

  group('BlockchainNetworkX.tryFromApiValue', () {
    test('maps ETH_SEPOLIA', () {
      expect(
        BlockchainNetworkX.tryFromApiValue('ETH_SEPOLIA'),
        BlockchainNetwork.ethSepolia,
      );
    });
  });

  group('isTronFamily', () {
    test('true for all Tron variants', () {
      expect(BlockchainNetwork.tronMainnet.isTronFamily, isTrue);
      expect(BlockchainNetwork.tronNile.isTronFamily, isTrue);
      expect(BlockchainNetwork.tronShasta.isTronFamily, isTrue);
    });

    test('false for non-Tron', () {
      expect(BlockchainNetwork.ethMainnet.isTronFamily, isFalse);
      expect(BlockchainNetwork.solanaDevnet.isTronFamily, isFalse);
    });
  });

  group('evmCaip2', () {
    test('matches tryFromEvmCaip2 round-trip for EVM enums', () {
      for (final n in BlockchainNetwork.values) {
        final caip = n.evmCaip2;
        if (caip != null) {
          expect(BlockchainNetworkX.tryFromEvmCaip2(caip), n);
        }
      }
    });
  });

  group('parseOnChainOperatorMode', () {
    test('defaults to production when missing or unknown', () {
      expect(parseOnChainOperatorMode(null), OnChainOperatorMode.production);
      expect(parseOnChainOperatorMode({}), OnChainOperatorMode.production);
      expect(
        parseOnChainOperatorMode({'ONCHAIN_OPERATOR_MODE': ''}),
        OnChainOperatorMode.production,
      );
      expect(
        parseOnChainOperatorMode({'ONCHAIN_OPERATOR_MODE': '  '}),
        OnChainOperatorMode.production,
      );
      expect(
        parseOnChainOperatorMode({'ONCHAIN_OPERATOR_MODE': 'prod'}),
        OnChainOperatorMode.production,
      );
    });

    test('sandbox is case-insensitive', () {
      expect(
        parseOnChainOperatorMode({'ONCHAIN_OPERATOR_MODE': 'sandbox'}),
        OnChainOperatorMode.sandbox,
      );
      expect(
        parseOnChainOperatorMode({'ONCHAIN_OPERATOR_MODE': 'SANDBOX'}),
        OnChainOperatorMode.sandbox,
      );
      expect(
        parseOnChainOperatorMode({'ONCHAIN_OPERATOR_MODE': '  Sandbox  '}),
        OnChainOperatorMode.sandbox,
      );
    });

    test('production keyword stays production', () {
      expect(
        parseOnChainOperatorMode({'ONCHAIN_OPERATOR_MODE': 'production'}),
        OnChainOperatorMode.production,
      );
    });
  });

  group('BlockchainNetworkX.resolveForFamily', () {
    test('EVM_ETH sandbox maps to BSC Chapel (legacy family default)', () {
      expect(
        BlockchainNetworkX.resolveForFamily(
          OnChainNetworkFamily.evmEth,
          OnChainOperatorMode.sandbox,
        ),
        BlockchainNetwork.bscChapel,
      );
    });

    test('TON family maps to mainnet / testnet', () {
      expect(
        BlockchainNetworkX.resolveForFamily(
          OnChainNetworkFamily.ton,
          OnChainOperatorMode.production,
        ),
        BlockchainNetwork.tonMainnet,
      );
      expect(
        BlockchainNetworkX.resolveForFamily(
          OnChainNetworkFamily.ton,
          OnChainOperatorMode.sandbox,
        ),
        BlockchainNetwork.tonTestnet,
      );
    });
  });

  group('onchainNetworkFilterChipLabel', () {
    test('mainnet unchanged', () {
      expect(
        onchainNetworkFilterChipLabel(BlockchainNetwork.ethMainnet, 'SB'),
        'Ethereum (mainnet)',
      );
    });

    test('sandbox chain gets parenthesized suffix', () {
      expect(
        onchainNetworkFilterChipLabel(BlockchainNetwork.bscChapel, 'Sandbox'),
        'BNB Smart Chain (Chapel) (Sandbox)',
      );
    });
  });

  group('onchainRecentTxNetworkChipLabel', () {
    test('matches plain network label (no sandbox suffix)', () {
      expect(
        onchainRecentTxNetworkChipLabel(BlockchainNetwork.bscChapel),
        BlockchainNetwork.bscChapel.label,
      );
    });
  });
}
