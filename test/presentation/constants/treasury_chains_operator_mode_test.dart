import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/presentation/constants/treasury_chains.dart';
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
      expect(chains, isNot(contains('ETH_SEPOLIA')));
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
    test('sandbox lists one Tron testnet + Solana + BSC Chapel (no Sepolia)', () {
      dotenv.loadFromString(envString: '''
ENV=development
ONCHAIN_OPERATOR_MODE=sandbox
''');
      final chains = treasuryOpsWalletCreationChainsForCurrentEnv();
      expect(chains, contains('SOLANA_DEVNET'));
      expect(chains, contains('BSC_CHAPEL'));
      expect(chains, isNot(contains('ETH_SEPOLIA')));
      expect(chains.where((c) => c == 'TRON_NILE' || c == 'TRON_SHASTA').length, 1);
      expect(chains, isNot(contains('TRON_MAINNET')));
    });

    test('TRON_DEFAULT_NETWORK=TRON_SHASTA picks Shasta for creation row', () {
      dotenv.loadFromString(envString: '''
ONCHAIN_OPERATOR_MODE=sandbox
TRON_DEFAULT_NETWORK=TRON_SHASTA
''');
      expect(treasurySandboxDefaultTronChain(), 'TRON_SHASTA');
      expect(treasuryOpsWalletCreationChainsForCurrentEnv().first, 'TRON_SHASTA');
    });

    test('production onchain mode keeps narrow mainnet creation list', () {
      dotenv.loadFromString(envString: '''
ENV=development
ONCHAIN_OPERATOR_MODE=production
''');
      expect(treasuryOpsWalletCreationChainsForCurrentEnv(), treasuryOpsChainsForCurrentEnv());
      expect(treasuryOpsWalletCreationChainsForCurrentEnv(), contains('TRON_MAINNET'));
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
    test('matches wallet creation chains in sandbox (no stray Sepolia)', () {
      dotenv.loadFromString(envString: 'ONCHAIN_OPERATOR_MODE=sandbox');
      expect(
        treasuryHistoryFilterChainsForCurrentEnv(),
        treasuryOpsWalletCreationChainsForCurrentEnv(),
      );
      expect(treasuryHistoryFilterChainsForCurrentEnv(), isNot(contains('ETH_SEPOLIA')));
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
    test('sandbox lists BSC Chapel + Solana devnet only (no Sepolia)', () {
      dotenv.loadFromString(envString: 'ONCHAIN_OPERATOR_MODE=sandbox');
      expect(walletConnectLinkNetworksForCurrentEnv(), [
        BlockchainNetwork.bscChapel,
        BlockchainNetwork.solanaDevnet,
      ]);
    });

    test('production lists three mainnets only', () {
      dotenv.loadFromString(envString: 'ONCHAIN_OPERATOR_MODE=production');
      expect(walletConnectLinkNetworksForCurrentEnv(), [
        BlockchainNetwork.ethMainnet,
        BlockchainNetwork.bscMainnet,
        BlockchainNetwork.solanaMainnet,
      ]);
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
    test('sandbox lists Chapel + Solana + Tron (no Sepolia)', () {
      dotenv.loadFromString(envString: 'ONCHAIN_OPERATOR_MODE=sandbox');
      expect(onchainDepositWithdrawNetworksForCurrentEnv(), [
        BlockchainNetwork.bscChapel,
        BlockchainNetwork.solanaDevnet,
        BlockchainNetwork.tronNile,
      ]);
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

    test('production lists four mainnets (EVM/Solana before Tron)', () {
      dotenv.loadFromString(envString: 'ONCHAIN_OPERATOR_MODE=production');
      expect(onchainDepositWithdrawNetworksForCurrentEnv(), [
        BlockchainNetwork.ethMainnet,
        BlockchainNetwork.bscMainnet,
        BlockchainNetwork.solanaMainnet,
        BlockchainNetwork.tronMainnet,
      ]);
    });
  });
}
