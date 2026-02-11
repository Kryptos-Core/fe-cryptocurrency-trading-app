/// DTO gửi lên BE POST /orders (camelCase)
class CreateOrderRequestDto {
  final int pairId;
  final String side; // BUY | SELL
  final String type; // LIMIT | MARKET
  final String? price;
  final String amount;
  final String timeInForce; // GTC | IOC | FOK
  final String? clientOrderId;
  final String idempotencyKey;

  const CreateOrderRequestDto({
    required this.pairId,
    required this.side,
    required this.type,
    this.price,
    required this.amount,
    this.timeInForce = 'GTC',
    this.clientOrderId,
    required this.idempotencyKey,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'pairId': pairId,
      'side': side,
      'type': type,
      'amount': amount,
      'timeInForce': timeInForce,
      'idempotencyKey': idempotencyKey,
    };
    if (price != null) map['price'] = price;
    if (clientOrderId != null && clientOrderId!.isNotEmpty) {
      map['clientOrderId'] = clientOrderId;
    }
    return map;
  }
}
