import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/markets/domain/dtos/create_currency_dto.dart';
import 'package:crypto_trading_app/features/markets/domain/dtos/update_currency_dto.dart';
import 'package:crypto_trading_app/features/markets/domain/entities/currency.dart';
import 'package:crypto_trading_app/features/markets/domain/repositories/currencies_repository.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/currencies_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/screens/currency_detail_screen.dart';

Currency _currency({
  String id = '1',
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

class _FakeRepository implements CurrenciesRepository {
  _FakeRepository({this.rows = const [], this.failure, this.delay});
  final List<Currency> rows;
  final Failure? failure;
  final Duration? delay;

  @override
  Future<Either<Failure, PaginatedCurrenciesResult>> getCurrencies({
    int page = 1,
    int limit = 10,
    bool includeInactive = false,
    String? search,
    bool? isTradable,
    bool? isActive,
  }) async {
    if (delay != null) await Future<void>.delayed(delay!);
    return Right(
      PaginatedCurrenciesResult(
        currencies: rows,
        total: rows.length,
        page: 1,
        limit: 10,
      ),
    );
  }

  @override
  Future<Either<Failure, List<Currency>>> getActiveCurrencies() async =>
      Right(rows);

  @override
  Future<Either<Failure, List<Currency>>> getTradableCurrencies() async =>
      Right(rows);

  @override
  Future<Either<Failure, Currency>> getCurrencyById(String currencyId) async {
    if (delay != null) await Future<void>.delayed(delay!);
    if (failure != null) return Left(failure!);
    final found = rows
        .where((c) => c.currencyId == currencyId)
        .cast<Currency?>()
        .firstWhere((_) => true, orElse: () => null);
    if (found != null) return Right(found);
    return const Left(NotFoundFailure(message: 'not found'));
  }

  @override
  Future<Either<Failure, Currency>> getCurrencyBySymbol(String symbol) async =>
      const Left(NotFoundFailure(message: 'not found'));

  @override
  Future<Either<Failure, Currency>> createCurrency(CreateCurrencyDto dto) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Currency>> updateCurrency(
    String currencyId,
    UpdateCurrencyDto dto,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteCurrency(String currencyId) async {
    throw UnimplementedError();
  }
}

Widget _wrap({
  required Widget child,
  required CurrenciesProvider provider,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: ChangeNotifierProvider<CurrenciesProvider>.value(
      value: provider,
      child: child,
    ),
  );
}

void main() {
  testWidgets('renders initial currency without a fetch call',
      (tester) async {
    final currency = _currency(
      lastPrice: '27000',
      change: '2.5',
      volume: '1000000',
    );
    final provider = CurrenciesProvider(
      currenciesRepository: _FakeRepository(rows: [currency]),
    );
    // Provide a tall viewport so the slivers below the AppBar are measured.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(_wrap(
      provider: provider,
      child: CurrencyDetailScreen(
        currencyId: currency.currencyId,
        initialCurrency: currency,
      ),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.text('BTC'), findsWidgets);
    expect(find.text('Bitcoin'), findsWidgets);
    // PriceFormatter formats 27000 as "27000" (one decimal then trimmed
    // trailing zeros and a trailing decimal point). The string appears in
    // both the header card and the "Last Price" metric card.
    expect(find.text('27000'), findsWidgets);
    expect(find.text('Active'), findsWidgets);
    expect(find.text('Tradable'), findsWidgets);
  });

  testWidgets('shows inactive + paused badges when flags are false',
      (tester) async {
    final currency = _currency(isActive: false, isTradable: false);
    final provider = CurrenciesProvider(
      currenciesRepository: _FakeRepository(rows: [currency]),
    );
    await tester.pumpWidget(_wrap(
      provider: provider,
      child: CurrencyDetailScreen(
        currencyId: currency.currencyId,
        initialCurrency: currency,
      ),
    ));
    await tester.pump();

    expect(find.text('Inactive'), findsWidgets);
    expect(find.text('Paused'), findsWidgets);
  });

  testWidgets('renders configuration section labels', (tester) async {
    final currency = _currency();
    final provider = CurrenciesProvider(
      currenciesRepository: _FakeRepository(rows: [currency]),
    );
    await tester.pumpWidget(_wrap(
      provider: provider,
      child: CurrencyDetailScreen(
        currencyId: currency.currencyId,
        initialCurrency: currency,
      ),
    ));
    // SliverAppBar.medium + custom scroll view requires an explicit viewport
    // size so the slivers below the fold are measured by the test framework.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pump();

    expect(find.text('Currency Configuration'), findsOneWidget);
    expect(find.text('Symbol'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Precision Scale'), findsOneWidget);
    expect(find.text('Min Withdraw'), findsOneWidget);
  });

  testWidgets('shows loading state when fetch is in flight', (tester) async {
    final provider = CurrenciesProvider(
      currenciesRepository: _FakeRepository(
        rows: const [],
        delay: const Duration(milliseconds: 200),
      ),
    );
    await tester.pumpWidget(_wrap(
      provider: provider,
      child: const CurrencyDetailScreen(currencyId: 'missing-id'),
    ));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Let the pending delay timer resolve so test framework doesn't complain.
    await tester.pump(const Duration(milliseconds: 250));
  });

  testWidgets('shows error empty state when fetch fails', (tester) async {
    final provider = CurrenciesProvider(
      currenciesRepository: _FakeRepository(
        failure: const NetworkFailure(),
      ),
    );
    await provider.getCurrencyById('missing-id');
    await tester.pumpWidget(_wrap(
      provider: provider,
      child: const CurrencyDetailScreen(currencyId: 'missing-id'),
    ));
    await tester.pump();

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
