import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/features/markets/domain/dtos/create_currency_dto.dart';
import 'package:crypto_trading_app/features/markets/domain/dtos/update_currency_dto.dart';
import 'package:crypto_trading_app/features/markets/domain/entities/currency.dart';
import 'package:crypto_trading_app/features/markets/domain/repositories/currencies_repository.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/currencies_provider.dart';

Currency _make({
  required String id,
  required String symbol,
  String name = 'Token',
  String? lastPrice,
  String? priceChangePercent24h,
  String? volume24h,
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
    priceChangePercent24h: priceChangePercent24h,
    volume24h: volume24h,
  );
}

/// In-memory fake used to drive the provider deterministically.
class FakeCurrenciesRepository implements CurrenciesRepository {
  FakeCurrenciesRepository({this.firstPage = const []});

  List<Currency> firstPage;
  PaginatedCurrenciesResult? nextResult;
  Failure? failure;
  int getCurrenciesCalls = 0;

  @override
  Future<Either<Failure, PaginatedCurrenciesResult>> getCurrencies({
    int page = 1,
    int limit = 10,
    bool includeInactive = false,
    String? search,
    bool? isTradable,
    bool? isActive,
  }) async {
    getCurrenciesCalls++;
    if (failure != null) return Left(failure!);
    if (nextResult != null && page > 1) return Right(nextResult!);
    return Right(
      PaginatedCurrenciesResult(
        currencies: firstPage,
        total: firstPage.length,
        page: page,
        limit: limit,
      ),
    );
  }

  @override
  Future<Either<Failure, Currency>> getCurrencyById(String currencyId) async {
    final found = firstPage
        .where((c) => c.currencyId == currencyId)
        .cast<Currency?>()
        .firstWhere((_) => true, orElse: () => null);
    if (found != null) return Right(found);
    return const Left(NotFoundFailure(message: 'not found'));
  }

  @override
  Future<Either<Failure, Currency>> getCurrencyBySymbol(String symbol) async {
    final found = firstPage
        .where((c) => c.symbol == symbol)
        .cast<Currency?>()
        .firstWhere((_) => true, orElse: () => null);
    if (found != null) return Right(found);
    return const Left(NotFoundFailure(message: 'not found'));
  }

  @override
  Future<Either<Failure, List<Currency>>> getActiveCurrencies() async =>
      const Right([]);

  @override
  Future<Either<Failure, List<Currency>>> getTradableCurrencies() async =>
      const Right([]);

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CurrenciesProvider.filter+sort', () {
    test('hasActiveFilter starts false', () {
      final provider = CurrenciesProvider(
        currenciesRepository: FakeCurrenciesRepository(),
      );
      expect(provider.hasActiveFilter, isFalse);
      expect(provider.sortMode, CurrencySortMode.topVolume);
    });

    test('setSearch updates query and refetches', () async {
      final repo = FakeCurrenciesRepository();
      final provider = CurrenciesProvider(currenciesRepository: repo);
      await provider.fetchCurrencies(refresh: true);
      final initialCalls = repo.getCurrenciesCalls;
      await provider.setSearch('btc');
      expect(provider.searchQuery, 'btc');
      expect(provider.hasActiveFilter, isTrue);
      expect(repo.getCurrenciesCalls, initialCalls + 1);
    });

    test('setSearch ignores identical normalized values', () async {
      final repo = FakeCurrenciesRepository();
      final provider = CurrenciesProvider(currenciesRepository: repo);
      await provider.fetchCurrencies(refresh: true);
      final calls = repo.getCurrenciesCalls;
      await provider.setSearch('  BTC ');
      await provider.setSearch('btc');
      expect(repo.getCurrenciesCalls, calls + 1);
    });

    test('setTradingFilter toggles isTradable filter', () async {
      final repo = FakeCurrenciesRepository();
      final provider = CurrenciesProvider(currenciesRepository: repo);
      await provider.fetchCurrencies(refresh: true);
      await provider.setTradingFilter(isTradable: true);
      expect(provider.filterTradable, isTrue);
      expect(provider.hasActiveFilter, isTrue);
    });

    test('setStatusFilter flips includeInactive when showing inactive only',
        () async {
      final repo = FakeCurrenciesRepository();
      final provider = CurrenciesProvider(currenciesRepository: repo);
      await provider.fetchCurrencies(refresh: true);
      await provider.setStatusFilter(isActive: false);
      expect(provider.filterIsActive, isFalse);
      expect(provider.includeInactive, isTrue);
    });

