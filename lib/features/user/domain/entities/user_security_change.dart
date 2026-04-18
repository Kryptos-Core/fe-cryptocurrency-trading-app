/// Đại diện một yêu cầu thay đổi thông tin bảo mật (email/password) của người dùng.
/// Domain Layer — Clean Architecture.
class UserSecurityChange {
  final String requestId;
  final String changeType; // EMAIL_CHANGE | PASSWORD_CHANGE
  final String status; // PENDING | APPROVED | REJECTED
  final DateTime requestedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? reviewNote;

  const UserSecurityChange({
    required this.requestId,
    required this.changeType,
    required this.status,
    required this.requestedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewNote,
  });

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';

  String get changeTypeLabel {
    switch (changeType) {
      case 'EMAIL_CHANGE':
        return 'Đổi email';
      case 'PASSWORD_CHANGE':
        return 'Đổi mật khẩu';
      default:
        return changeType;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSecurityChange &&
          runtimeType == other.runtimeType &&
          requestId == other.requestId;

  @override
  int get hashCode => requestId.hashCode;

  @override
  String toString() =>
      'UserSecurityChange(requestId: $requestId, type: $changeType, status: $status)';
}
