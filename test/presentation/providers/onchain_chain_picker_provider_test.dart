import 'dart:convert';

import 'package:crypto_trading_app/core/services/chain_picker_options_cache.dart';
import 'package:crypto_trading_app/features/treasury/domain/entities/chain_picker_options_model.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/onchain_chain_picker_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/stub_treasury_remote_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnchainChainPickerProvider', () {
    test('when API fails, uses last cached options from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        ChainPickerOptionsCache.storageKey: jsonEncode({
          'operatorMode': 'sandbox',
          'tronDefaultNetwork': 'TRON_NILE',
          'pickers': {
            'onchain_deposit_withdraw': [
              'CACHED_A',
              'CACHED_B',
            ],
          },
        }),
      });
      final prefs = await SharedPreferences.getInstance();

      final provider = OnchainChainPickerProvider(
        repository: StubTreasuryRepository(
          chainPickerJson: const {},
          chainPickerError: Exception('offline'),
        ),
        prefs: prefs,
      );

      await provider.ensureLoaded();

      expect(provider.rawOptions, isNotNull);
      expect(provider.onchainDepositWithdrawChainCodes, ['CACHED_A', 'CACHED_B']);
    });

    test('when API succeeds, persists options for later offline reads', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final apiModel = ChainPickerOptionsModel.fromJson({
        'operatorMode': 'sandbox',
        'tronDefaultNetwork': 'TRON_NILE',
        'pickers': {
          'onchain_deposit_withdraw': ['SOLANA_DEVNET', 'BSC_CHAPEL'],
        },
      });

      final provider = OnchainChainPickerProvider(
        repository: StubTreasuryRepository(
          chainPickerJson: {
            'operatorMode': 'sandbox',
            'tronDefaultNetwork': 'TRON_NILE',
            'pickers': {
              'onchain_deposit_withdraw': ['SOLANA_DEVNET', 'BSC_CHAPEL'],
            },
          },
        ),
        prefs: prefs,
      );

      await provider.ensureLoaded();

      expect(provider.onchainDepositWithdrawChainCodes, ['SOLANA_DEVNET', 'BSC_CHAPEL']);

      final raw = prefs.getString(ChainPickerOptionsCache.storageKey);
      expect(raw, isNotNull);
      final decoded = jsonDecode(raw!) as Map<String, dynamic>;
      final roundTrip = ChainPickerOptionsModel.fromJson(decoded);
      expect(roundTrip.onchainDepositWithdraw, apiModel.onchainDepositWithdraw);
    });
  });
}
