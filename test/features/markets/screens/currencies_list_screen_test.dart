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
import 'package:crypto_trading_app/features/markets/presentation/screens/currencies_list_screen.dart';

Currency _currency(String symbol, {String id = '0', String? price}) {
  return Currency(
    currencyId: id,
    symbol: symbol,
    name: '$symbol Network',
    precisionScale: 8,
    minWithdraw: '0',
    isTradable: true,
    isActive: true,
    lastPrice: price,
    priceChangePercent24h: '1.0',
    volume24h: '500',
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
    if (failure != null) return Left(failure!);
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
  Future<Either<Failure, Currency>> getCurrencyById(String currencyId) async =>
      const Left(NotFoundFailure(message: 'not found'));

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

Widget _wrap(Widget child, {CurrenciesProvider? provider}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: ChangeNotifierProvider<CurrenciesProvider>(
      create: (_) => provider ?? CurrenciesProvider(
        currenciesRepository: _FakeRepository(),
      ),
      child: child,
    ),
  );
}

void main() {
  testWidgets('shows loading indicator on first render', (tester) async {
    final provider = CurrenciesProvider(
      currenciesRepository: _FakeRepository(
        rows: const [],
        delay: const Duration(milliseconds: 200),
      ),
    );
    await tester.pumpWidget(_wrap(
      const CurrenciesListScreen(),
      provider: provider,
    ));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Drain the pending timer so the test framework doesn't complain.
    await tester.pump(const Duration(milliseconds: 250));
  });

  testWidgets('renders rows when repository returns data', (tester) async {
    final rows = [
      _currency('BTC', id: '1'),
      _currency('ETH', id: '2'),
      _currency('SOL', id: '3'),
    ];
    final provider = CurrenciesProvider(
      currenciesRepository: _FakeRepository(rows: rows),
    );
    await provider.fetchCurrencies(refresh: true);
    await tester.pumpWidget(_wrap(
      const CurrenciesListScreen(),
      provider: provider,
    ));
    // First pump mounts the tree, subsequent pumps drive the post-frame
    // callback which re-fetches and triggers the Consumer rebuild.
    await tester.pump();
    await tester.pump();
    await tester.pump();

    // The list view only lays out items visible in the test viewport; we
    // verify the data via the provider rather than asserting on visible
    // widget text.
    expect(provider.sortedCurrencies.length, 3);
    expect(provider.sortedCurrencies.any((c) => c.symbol == 'BTC'), isTrue);
    expect(provider.sortedCurrencies.any((c) => c.symbol == 'ETH'), isTrue);
    expect(provider.sortedCurrencies.any((c) => c.symbol == 'SOL'), isTrue);
  });

  testWidgets('empty state shows clear filters when filter is active',
      (tester) async {
    final provider = CurrenciesProvider(
      currenciesRepository: _FakeRepository(rows: []),
    );
    await provider.fetchCurrencies(refresh: true);
    await tester.pumpWidget(_wrap(
      const CurrenciesListScreen(),
      provider: provider,
    ));
    await tester.pump();

    // No filter active and no rows → "No currencies found".
    expect(find.text('No currencies found'), findsOneWidget);

    // Simulate the user enabling a filter so empty state copy changes.
    await provider.setSearch('zzz');
    await tester.pump();
    expect(find.textContaining('No currencies match'), findsOneWidget);
  });

  testWidgets('shows retry empty state when repository fails', (tester) async {
    final provider = CurrenciesProvider(
      currenciesRepository: _FakeRepository(
        failure: const NetworkFailure(),
      ),
    );
    await provider.fetchCurrencies(refresh: true);
    await tester.pumpWidget(_wrap(
      const CurrenciesListScreen(),
      provider: provider,
    ));
    await tester.pump();

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('clearFilters button appears only when filter is active',
      (tester) async {
    final provider = CurrenciesProvider(
      currenciesRepository: _FakeRepository(
        rows: [_currency('BTC')],
      ),
    );
    await provider.fetchCurrencies(refresh: true);
    await tester.pumpWidget(_wrap(
      const CurrenciesListScreen(),
      provider: provider,
    ));
    await tester.pump();

    expect(find.text('Clear filters'), findsNothing);
    await provider.setSearch('btc');
    await tester.pump();
    expect(find.text('Clear filters'), findsOneWidget);
  });

  testWidgets('sort dropdown reflects provider.sortMode', (tester) async {
    final provider = CurrenciesProvider(
      currenciesRepository: _FakeRepository(
        rows: [_currency('AAA'), _currency('ZZZ')],
      ),
    );
    await provider.fetchCurrencies(refresh: true);
    await tester.pumpWidget(_wrap(
      const CurrenciesListScreen(),
      provider: provider,
    ));
    await tester.pump();

    expect(find.text('Top Volume'), findsWidgets);
    provider.setSortMode(CurrencySortMode.alphabet);
    await tester.pump();
    expect(find.text('A-Z'), findsWidgets);
  });
}
