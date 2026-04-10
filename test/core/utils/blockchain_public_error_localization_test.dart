import 'package:crypto_trading_app/core/utils/blockchain_public_error_localization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('suppressDepositAddressUnavailableSnackBar', () {
    test('true for treasury main wallet not configured', () {
      expect(
        suppressDepositAddressUnavailableSnackBar(
          code: 'TREASURY_MAIN_WALLET_NOT_CONFIGURED',
          serverMessage: 'No active default main wallet',
        ),
        isTrue,
      );
    });

    test('true when message matches English ops copy without code', () {
      expect(
        suppressDepositAddressUnavailableSnackBar(
          code: null,
          serverMessage:
              'No active default main wallet configured for chain BSC_CHAPEL.',
        ),
        isTrue,
      );
    });

    test('false for unknown errors', () {
      expect(
        suppressDepositAddressUnavailableSnackBar(
          code: 'CHAIN_REQUIRED',
          serverMessage: 'Missing chain',
        ),
        isFalse,
      );
    });
  });

  group('isDepositConfigurationUnavailable', () {
    test('true for known treasury codes', () {
      expect(
        isDepositConfigurationUnavailable(
          code: 'DEPOSIT_DEFAULT_NOT_CONFIGURED',
          serverMessage: null,
        ),
        isTrue,
      );
    });

    test('false for unrelated API errors', () {
      expect(
        isDepositConfigurationUnavailable(
          code: 'CHAIN_REQUIRED',
          serverMessage: 'Missing chain',
        ),
        isFalse,
      );
    });
  });

  group('resolveDepositAddressEmptyKind', () {
    test('generic when no provider error or code', () {
      expect(
        resolveDepositAddressEmptyKind(
          hasErrorOrCode: false,
          code: null,
          serverMessage: null,
        ),
        DepositAddressEmptyKind.generic,
      );
    });

    test('configurationUnavailable matches treasury not configured', () {
      expect(
        resolveDepositAddressEmptyKind(
          hasErrorOrCode: true,
          code: 'TREASURY_MAIN_WALLET_NOT_CONFIGURED',
          serverMessage: null,
        ),
        DepositAddressEmptyKind.configurationUnavailable,
      );
    });

    test('error for other API failures', () {
      expect(
        resolveDepositAddressEmptyKind(
          hasErrorOrCode: true,
          code: 'CHAIN_REQUIRED',
          serverMessage: 'x',
        ),
        DepositAddressEmptyKind.error,
      );
    });
  });
}
