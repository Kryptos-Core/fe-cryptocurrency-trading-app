/// UserRole enum matching the backend RBAC role definitions.
/// Mirrors: src/common/enums/index.ts → UserRole
/// Không có GUEST (khách = chưa JWT); không có VERIFIED_USER (KYC: identityVerified; tích xanh email: emailVerified).
enum UserRole {
  trader,
  admin,
  riskOfficer,
  supportAgent,
  marketMaker,
  financeManager,

  /// JWT / API trả mã role mới chưa có trong bản build này — dùng [formatDisplayLabel] + raw claim để hiển thị.
  unrecognized;

  /// Parse from backend string representation (e.g. "ADMIN", "RISK_OFFICER").
  factory UserRole.fromString(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return UserRole.trader;
    switch (v.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'RISK_OFFICER':
        return UserRole.riskOfficer;
      case 'SUPPORT_AGENT':
        return UserRole.supportAgent;
      case 'MARKET_MAKER':
        return UserRole.marketMaker;
      case 'FINANCE_MANAGER':
        return UserRole.financeManager;
      case 'GUEST':
      case 'VERIFIED_USER':
      case 'TRADER':
        return UserRole.trader;
      default:
        return UserRole.unrecognized;
    }
  }

  /// Label cho drawer / profile khi JWT có role mới (chưa có enum tương ứng).
  static String formatDisplayLabel(
    UserRole role, {
    String? rawRoleClaim,
  }) {
    if (role == UserRole.unrecognized) {
      final r = rawRoleClaim?.trim();
      if (r != null && r.isNotEmpty) return _humanizeRoleCode(r);
      return 'Custom role';
    }
    return role.displayName;
  }

  static String _humanizeRoleCode(String role) {
    if (role.isEmpty) return role;
    return role
        .split('_')
        .map((part) {
          if (part.isEmpty) return part;
          final lower = part.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.length > 1 ? lower.substring(1) : ''}';
        })
        .join(' ');
  }

  /// Human-readable label for display in UI.
  String get displayName {
    switch (this) {
      case UserRole.trader:
        return 'Trader';
      case UserRole.admin:
        return 'Admin';
      case UserRole.riskOfficer:
        return 'Risk Officer';
      case UserRole.supportAgent:
        return 'Support Agent';
      case UserRole.marketMaker:
        return 'Market Maker';
      case UserRole.financeManager:
        return 'Finance Manager';
      case UserRole.unrecognized:
        return 'Custom role';
    }
  }
}
