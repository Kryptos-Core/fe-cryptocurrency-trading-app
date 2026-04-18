import 'package:crypto_trading_app/features/deposits/domain/entities/deposit.dart';

class DepositModel extends Deposit {
  const DepositModel({
    required super.depositId,
    required super.userId,
    required super.amount,
    required super.status,
    required super.orderCode,
    required super.checkoutUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DepositModel.fromJson(Map<String, dynamic> json) {
    return DepositModel(
      depositId: json['deposit_id'] ?? json['depositId'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      amount: json['amount'] ?? '0',
      status: json['status'] ?? 'PENDING',
      orderCode: json['order_code'] ?? json['orderCode'] ?? 0,
      checkoutUrl: json['checkout_url'] ?? json['checkoutUrl'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ??
          json['createdAt'] ??
          DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ??
          json['updatedAt'] ??
          DateTime.now().toIso8601String()),
    );
  }
}
