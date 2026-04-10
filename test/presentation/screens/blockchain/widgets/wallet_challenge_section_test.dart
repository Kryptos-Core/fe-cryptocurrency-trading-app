import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/wallet_extension_precheck_service.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/screens/blockchain/widgets/windows_extension_precheck_card.dart';
import 'package:crypto_trading_app/presentation/screens/blockchain/widgets/wallet_challenge_section.dart';

class _ChallengeHarness extends StatefulWidget {
  final bool showWindowsPrecheck;
  final bool testMode;
  final bool isWebDialog;
  final BlockchainNetwork network;

  const _ChallengeHarness({
    required this.showWindowsPrecheck,
    required this.testMode,
    required this.isWebDialog,
    this.network = BlockchainNetwork.bscChapel,
  });

  @override
  State<_ChallengeHarness> createState() => _ChallengeHarnessState();
}

class _ChallengeHarnessState extends State<_ChallengeHarness> {
  final _signatureController = TextEditingController();
  final _precheckKey = GlobalKey<WindowsExtensionPrecheckCardState>();
  bool _isPrechecked = false;

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: 520,
              child: WalletChallengeSection(
                challengeMessage: 'challenge-body',
                testMode: widget.testMode,
                isWebDialog: widget.isWebDialog,
                isSubmitting: false,
                network: widget.network,
                onSignPressed: () {},
                signatureController: _signatureController,
                showWindowsPrecheck: widget.showWindowsPrecheck,
                windowsPrechecked: _isPrechecked,
                extensionPrecheckService: WalletExtensionPrecheckService(
                  openExternalUrl: (_) async => true,
                ),
                windowsPrecheckKey: _precheckKey,
                onWindowsPrecheckChanged: (value) {
                  setState(() {
                    _isPrechecked = value;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('renders challenge content, step 2 button, and signature field',
      (tester) async {
    await tester.pumpWidget(
      const _ChallengeHarness(
        showWindowsPrecheck: false,
        testMode: false,
        isWebDialog: true,
      ),
    );

    expect(find.text('Challenge message'), findsOneWidget);
    expect(find.text('challenge-body'), findsOneWidget);
    expect(find.text('2) Open Extension & Sign'), findsOneWidget);
    expect(find.text('Signature'), findsOneWidget);
  });

  testWidgets('renders windows precheck card when enabled', (tester) async {
    await tester.pumpWidget(
      const _ChallengeHarness(
        showWindowsPrecheck: true,
        testMode: false,
        isWebDialog: false,
      ),
    );

    expect(
      find.text(
          'Windows pre-check: confirm extension is installed before signing.'),
      findsOneWidget,
    );
    expect(find.text('Check extension in browser'), findsOneWidget);
  },
      variant: const TargetPlatformVariant(
          <TargetPlatform>{TargetPlatform.windows}));

  testWidgets('shows native windows signing notice under step 2 for Tron',
      (tester) async {
    await tester.pumpWidget(
      const _ChallengeHarness(
        showWindowsPrecheck: true,
        testMode: false,
        isWebDialog: false,
        network: BlockchainNetwork.tronNile,
      ),
    );

    expect(
      find.text(
        'Windows native app cannot trigger extension signing popup directly. Direct popup signing is available only on web (Chrome/Edge).',
      ),
      findsOneWidget,
    );
    expect(find.text('2) Open Wallet (Manual Sign)'), findsOneWidget);
  },
      variant: const TargetPlatformVariant(
          <TargetPlatform>{TargetPlatform.windows}));
}
