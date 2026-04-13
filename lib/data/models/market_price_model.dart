import 'package:crypto_trading_app/domain/entities/market_price.dart';

class MarketPriceModel extends MarketPrice {
  const MarketPriceModel({
    required super.symbol,
    required super.priceUsd,
    required super.priceVnd,
  });

  factory MarketPriceModel.fromJson(Map<String, dynamic> json) {
    return MarketPriceModel(
      symbol: json['symbol']?.toString() ?? '',
      priceUsd: json['priceUsd']?.toString() ?? '0',
      priceVnd: json['priceVnd']?.toString() ?? '0',
    );
  }
}
