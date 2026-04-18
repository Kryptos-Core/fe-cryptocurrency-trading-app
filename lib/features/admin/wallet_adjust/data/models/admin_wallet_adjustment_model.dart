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
    final e = AdminWalletAdjustment.fromJson(json);
    return AdminWalletAdjustmentModel(
      adjustmentId: e.adjustmentId,
      actorUserId: e.actorUserId,
      targetUserId: e.targetUserId,
      currencyId: e.currencyId,
      amount: e.amount,
      type: e.type,
      note: e.note,
      createdAt: e.createdAt,
      actorEmail: e.actorEmail,
      targetEmail: e.targetEmail,
      currencySymbol: e.currencySymbol,
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