    test('setSortMode updates mode and does not refetch', () async {
      final repo = FakeCurrenciesRepository();
      final provider = CurrenciesProvider(currenciesRepository: repo);
      await provider.fetchCurrencies(refresh: true);
      final calls = repo.getCurrenciesCalls;
      provider.setSortMode(CurrencySortMode.alphabet);
      expect(provider.sortMode, CurrencySortMode.alphabet);
      expect(repo.getCurrenciesCalls, calls);
    });

    test('clearFilters resets every filter and sort', () async {
      final repo = FakeCurrenciesRepository();
      final provider = CurrenciesProvider(currenciesRepository: repo);
      await provider.fetchCurrencies(refresh: true);
      await provider.setSearch('btc');
      await provider.setTradingFilter(isTradable: true);
      provider.setSortMode(CurrencySortMode.alphabet);

      await provider.clearFilters();
      expect(provider.searchQuery, isEmpty);
      expect(provider.filterTradable, isNull);
      expect(provider.filterIsActive, isNull);
      expect(provider.includeInactive, isFalse);
      expect(provider.sortMode, CurrencySortMode.topVolume);
      expect(provider.hasActiveFilter, isFalse);
    });

    test('sortedCurrencies sorts by symbol alphabetically', () async {
      final repo = FakeCurrenciesRepository(
        firstPage: [
          _make(id: '1', symbol: 'ZRX', volume24h: '100'),
          _make(id: '2', symbol: 'AAA', volume24h: '50'),
          _make(id: '3', symbol: 'MNT', volume24h: '75'),
        ],
      );
      final provider = CurrenciesProvider(currenciesRepository: repo);
      await provider.fetchCurrencies(refresh: true);
      provider.setSortMode(CurrencySortMode.alphabet);
      final symbols = provider.sortedCurrencies.map((c) => c.symbol).toList();
      expect(symbols, ['AAA', 'MNT', 'ZRX']);
    });

    test('sortedCurrencies sorts top gainers by descending change', () async {
      final repo = FakeCurrenciesRepository(
        firstPage: [
          _make(id: '1', symbol: 'AAA', priceChangePercent24h: '-5'),
          _make(id: '2', symbol: 'BBB', priceChangePercent24h: '12'),
          _make(id: '3', symbol: 'CCC', priceChangePercent24h: '0.5'),
        ],
      );
      final provider = CurrenciesProvider(currenciesRepository: repo);
      await provider.fetchCurrencies(refresh: true);
      provider.setSortMode(CurrencySortMode.topGainers);
      final symbols = provider.sortedCurrencies.map((c) => c.symbol).toList();
      expect(symbols, ['BBB', 'CCC', 'AAA']);
    });

    test('sortedCurrencies sorts top losers by ascending change', () async {
      final repo = FakeCurrenciesRepository(
        firstPage: [
          _make(id: '1', symbol: 'AAA', priceChangePercent24h: '-5'),
          _make(id: '2', symbol: 'BBB', priceChangePercent24h: '12'),
          _make(id: '3', symbol: 'CCC', priceChangePercent24h: '0.5'),
        ],
      );
      final provider = CurrenciesProvider(currenciesRepository: repo);
      await provider.fetchCurrencies(refresh: true);
      provider.setSortMode(CurrencySortMode.topLosers);
      final symbols = provider.sortedCurrencies.map((c) => c.symbol).toList();
      expect(symbols, ['AAA', 'CCC', 'BBB']);
    });
  });

  group('CurrenciesProvider.fetchCurrencies', () {
    test('emits error and resets loading state when repository fails',
        () async {
      final repo = FakeCurrenciesRepository()
        ..failure = const NetworkFailure();
      final provider = CurrenciesProvider(currenciesRepository: repo);
      var notified = 0;
      provider.addListener(() => notified++);

      await provider.fetchCurrencies(refresh: true);

      expect(provider.isLoading, isFalse);
      expect(provider.error, isNotNull);
      expect(notified, greaterThanOrEqualTo(2));
    });

    test('loadMore no-ops when hasMore is false', () async {
      final repo = FakeCurrenciesRepository();
      final provider = CurrenciesProvider(currenciesRepository: repo);
      await provider.fetchCurrencies(refresh: true);
      // hasMore becomes false because total equals current length after first fetch
      expect(provider.hasMore, isFalse);
      final calls = repo.getCurrenciesCalls;
      await provider.loadMore();
      expect(repo.getCurrenciesCalls, calls);
    });
  });
}
