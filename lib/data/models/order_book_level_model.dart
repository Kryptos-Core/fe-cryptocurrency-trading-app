import 'package:crypto_trading_app/domain/entities/order_book_level.dart';

String _str(dynamic v) {
  if (v == null) return '0';
  return v.toString();
}

int _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

class OrderBookLevelModel {
  final String price;
  final String remaining;
  final int orderCount;

  OrderBookLevelModel({
    required this.price,
    required this.remaining,
    required this.orderCount,
  });

  factory OrderBookLevelModel.fromJson(Map<String, dynamic> json) {
    return OrderBookLevelModel(
      price: _str(json['price']),
      remaining: _str(json['remaining']),
      orderCount: _int(json['order_count']),
    );
  }

  OrderBookLevel toDomain() => OrderBookLevel(
        price: price,
        remaining: remaining,
        orderCount: orderCount,
      );
}
