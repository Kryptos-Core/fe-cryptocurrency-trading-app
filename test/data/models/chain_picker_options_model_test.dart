import 'package:crypto_trading_app/data/models/chain_picker_options_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChainPickerOptionsModel', () {
    test('fromJson parses pickers and typed getters', () {
      final m = ChainPickerOptionsModel.fromJson({
        'operatorMode': 'sandbox',
        'tronDefaultNetwork': 'TRON_NILE',
        'pickers': {
          'treasury_ops': ['TRON_NILE', 'SOLANA_DEVNET', 'BSC_CHAPEL'],
          'treasury_main_wallet': ['TRON_NILE'],
          'treasury_history_filter': ['TRON_NILE'],
          'withdrawal_admin_filter': ['TRON_NILE', 'BSC_CHAPEL'],
          'managed_wallets': ['TRON_MAINNET'],
          'onchain_deposit_withdraw': [
            'BSC_CHAPEL',
            'SOLANA_DEVNET',
            'TRON_NILE',
          ],
        },
      });
      expect(m.operatorMode, 'sandbox');
      expect(m.tronDefaultNetwork, 'TRON_NILE');
      expect(m.treasuryOps, ['TRON_NILE', 'SOLANA_DEVNET', 'BSC_CHAPEL']);
      expect(m.treasuryMainWallet, ['TRON_NILE']);
      expect(m.treasuryHistoryFilter, ['TRON_NILE']);
      expect(m.withdrawalAdminFilter, ['TRON_NILE', 'BSC_CHAPEL']);
      expect(m.managedWallets, ['TRON_MAINNET']);
      expect(m.onchainDepositWithdraw, [
        'BSC_CHAPEL',
        'SOLANA_DEVNET',
        'TRON_NILE',
      ]);
    });

    test('fromJson uses defaults when pickers missing', () {
      final m = ChainPickerOptionsModel.fromJson(<String, dynamic>{});
      expect(m.operatorMode, 'sandbox');
      expect(m.tronDefaultNetwork, 'TRON_NILE');
      expect(m.treasuryOps, isEmpty);
    });
  });
}
