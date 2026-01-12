import 'package:equatable/equatable.dart';

/// Currency Entity - Domain Layer
class Currency extends Equatable {
  final int currencyId;
  final String symbol;
  final String name;
  final int precisionScale;
  final double minWithdraw;
  final bool isTradable;
  final bool isActive;

  const Currency({
    required this.currencyId,
    required this.symbol,
    required this.name,
    this.precisionScale = 8,
    this.minWithdraw = 0.0,
    this.isTradable = true,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        currencyId,
        symbol,
        name,
        precisionScale,
        minWithdraw,
        isTradable,
        isActive,
      ];

  Currency copyWith({
    int? currencyId,
    String? symbol,
    String? name,
    int? precisionScale,
    double? minWithdraw,
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
}
