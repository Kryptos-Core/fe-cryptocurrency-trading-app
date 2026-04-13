import 'package:crypto_trading_app/domain/entities/exchange_rate_preview.dart';
import 'package:crypto_trading_app/domain/entities/market_price.dart';

abstract class ExchangeRateRepository {
  Future<ExchangeRatePreview> getDepositPreview(int fiatAmount, {String fiatSymbol = 'VND'});
  Future<List<MarketPrice>> getMarketPrices({List<String>? symbols});
}
