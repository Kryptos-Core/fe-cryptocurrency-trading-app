import 'package:crypto_trading_app/core/utils/blockchain_public_error_localization.dart';
import 'package:crypto_trading_app/presentation/widgets/deposit_address_empty_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('configurationUnavailable shows info callout, not raw red text', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DepositAddressEmptyPlaceholder(
            message: 'Chưa hỗ trợ',
            kind: DepositAddressEmptyKind.configurationUnavailable,
          ),
        ),
      ),
    );

    expect(find.text('Chưa hỗ trợ'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    expect(find.byType(DecoratedBox), findsWidgets);
  });

  testWidgets('generic uses plain text without info banner', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DepositAddressEmptyPlaceholder(
            message: 'Fallback',
            kind: DepositAddressEmptyKind.generic,
          ),
        ),
      ),
    );

    expect(find.text('Fallback'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline_rounded), findsNothing);
  });
}
