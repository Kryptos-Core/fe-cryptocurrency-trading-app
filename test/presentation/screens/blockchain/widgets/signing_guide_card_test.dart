import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/screens/widgets/signing_guide_card.dart';

Widget _buildHarness({
  required BlockchainNetwork network,
  required bool isWebDialog,
  required bool testMode,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 500,
          child: SigningGuideCard(
            network: network,
            isWebDialog: isWebDialog,
            testMode: testMode,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders browser guide title and ETH web steps', (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        network: BlockchainNetwork.bscChapel,
        isWebDialog: true,
        testMode: false,
      ),
    );

    expect(find.text('Browser signing guide (MetaMask)'), findsOneWidget);
    expect(
      find.textContaining('MetaMask extension is installed and unlocked.'),
      findsOneWidget,
    );
  });

  testWidgets('renders manual guide in test mode', (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        network: BlockchainNetwork.tronShasta,
        isWebDialog: false,
        testMode: true,
      ),
    );

    expect(find.text('Manual signing guide (Test mode)'), findsOneWidget);
    expect(
      find.textContaining('challenge text to your clipboard.'),
      findsOneWidget,
    );
  });
}
