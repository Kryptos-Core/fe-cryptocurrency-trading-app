import 'package:crypto_trading_app/features/markets/domain/entities/exchange_rate_preview.dart';

class ExchangeRatePreviewModel extends ExchangeRatePreview {
  const ExchangeRatePreviewModel({
    required super.fiatAmount,
    required super.fiatSymbol,
    required super.quoteCurrency,
    required super.grossAmount,
    required super.spreadBps,
    required super.spreadAmount,
    required super.netAmount,
    required super.effectiveRate,
    required super.marketRate,
    required super.rateSource,
    required super.validUntil,
  });

  factory ExchangeRatePreviewModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRatePreviewModel(
      fiatAmount: json['fiatAmount']?.toString() ?? '0',
      fiatSymbol: json['fiatSymbol']?.toString() ?? 'VND',
      quoteCurrency: json['quoteCurrency']?.toString() ?? 'USDT',
      grossAmount: json['grossAmount']?.toString() ?? '0',
      spreadBps: json['spreadBps']?.toString() ?? '0',
      spreadAmount: json['spreadAmount']?.toString() ?? '0',
      netAmount: json['netAmount']?.toString() ?? '0',
      effectiveRate: json['effectiveRate']?.toString() ?? '0',
      marketRate: json['marketRate']?.toString() ?? '0',
      rateSource: json['rateSource']?.toString() ?? 'unknown',
      validUntil: json['validUntil']?.toString() ?? '',
    );
  }
}
