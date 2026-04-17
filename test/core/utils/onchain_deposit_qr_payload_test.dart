import 'package:crypto_trading_app/core/utils/onchain_deposit_qr_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildOnchainDepositQrPayload', () {
    test('tron is raw Base58 so wallet UIs do not show a tron: prefix', () {
      expect(
        buildOnchainDepositQrPayload(
          chainApiCode: 'TRON_NILE',
          rawAddress: ' TQwB27x5HUNz5qqmEG9q6BjfxsbZMF2LRV ',
        ),
        'TQwB27x5HUNz5qqmEG9q6BjfxsbZMF2LRV',
      );
    });

    test('evm uses ethereum: URI', () {
      expect(
        buildOnchainDepositQrPayload(
          chainApiCode: 'ETH_SEPOLIA',
          rawAddress: '0xabcDEFabcdefABCDEFabcdefABCDEFabcdefAB',
        ),
        'ethereum:0xabcDEFabcdefABCDEFabcdefABCDEFabcdefAB',
      );
    });

    test('evm adds 0x when missing', () {
      expect(
        buildOnchainDepositQrPayload(
          chainApiCode: 'BSC_MAINNET',
          rawAddress: 'abcdefabcdefabcdefabcdefabcdefabcdefabcd',
        ),
        'ethereum:0xabcdefabcdefabcdefabcdefabcdefabcdefabcd',
      );
    });

    test('solana uses solana: URI', () {
      expect(
        buildOnchainDepositQrPayload(
          chainApiCode: 'SOLANA_DEVNET',
          rawAddress: 'So11111111111111111111111111111111111111112',
        ),
        'solana:So11111111111111111111111111111111111111112',
      );
    });
  });
}
