import 'package:equatable/equatable.dart';

class BinanceSpotBalance extends Equatable {
  final String asset;
  final String free;
  final String locked;

  const BinanceSpotBalance({
    required this.asset,
    required this.free,
    required this.locked,
  });

  String get total => ((double.tryParse(free) ?? 0) + (double.tryParse(locked) ?? 0)).toStringAsFixed(8);

  @override
  List<Object?> get props => [asset, free, locked];
}

class BinanceSpotOrder extends Equatable {
  final String orderId;
  final String symbol;
  final String side;
  final String type;
  final String price;
  final String origQty;
  final String executedQty;
  final String status;
  final int time;
  final int updateTime;
  final bool isIsolated;

  const BinanceSpotOrder({
    required this.orderId,
    required this.symbol,
    required this.side,
    required this.type,
    required this.price,
    required this.origQty,
    required this.executedQty,
    required this.status,
    required this.time,
    required this.updateTime,
    required this.isIsolated,
  });

  @override
  List<Object?> get props => [orderId, symbol, side, type, price, origQty, executedQty, status, time, updateTime];
}

class BinanceSpotOrderResult extends Equatable {
  final String orderId;
  final String symbol;
  final String side;
  final String type;
  final String price;
  final String origQty;
  final String executedQty;
  final String status;
  final int transactTime;

  const BinanceSpotOrderResult({
    required this.orderId,
    required this.symbol,
    required this.side,
    required this.type,
    required this.price,
    required this.origQty,
    required this.executedQty,
    required this.status,
    required this.transactTime,
  });

  @override
  List<Object?> get props => [orderId, symbol, side, type, price, origQty, executedQty, status, transactTime];
}

class BinanceFuturesPosition extends Equatable {
  final String symbol;
  final String positionSide;
  final String positionAmt;
  final String entryPrice;
  final String markPrice;
  final String unrealizedPnL;
  final String marginType;
  final String isolatedMargin;
  final String leverage;

  const BinanceFuturesPosition({
    required this.symbol,
    required this.positionSide,
    required this.positionAmt,
    required this.entryPrice,
    required this.markPrice,
    required this.unrealizedPnL,
    required this.marginType,
    required this.isolatedMargin,
    required this.leverage,
  });

  @override
  List<Object?> get props => [symbol, positionSide, positionAmt, entryPrice, markPrice, unrealizedPnL, marginType, isolatedMargin, leverage];
}

class BinanceFuturesBalance extends Equatable {
  final String asset;
  final String walletBalance;
  final String unrealizedProfit;
  final String availableBalance;

  const BinanceFuturesBalance({
    required this.asset,
    required this.walletBalance,
    required this.unrealizedProfit,
    required this.availableBalance,
  });

  @override
  List<Object?> get props => [asset, walletBalance, unrealizedProfit, availableBalance];
}
