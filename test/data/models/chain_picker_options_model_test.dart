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

    test('fromJson parses networkCatalog when sortOrder is string (no cast crash)', () {
      final m = ChainPickerOptionsModel.fromJson({
        'operatorMode': 'sandbox',
        'tronDefaultNetwork': 'TRON_NILE',
        'pickers': <String, dynamic>{},
        'networkCatalog': [
          {
            'code': 'ETH_SEPOLIA',
            'iconKey': 'evm',
            'family': 'evm_eth',
            'isTestnet': 'true',
            'sortOrder': '20',
            'capabilities': {'deposit': true, 'withdraw': true, 'linkWallet': true},
          },
        ],
      });
      expect(m.networkCatalog, isNotNull);
      expect(m.networkCatalog!.single.sortOrder, 20);
      expect(m.networkCatalog!.single.isTestnet, true);
    });

    test('toJson round-trips with fromJson', () {
      final original = ChainPickerOptionsModel.fromJson({
        'operatorMode': 'production',
        'tronDefaultNetwork': 'TRON_MAINNET',
        'pickers': {
          'onchain_deposit_withdraw': ['ETH_MAINNET', 'POLYGON_MAINNET'],
          'treasury_ops': ['TRON_MAINNET'],
        },
      });
      final restored = ChainPickerOptionsModel.fromJson(original.toJson());
      expect(restored.operatorMode, original.operatorMode);
      expect(restored.tronDefaultNetwork, original.tronDefaultNetwork);
      expect(restored.pickers, original.pickers);
      expect(restored.onchainDepositWithdraw, ['ETH_MAINNET', 'POLYGON_MAINNET']);
    });
  });
}
