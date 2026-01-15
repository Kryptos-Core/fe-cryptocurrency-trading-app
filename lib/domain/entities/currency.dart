/// Currency entity representing a cryptocurrency
/// Following Clean Architecture - Domain Layer
class Currency {
  final int currencyId;
  final String symbol;
  final String name;
  final int precisionScale;
  final String minWithdraw;
  final bool isTradable;
  final bool isActive;

  const Currency({
    required this.currencyId,
    required this.symbol,
    required this.name,
    required this.precisionScale,
    required this.minWithdraw,
    required this.isTradable,
    required this.isActive,
  });

  Currency copyWith({
    int? currencyId,
    String? symbol,
    String? name,
    int? precisionScale,
    String? minWithdraw,
    bool? isTradable,
    bool? isActive,
  }) {
    return Currency(
      currencyId: currencyId ?? this.currencyId,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      precisionScale: precisionScale ?? this.precisionScale,
      minWithdraw: minWithdraw ?? this.minWithdraw,
      isTradable: isTradable ?? this.isTradable,
      isActive: isActive ?? this.isActive,
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
