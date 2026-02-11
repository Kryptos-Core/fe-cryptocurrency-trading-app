import 'package:equatable/equatable.dart';

/// Một mức giá trong order book (Orders API)
///
/// GET /orders/book/:pairId?side=BUY|SELL
class OrderBookLevel extends Equatable {
  final String price;
  final String remaining;
  final int orderCount;

  const OrderBookLevel({
    required this.price,
    required this.remaining,
    required this.orderCount,
  });

  @override
  List<Object?> get props => [price, remaining, orderCount];
}
