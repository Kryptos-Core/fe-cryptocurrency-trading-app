import 'package:crypto_trading_app/features/markets/domain/entities/exchange_rate_preview.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/markets/presentation/widgets/rate_preview_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const preview = ExchangeRatePreview(
    fiatAmount: '500000',
    fiatSymbol: 'VND',
    quoteCurrency: 'USDT',
    grossAmount: '20.00000000',
    spreadBps: '50',
    spreadAmount: '0.10000000',
    netAmount: '19.90000000',
    effectiveRate: '0.00003980',
    marketRate: '0.00004000',
    rateSource: 'manual_override',
    validUntil: '2026-04-14T10:05:00.000Z',
  );

  testWidgets('shows loading indicator while preview is loading',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: Scaffold(
          body: RatePreviewWidget(
            preview: null,
            isLoading: true,
          ),
        ),
      ),
    );

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('renders conversion details when preview is available',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: Scaffold(
          body: RatePreviewWidget(
            preview: preview,
            isLoading: false,
          ),
        ),
      ),
    );

    expect(find.text('Current exchange rate'), findsOneWidget);
    expect(find.textContaining('Spread: 50 bps'), findsOneWidget);
    expect(find.textContaining('19.9 USDT'), findsOneWidget);
  });
}
