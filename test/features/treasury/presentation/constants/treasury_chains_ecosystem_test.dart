import 'package:crypto_trading_app/features/treasury/presentation/constants/treasury_chains.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ecosystemForChain', () {
    test('maps API prefixes to ecosystems', () {
      expect(ecosystemForChain('TRON_NILE'), TreasuryChainEcosystem.tron);
      expect(ecosystemForChain('ETH_SEPOLIA'), TreasuryChainEcosystem.ethereum);
      expect(ecosystemForChain('BSC_CHAPEL'), TreasuryChainEcosystem.bsc);
      expect(ecosystemForChain('SOLANA_DEVNET'), TreasuryChainEcosystem.solana);
      expect(ecosystemForChain('BASE_SEPOLIA'), TreasuryChainEcosystem.base);
    });
  });

  group('treasuryOpsEcosystems', () {
    test('dedupes by first appearance order', () {
      final eco = treasuryOpsEcosystems(const [
        'BSC_CHAPEL',
        'SOLANA_DEVNET',
        'TRON_NILE',
        'TRON_SHASTA',
        'ETH_SEPOLIA',
      ]);
      expect(eco, [
        TreasuryChainEcosystem.bsc,
        TreasuryChainEcosystem.solana,
        TreasuryChainEcosystem.tron,
        TreasuryChainEcosystem.ethereum,
      ]);
    });
  });

  group('treasuryOpsNetworksForEcosystem', () {
    test('places mainnet before testnets; preserves input order within groups', () {
      final nets = treasuryOpsNetworksForEcosystem(
        TreasuryChainEcosystem.tron,
        const ['TRON_SHASTA', 'TRON_NILE'],
      );
      expect(nets, ['TRON_SHASTA', 'TRON_NILE']);
      final nets2 = treasuryOpsNetworksForEcosystem(
        TreasuryChainEcosystem.ethereum,
        const ['ETH_SEPOLIA', 'ETH_MAINNET'],
      );
      expect(nets2, ['ETH_MAINNET', 'ETH_SEPOLIA']);
    });
  });
}
