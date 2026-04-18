import 'package:equatable/equatable.dart';

class Deposit extends Equatable {
  final String depositId;
  final String userId;
  final String amount;
  final String status; // PENDING, PAID, CANCELLED
  final int orderCode;
  final String checkoutUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Deposit({
    required this.depositId,
    required this.userId,
    required this.amount,
    required this.status,
    required this.orderCode,
    required this.checkoutUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        depositId,
        userId,
        amount,
        status,
        orderCode,
        checkoutUrl,
        createdAt,
        updatedAt,
      ];
}
