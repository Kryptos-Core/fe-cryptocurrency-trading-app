import 'package:equatable/equatable.dart';

/// Market Pair Entity - Domain Layer
class MarketPair extends Equatable {
  final int pairId;
  final int baseCurrencyId;
  final int quoteCurrencyId;
  final String symbol; // e.g., "BTC/USDT"
  final int priceScale;
  final int amountScale;
  final double minOrderAmount;
  final double makerFeeRate;
  final double takerFeeRate;
  final bool isActive;
  final DateTime createdAt;

  const MarketPair({
    required this.pairId,
    required this.baseCurrencyId,
    required this.quoteCurrencyId,
    required this.symbol,
    this.priceScale = 2,
    this.amountScale = 6,
    this.minOrderAmount = 0.0001,
    this.makerFeeRate = 0.001,
    this.takerFeeRate = 0.001,
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        pairId,
        baseCurrencyId,
        quoteCurrencyId,
        symbol,
        priceScale,
        amountScale,
        minOrderAmount,
        makerFeeRate,
        takerFeeRate,
        isActive,
        createdAt,
      ];

  MarketPair copyWith({
    int? pairId,
    int? baseCurrencyId,
    int? quoteCurrencyId,
    String? symbol,
    int? priceScale,
    int? amountScale,
    double? minOrderAmount,
    double? makerFeeRate,
    double? takerFeeRate,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return MarketPair(
      pairId: pairId ?? this.pairId,
      baseCurrencyId: baseCurrencyId ?? this.baseCurrencyId,
      quoteCurrencyId: quoteCurrencyId ?? this.quoteCurrencyId,
      symbol: symbol ?? this.symbol,
      priceScale: priceScale ?? this.priceScale,
      amountScale: amountScale ?? this.amountScale,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      makerFeeRate: makerFeeRate ?? this.makerFeeRate,
      takerFeeRate: takerFeeRate ?? this.takerFeeRate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
