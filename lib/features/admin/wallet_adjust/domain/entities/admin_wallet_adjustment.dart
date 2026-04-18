/// Đại diện cho một lần điều chỉnh số dư ví thủ công bởi admin/risk officer.
/// Domain Layer — Clean Architecture.
class AdminWalletAdjustment {
  final String adjustmentId;
  final String actorUserId;
  final String targetUserId;
  final String currencyId;
  final String amount;

  /// 'DEPOSIT' hoặc 'WITHDRAW'
  final String type;

  final String? note;
  final DateTime createdAt;

  /// Thông tin mở rộng (join từ BE, nullable)
  final String? actorEmail;
  final String? targetEmail;
  final String? currencySymbol;

  const AdminWalletAdjustment({
    required this.adjustmentId,
    required this.actorUserId,
    required this.targetUserId,
    required this.currencyId,
    required this.amount,
    required this.type,
    required this.createdAt,
    this.note,
    this.actorEmail,
    this.targetEmail,
    this.currencySymbol,
  });

  factory AdminWalletAdjustment.fromJson(Map<String, dynamic> json) {
    return AdminWalletAdjustment(
      adjustmentId: json['adjustmentId']?.toString() ?? '',
      actorUserId: json['actorUserId']?.toString() ?? '',
      targetUserId: json['targetUserId']?.toString() ?? '',
      currencyId: json['currencyId']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      type: json['type']?.toString() ?? 'DEPOSIT',
      note: json['note']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      actorEmail: json['actorEmail']?.toString(),
      targetEmail: json['targetEmail']?.toString(),
      currencySymbol: json['currencySymbol']?.toString(),
    );
  }

  bool get isDeposit => type == 'DEPOSIT';
  bool get isWithdraw => type == 'WITHDRAW';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminWalletAdjustment &&
          runtimeType == other.runtimeType &&
          adjustmentId == other.adjustmentId;

  @override
  int get hashCode => adjustmentId.hashCode;

  @override
  String toString() =>
      'AdminWalletAdjustment(id: $adjustmentId, type: $type, amount: $amount, target: $targetUserId)';
}
