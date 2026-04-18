import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/linked_wallet_status.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/onchain_transaction.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/onchain_tx_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnchainTxStatusX.fromApiValue', () {
    test('parses known values', () {
      expect(OnchainTxStatusX.fromApiValue('PENDING'), OnchainTxStatus.pending);
      expect(OnchainTxStatusX.fromApiValue('pending'), OnchainTxStatus.pending);
    });

    test('does not throw on unknown API value — returns unknown', () {
      expect(OnchainTxStatusX.fromApiValue('EXPIRED'), OnchainTxStatus.unknown);
      expect(OnchainTxStatusX.fromApiValue(''), OnchainTxStatus.unknown);
    });
  });

  group('LinkedWalletStatusX.fromApiValue', () {
    test('parses known values', () {
      expect(LinkedWalletStatusX.fromApiValue('VERIFIED'), LinkedWalletStatus.verified);
    });

    test('does not throw on unknown API value — returns unknown', () {
      expect(LinkedWalletStatusX.fromApiValue('ARCHIVED'), LinkedWalletStatus.unknown);
    });
  });

  group('OnchainTxTypeX.fromApiValue', () {
    test('parses known values', () {
      expect(OnchainTxTypeX.fromApiValue('DEPOSIT'), OnchainTxType.deposit);
      expect(OnchainTxTypeX.fromApiValue('FUND'), OnchainTxType.fund);
      expect(OnchainTxTypeX.fromApiValue('SWEEP'), OnchainTxType.sweep);
    });

    test('does not throw on unknown API value — returns unknown', () {
      expect(OnchainTxTypeX.fromApiValue('AIRDROP'), OnchainTxType.unknown);
    });
  });
}
