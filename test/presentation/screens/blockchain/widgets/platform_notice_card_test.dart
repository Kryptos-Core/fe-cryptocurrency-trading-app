import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/screens/blockchain/widgets/platform_notice_card.dart';

Widget _buildHarness({required bool isWebDialog}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 500,
          child: PlatformNoticeCard(isWebDialog: isWebDialog),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows web notice text in web mode', (tester) async {
    await tester.pumpWidget(_buildHarness(isWebDialog: true));

    expect(
      find.text(
          'Web mode: this flow signs via browser extension popup when provider is available.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.language_outlined), findsOneWidget);
  });

  testWidgets('shows app notice text in app mode', (tester) async {
    await tester.pumpWidget(_buildHarness(isWebDialog: false));

    expect(
      find.text(
          'App mode: Windows/Mobile uses wallet app or manual-sign fallback depending on network/provider availability.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.devices_outlined), findsOneWidget);
  });
}
