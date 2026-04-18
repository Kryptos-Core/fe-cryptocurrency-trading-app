import 'package:crypto_trading_app/features/markets/domain/entities/exchange_rate_preview.dart';
import 'package:crypto_trading_app/features/markets/domain/entities/market_price.dart';
import 'package:crypto_trading_app/features/markets/domain/repositories/exchange_rate_repository.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/exchange_rate_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeExchangeRateRepository implements ExchangeRateRepository {
  ExchangeRatePreview previewResponse;
  List<MarketPrice> marketPricesResponse;

  _FakeExchangeRateRepository({
    required this.previewResponse,
    required this.marketPricesResponse,
  });

  @override
  Future<ExchangeRatePreview> getDepositPreview(
    int fiatAmount, {
    String fiatSymbol = 'VND',
  }) async {
    return previewResponse;
  }

  @override
  Future<List<MarketPrice>> getMarketPrices({List<String>? symbols}) async {
    return marketPricesResponse;
  }
}

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

  const prices = [
    MarketPrice(symbol: 'BTC', priceUsd: '63500', priceVnd: '1590000000'),
    MarketPrice(symbol: 'USDT', priceUsd: '1', priceVnd: '25100'),
  ];

  test('fetchDepositPreview stores preview result', () async {
    final provider = ExchangeRateProvider(
      repository: _FakeExchangeRateRepository(
        previewResponse: preview,
        marketPricesResponse: prices,
      ),
    );

    await provider.fetchDepositPreview(500000);

    expect(provider.depositPreview, isNotNull);
    expect(provider.depositPreview?.netAmount, '19.90000000');
    expect(provider.isLoadingPreview, isFalse);
    expect(provider.error, isNull);
  });

  test('fetchMarketPrices stores price list', () async {
    final provider = ExchangeRateProvider(
      repository: _FakeExchangeRateRepository(
        previewResponse: preview,
        marketPricesResponse: prices,
      ),
    );

    await provider.fetchMarketPrices();

    expect(provider.marketPrices.length, 2);
    expect(provider.marketPrices.first.symbol, 'BTC');
    expect(provider.isLoadingPrices, isFalse);
  });

  test('scheduleDepositPreview clears preview when amount is invalid',
      () async {
    final provider = ExchangeRateProvider(
      repository: _FakeExchangeRateRepository(
        previewResponse: preview,
        marketPricesResponse: prices,
      ),
    );

    await provider.fetchDepositPreview(500000);
    expect(provider.depositPreview, isNotNull);

    provider.scheduleDepositPreview(null);

    expect(provider.depositPreview, isNull);
  });
}
