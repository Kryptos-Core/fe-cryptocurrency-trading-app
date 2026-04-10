import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_trading_app/presentation/utils/deposit_methods_recommended_chain.dart';

void main() {
  group('resolveDepositMethodsHeaderRecommendedChain', () {
    test('returns API value when it is in the on-chain deposit list', () {
      expect(
        resolveDepositMethodsHeaderRecommendedChain(
          apiRecommended: 'TRON_NILE',
          onchainDepositWithdrawCodes: const [
            'BSC_CHAPEL',
            'SOLANA_DEVNET',
            'TRON_NILE',
          ],
          tronDefaultFromPickerApi: 'TRON_NILE',
        ),
        'TRON_NILE',
      );
    });

    test('maps TRON_MAINNET to tron default when mainnet not in sandbox list', () {
      expect(
        resolveDepositMethodsHeaderRecommendedChain(
          apiRecommended: 'TRON_MAINNET',
          onchainDepositWithdrawCodes: const [
            'BSC_CHAPEL',
            'SOLANA_DEVNET',
            'TRON_NILE',
          ],
          tronDefaultFromPickerApi: 'TRON_NILE',
        ),
        'TRON_NILE',
      );
    });

    test('maps TRON_MAINNET to TRON_SHASTA when picker default is Shasta', () {
      expect(
        resolveDepositMethodsHeaderRecommendedChain(
          apiRecommended: 'TRON_MAINNET',
          onchainDepositWithdrawCodes: const [
            'BSC_CHAPEL',
            'SOLANA_DEVNET',
            'TRON_SHASTA',
          ],
          tronDefaultFromPickerApi: 'TRON_SHASTA',
        ),
        'TRON_SHASTA',
      );
    });

    test('returns null when API recommended is null', () {
      expect(
        resolveDepositMethodsHeaderRecommendedChain(
          apiRecommended: null,
          onchainDepositWithdrawCodes: const ['TRON_NILE'],
          tronDefaultFromPickerApi: 'TRON_NILE',
        ),
        isNull,
      );
    });
  });
}
