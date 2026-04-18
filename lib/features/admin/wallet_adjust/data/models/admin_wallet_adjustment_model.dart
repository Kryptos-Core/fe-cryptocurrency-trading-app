import 'package:crypto_trading_app/features/admin/wallet_adjust/domain/entities/admin_wallet_adjustment.dart';

/// Data Transfer Object cho AdminWalletAdjustment.
/// Xử lý JSON từ API và chuyển đổi sang domain entity.
class AdminWalletAdjustmentModel {
  final String adjustmentId;
  final String actorUserId;
  final String targetUserId;
  final String currencyId;
  final String amount;
  final String type;
  final String? note;
  final DateTime createdAt;
  final String? actorEmail;
  final String? targetEmail;
  final String? currencySymbol;

  const AdminWalletAdjustmentModel({
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

  factory AdminWalletAdjustmentModel.fromJson(Map<String, dynamic> json) {
    return AdminWalletAdjustmentModel(
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

  AdminWalletAdjustment toEntity() {
    return AdminWalletAdjustment(
      adjustmentId: adjustmentId,
      actorUserId: actorUserId,
      targetUserId: targetUserId,
      currencyId: currencyId,
      amount: amount,
      type: type,
      note: note,
      createdAt: createdAt,
      actorEmail: actorEmail,
      targetEmail: targetEmail,
      currencySymbol: currencySymbol,
    );
  }
}
