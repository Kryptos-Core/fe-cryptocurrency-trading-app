import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/markets/domain/entities/currency.dart';
import 'package:crypto_trading_app/features/markets/presentation/widgets/currency_card.dart';

Currency _currency({
  String id = 'id-1',
  String symbol = 'BTC',
  String name = 'Bitcoin',
  String? lastPrice,
  String? change,
  String? volume,
  bool isActive = true,
  bool isTradable = true,
}) {
  return Currency(
    currencyId: id,
    symbol: symbol,
    name: name,
    precisionScale: 8,
    minWithdraw: '0',
    isTradable: isTradable,
    isActive: isActive,
    lastPrice: lastPrice,
    priceChangePercent24h: change,
    volume24h: volume,
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('full card renders symbol, name, price and change',
      (tester) async {
    await tester.pumpWidget(_wrap(
      CurrencyCard(
        currency: _currency(
          lastPrice: '27000.5',
          change: '2.5',
          volume: '1234567',
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('BTC'), findsOneWidget);
    expect(find.text('Bitcoin'), findsOneWidget);
    expect(find.text('27000.5'), findsOneWidget);
    expect(find.text('+2.50%'), findsOneWidget);
    expect(find.text('1.23M'), findsOneWidget);
  });

  testWidgets('full card shows active + tradable badges', (tester) async {
    await tester.pumpWidget(_wrap(
      CurrencyCard(
        currency: _currency(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Tradable'), findsOneWidget);
  });

  testWidgets('full card shows inactive + paused badges when flags false',
      (tester) async {
    await tester.pumpWidget(_wrap(
      CurrencyCard(
        currency: _currency(isActive: false, isTradable: false),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Inactive'), findsOneWidget);
    expect(find.text('Paused'), findsOneWidget);
  });

  testWidgets('compact variant hides status badges', (tester) async {
    await tester.pumpWidget(_wrap(
      SizedBox(
        width: 320,
        child: CurrencyCard(
          currency: _currency(),
          variant: CurrencyCardVariant.compact,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Active'), findsNothing);
    expect(find.text('Tradable'), findsNothing);
    expect(find.text('BTC'), findsOneWidget);
  });

  testWidgets('tap invokes onTap callback', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(_wrap(
      CurrencyCard(
        currency: _currency(),
        onTap: () => tapped++,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CurrencyCard));
    await tester.pumpAndSettle();
    expect(tapped, 1);
  });

  testWidgets('falls back to N/A when price/change/volume are null',
      (tester) async {
    await tester.pumpWidget(_wrap(
      CurrencyCard(currency: _currency()),
    ));
    await tester.pumpAndSettle();
    // Three N/A placeholders: price, change, volume.
    expect(find.text('N/A'), findsNWidgets(3));
  });
}
