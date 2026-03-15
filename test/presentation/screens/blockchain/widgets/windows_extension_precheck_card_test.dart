import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/wallet_extension_precheck_service.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/screens/blockchain/widgets/windows_extension_precheck_card.dart';

class _PrecheckHarness extends StatefulWidget {
  final WalletExtensionPrecheckService service;

  const _PrecheckHarness({required this.service});

  @override
  State<_PrecheckHarness> createState() => _PrecheckHarnessState();
}

class _PrecheckHarnessState extends State<_PrecheckHarness> {
  bool _isReady = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 500,
            child: WindowsExtensionPrecheckCard(
              network: BlockchainNetwork.ethSepolia,
              isPrechecked: _isReady,
              enabled: true,
              precheckService: widget.service,
              onPrecheckChanged: (value) {
                setState(() {
                  _isReady = value;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('renders required precheck message and action button',
      (tester) async {
    final service = WalletExtensionPrecheckService(
      openExternalUrl: (_) async => true,
    );

    await tester.pumpWidget(_PrecheckHarness(service: service));

    expect(
      find.text(
          'Windows pre-check: confirm extension is installed before signing.'),
      findsOneWidget,
    );
    expect(find.text('Check extension in browser'), findsOneWidget);
  },
      variant: const TargetPlatformVariant(
          <TargetPlatform>{TargetPlatform.windows}));

  testWidgets('marks precheck ready after selecting Ready in check dialog',
      (tester) async {
    final service = WalletExtensionPrecheckService(
      openExternalUrl: (_) async => true,
    );

    await tester.pumpWidget(_PrecheckHarness(service: service));

    await tester.tap(find.text('Check extension in browser'));
    await tester.pumpAndSettle();

    expect(find.text('Check MetaMask'), findsOneWidget);

    await tester.tap(find.text('Ready'));
    await tester.pumpAndSettle();

    expect(
      find.text(
          'Windows pre-check: extension is ready, you can continue signing.'),
      findsOneWidget,
    );
  },
      variant: const TargetPlatformVariant(
          <TargetPlatform>{TargetPlatform.windows}));
}
