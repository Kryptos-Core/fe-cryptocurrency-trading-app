import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/widgets/onchain_recent_tx_filter_dropdowns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder _appDropdownFields() {
  return find.byWidgetPredicate(
    (widget) => widget.runtimeType.toString().startsWith('AppDropdownField'),
  );
}

Finder _dropdownButtons() {
  return find.byWidgetPredicate(
    (widget) => widget.runtimeType.toString().startsWith('DropdownButtonFormField'),
  );
}

void main() {
  testWidgets('renders network and type dropdowns', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 680,
              child: OnchainRecentTxFilterDropdowns(
                networks: const [
                  BlockchainNetwork.tronNile,
                  BlockchainNetwork.bscChapel,
                ],
                selectedNetwork: null,
                selectedType: null,
                onNetworkChanged: (_) {},
                onTypeChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(_appDropdownFields(), findsNWidgets(2));
  });

  testWidgets('type dropdown only exposes deposit withdraw and transfer',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 680,
              child: OnchainRecentTxFilterDropdowns(
                networks: const [BlockchainNetwork.tronNile],
                selectedNetwork: null,
                selectedType: null,
                onNetworkChanged: (_) {},
                onTypeChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(_dropdownButtons().at(1));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)));
    expect(find.text(l10n.txTypeDeposits), findsOneWidget);
    expect(find.text(l10n.txTypeWithdrawals), findsOneWidget);
    expect(find.text(l10n.txTypeTransfers), findsOneWidget);
    expect(find.text(l10n.txTypeFund), findsNothing);
    expect(find.text(l10n.txTypeSweep), findsNothing);
  });
}
