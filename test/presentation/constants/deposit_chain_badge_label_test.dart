import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/constants/treasury_chains.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('depositChainBadgeLabel', () {
    test('uses readable short tokens, not truncated enum codes', () {
      expect(depositChainBadgeLabel('ETH_SEPOLIA'), 'Sepolia');
      expect(depositChainBadgeLabel('BASE_SEPOLIA'), 'Base Sepolia');
      expect(depositChainBadgeLabel('ARBITRUM_SEPOLIA'), 'Arbitrum Sepolia');
      expect(depositChainBadgeLabel('OPTIMISM_SEPOLIA'), 'Optimism Sepolia');
      expect(depositChainBadgeLabel('POLYGON_AMOY'), 'Polygon Amoy');
      expect(depositChainBadgeLabel('AVALANCHE_FUJI'), 'Avalanche Fuji');
      expect(depositChainBadgeLabel('GNOSIS_CHIADO'), 'Gnosis Chiado');
      expect(depositChainBadgeLabel('LINEA_SEPOLIA'), 'Linea Sepolia');
      expect(depositChainBadgeLabel('FANTOM_TESTNET'), 'Fantom Testnet');
      expect(depositChainBadgeLabel('BSC_CHAPEL'), 'BNB Chapel');
      expect(depositChainBadgeLabel('SOLANA_DEVNET'), 'Solana Devnet');
    });

    test('mainnets stay compact but clear', () {
      expect(depositChainBadgeLabel('ETH_MAINNET'), 'Ethereum');
      expect(depositChainBadgeLabel('BASE_MAINNET'), 'Base');
      expect(depositChainBadgeLabel('ARBITRUM_MAINNET'), 'Arbitrum');
      expect(depositChainBadgeLabel('OPTIMISM_MAINNET'), 'Optimism');
      expect(depositChainBadgeLabel('POLYGON_MAINNET'), 'Polygon');
      expect(depositChainBadgeLabel('AVALANCHE_MAINNET'), 'Avalanche');
      expect(depositChainBadgeLabel('GNOSIS_MAINNET'), 'Gnosis');
      expect(depositChainBadgeLabel('LINEA_MAINNET'), 'Linea');
      expect(depositChainBadgeLabel('FANTOM_MAINNET'), 'Fantom');
    });

    test('is case-insensitive on input', () {
      expect(depositChainBadgeLabel('eth_sepolia'), 'Sepolia');
    });
  });

  testWidgets('treasuryChainDisplayLabel does not show raw ETH_SEPOLIA in Vietnamese', (tester) async {
    late String resolved;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('vi'),
        home: Builder(
          builder: (context) {
            resolved = treasuryChainDisplayLabel(
              AppLocalizations.of(context),
              'ETH_SEPOLIA',
            );
            return const SizedBox();
          },
        ),
      ),
    );
    expect(resolved, contains('Sepolia'));
    expect(resolved, isNot(equals('ETH_SEPOLIA')));
  });
}
