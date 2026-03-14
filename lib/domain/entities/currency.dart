/// Currency entity representing a cryptocurrency
/// Following Clean Architecture - Domain Layer
class Currency {
  final String currencyId; // UUID v7
  final String symbol;
  final String name;
  final int precisionScale;
  final String minWithdraw;
  final bool isTradable;
  final bool isActive;
  final String? createdAt; // ISO 8601 date
  final String? updatedAt; // ISO 8601 date
  final String? lastPrice;
  final String? priceChangePercent24h;
  final String? volume24h;

  const Currency({
    required this.currencyId,
    required this.symbol,
    required this.name,
    required this.precisionScale,
    required this.minWithdraw,
    required this.isTradable,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.lastPrice,
    this.priceChangePercent24h,
    this.volume24h,
  });

  Currency copyWith({
    String? currencyId,
    String? symbol,
    String? name,
    int? precisionScale,
    String? minWithdraw,
    bool? isTradable,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    String? lastPrice,
    String? priceChangePercent24h,
    String? volume24h,
  }) {
    return Currency(
      currencyId: currencyId ?? this.currencyId,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      precisionScale: precisionScale ?? this.precisionScale,
      minWithdraw: minWithdraw ?? this.minWithdraw,
      isTradable: isTradable ?? this.isTradable,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastPrice: lastPrice ?? this.lastPrice,
      priceChangePercent24h:
          priceChangePercent24h ?? this.priceChangePercent24h,
      volume24h: volume24h ?? this.volume24h,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          currencyId == other.currencyId;

  @override
  int get hashCode => currencyId.hashCode;

  @override
  String toString() {
    return 'Currency(currencyId: $currencyId, symbol: $symbol, name: $name, isActive: $isActive, isTradable: $isTradable)';
  }
}
