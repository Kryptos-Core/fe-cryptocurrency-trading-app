import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/features/treasury/presentation/constants/treasury_chains.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(dotenv.clean);

  group('treasuryOpsChainsForCurrentEnv vs ONCHAIN_OPERATOR_MODE', () {
    test('explicit sandbox forces testnet ops list even when ENV=production', () {
      dotenv.loadFromString(envString: '''
ENV=production
ONCHAIN_OPERATOR_MODE=sandbox
''');
      final chains = treasuryOpsChainsForCurrentEnv();
      expect(chains, contains('TRON_NILE'));
      expect(chains, contains('ETH_SEPOLIA'));
      expect(chains, isNot(contains('TRON_MAINNET')));
    });

    test('explicit production forces mainnet ops list even when ENV=development', () {
      dotenv.loadFromString(envString: '''
ENV=development
ONCHAIN_OPERATOR_MODE=production
''');
      final chains = treasuryOpsChainsForCurrentEnv();
      expect(chains, contains('TRON_MAINNET'));
      expect(chains, contains('ETH_MAINNET'));
      expect(chains, isNot(contains('TRON_NILE')));
    });

    test('blank ONCHAIN falls back to ENV=development → testnets', () {
      dotenv.loadFromString(envString: '''
ENV=development
ONCHAIN_OPERATOR_MODE=
''');
      expect(treasuryOpsChainsForCurrentEnv(), contains('TRON_NILE'));
    });

    test('missing ONCHAIN key falls back to ENV=production → mainnet', () {
      dotenv.loadFromString(envString: 'ENV=production');
      expect(treasuryOpsChainsForCurrentEnv(), contains('TRON_MAINNET'));
    });
  });

  group('treasuryOpsWalletCreationChainsForCurrentEnv', () {
    test('sandbox lists multichain testnets including Sepolia', () {
      dotenv.loadFromString(envString: '''
ENV=development
ONCHAIN_OPERATOR_MODE=sandbox
''');
      final chains = treasuryOpsWalletCreationChainsForCurrentEnv();
      expect(chains, contains('SOLANA_DEVNET'));
      expect(chains, contains('BSC_CHAPEL'));
      expect(chains, contains('ETH_SEPOLIA'));
      expect(chains.where((c) => c == 'TRON_NILE' || c == 'TRON_SHASTA').length, 1);
      expect(chains, isNot(contains('TRON_MAINNET')));
    });

    test('TRON_DEFAULT_NETWORK=TRON_SHASTA includes Shasta as sole Tron row', () {
      dotenv.loadFromString(envString: '''
ONCHAIN_OPERATOR_MODE=sandbox
TRON_DEFAULT_NETWORK=TRON_SHASTA
''');
      expect(treasurySandboxDefaultTronChain(), 'TRON_SHASTA');
      expect(treasuryOpsWalletCreationChainsForCurrentEnv(), contains('TRON_SHASTA'));
      expect(treasuryOpsWalletCreationChainsForCurrentEnv(), isNot(contains('TRON_NILE')));
    });

    test('production onchain mode matches expanded mainnet list', () {
      dotenv.loadFromString(envString: '''
ENV=development
ONCHAIN_OPERATOR_MODE=production
''');
      expect(treasuryOpsWalletCreationChainsForCurrentEnv(), treasuryOpsChainsForCurrentEnv());
      expect(treasuryOpsWalletCreationChainsForCurrentEnv(), contains('TRON_MAINNET'));
      expect(treasuryOpsWalletCreationChainsForCurrentEnv(), contains('BASE_MAINNET'));
    });
  });

  group('treasuryMainWalletChainsForCurrentEnv (hot wallet = payment config)', () {
    test('sandbox matches treasuryOpsWalletCreationChainsForCurrentEnv exactly', () {
      dotenv.loadFromString(envString: '''
ENV=development
ONCHAIN_OPERATOR_MODE=sandbox
''');
      expect(
        treasuryMainWalletChainsForCurrentEnv(),
        treasuryOpsWalletCreationChainsForCurrentEnv(),
      );
      expect(treasuryMainWalletChainsForCurrentEnv(), contains('BSC_CHAPEL'));
      expect(treasuryMainWalletChainsForCurrentEnv(), isNot(contains('BSC_TESTNET')));
    });

    test('production onchain mode matches ops creation list', () {
      dotenv.loadFromString(envString: 'ONCHAIN_OPERATOR_MODE=production');
      expect(
        treasuryMainWalletChainsForCurrentEnv(),
        treasuryOpsWalletCreationChainsForCurrentEnv(),
      );
    });
  });

  group('treasuryHistoryFilterChainsForCurrentEnv', () {
    test('matches wallet creation chains in sandbox', () {
      dotenv.loadFromString(envString: 'ONCHAIN_OPERATOR_MODE=sandbox');
      expect(
        treasuryHistoryFilterChainsForCurrentEnv(),
        treasuryOpsWalletCreationChainsForCurrentEnv(),
      );
      expect(treasuryHistoryFilterChainsForCurrentEnv(), contains('ETH_SEPOLIA'));
    });

    test('matches wallet creation chains in production onchain mode', () {
      dotenv.loadFromString(envString: 'ONCHAIN_OPERATOR_MODE=production');
      expect(
        treasuryHistoryFilterChainsForCurrentEnv(),
        treasuryOpsWalletCreationChainsForCurrentEnv(),
      );
    });
  });

  group('walletConnectLinkNetworksForCurrentEnv', () {
    test('sandbox lists EVM testnets + Solana (no Tron)', () {
      dotenv.loadFromString(envString: 'ONCHAIN_OPERATOR_MODE=sandbox');
      final nets = walletConnectLinkNetworksForCurrentEnv();
      expect(nets, contains(BlockchainNetwork.bscChapel));
      expect(nets, contains(BlockchainNetwork.solanaDevnet));
      expect(nets, contains(BlockchainNetwork.ethSepolia));
      expect(nets.where((n) => n.isTronFamily), isEmpty);
    });

    test('production lists EVM mainnets + Solana (no Tron)', () {
      dotenv.loadFromString(envString: 'ONCHAIN_OPERATOR_MODE=production');
      final nets = walletConnectLinkNetworksForCurrentEnv();
      expect(nets, contains(BlockchainNetwork.ethMainnet));
      expect(nets, contains(BlockchainNetwork.bscMainnet));
      expect(nets, contains(BlockchainNetwork.solanaMainnet));
      expect(nets.where((n) => n.isTronFamily), isEmpty);
    });
  });

  group('tronExtensionLinkNetworksForCurrentEnv', () {
    test('sandbox uses default Tron testnet only', () {
      dotenv.loadFromString(envString: 'ONCHAIN_OPERATOR_MODE=sandbox');
      expect(tronExtensionLinkNetworksForCurrentEnv(), [BlockchainNetwork.tronNile]);
    });

    test('sandbox respects TRON_DEFAULT_NETWORK=TRON_SHASTA', () {
      dotenv.loadFromString(envString: '''
ONCHAIN_OPERATOR_MODE=sandbox
TRON_DEFAULT_NETWORK=TRON_SHASTA
''');
      expect(tronExtensionLinkNetworksForCurrentEnv(), [BlockchainNetwork.tronShasta]);
    });

    test('production is Tron mainnet only', () {
      dotenv.loadFromString(envString: 'ONCHAIN_OPERATOR_MODE=production');
      expect(tronExtensionLinkNetworksForCurrentEnv(), [BlockchainNetwork.tronMainnet]);
    });
  });

  group('onchainDepositWithdrawNetworksForCurrentEnv', () {
    test('sandbox lists full actionable testnet set ending with Tron', () {
      dotenv.loadFromString(envString: 'ONCHAIN_OPERATOR_MODE=sandbox');
      final nets = onchainDepositWithdrawNetworksForCurrentEnv();
      expect(nets.first, BlockchainNetwork.bscChapel);
      expect(nets, contains(BlockchainNetwork.ethSepolia));
      expect(nets.last, BlockchainNetwork.tronNile);
    });

    test('sandbox ends with Shasta when TRON_DEFAULT_NETWORK set', () {
      dotenv.loadFromString(envString: '''
ONCHAIN_OPERATOR_MODE=sandbox
TRON_DEFAULT_NETWORK=TRON_SHASTA
''');
      expect(
        onchainDepositWithdrawNetworksForCurrentEnv().last,
        BlockchainNetwork.tronShasta,
      );
    });

    test('production lists mainnet actionable order (BSC first)', () {
      dotenv.loadFromString(envString: 'ONCHAIN_OPERATOR_MODE=production');
      final nets = onchainDepositWithdrawNetworksForCurrentEnv();
      expect(nets.first, BlockchainNetwork.bscMainnet);
      expect(nets.last, BlockchainNetwork.tronMainnet);
      expect(nets, contains(BlockchainNetwork.baseMainnet));
    });
  });

  group('preferredOnchainDepositWithdrawNetwork', () {
    test('sandbox prefers first Tron row over BSC-first list order', () {
      dotenv.loadFromString(envString: 'ONCHAIN_OPERATOR_MODE=sandbox');
      final nets = onchainDepositWithdrawNetworksForCurrentEnv();
      expect(nets.first, BlockchainNetwork.bscChapel);
      expect(
        preferredOnchainDepositWithdrawNetwork(nets),
        BlockchainNetwork.tronNile,
      );
    });

    test('production keeps env list order (first actionable)', () {
      dotenv.loadFromString(envString: 'ONCHAIN_OPERATOR_MODE=production');
      final nets = onchainDepositWithdrawNetworksForCurrentEnv();
      expect(
        preferredOnchainDepositWithdrawNetwork(nets),
        BlockchainNetwork.bscMainnet,
      );
    });
  });
}
