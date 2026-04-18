class ExchangeRatePreview {
  final String fiatAmount;
  final String fiatSymbol;
  final String quoteCurrency;
  final String grossAmount;
  final String spreadBps;
  final String spreadAmount;
  final String netAmount;
  final String effectiveRate;
  final String marketRate;
  final String rateSource;
  final String validUntil;

  const ExchangeRatePreview({
    required this.fiatAmount,
    required this.fiatSymbol,
    required this.quoteCurrency,
    required this.grossAmount,
    required this.spreadBps,
    required this.spreadAmount,
    required this.netAmount,
    required this.effectiveRate,
    required this.marketRate,
    required this.rateSource,
    required this.validUntil,
  });
}
