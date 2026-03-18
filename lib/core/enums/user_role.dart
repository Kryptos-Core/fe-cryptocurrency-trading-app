/// UserRole enum matching the backend RBAC role definitions.
/// Mirrors: src/common/enums/index.ts → UserRole
enum UserRole {
  guest,
  trader,
  verifiedUser,
  admin,
  riskOfficer,
  supportAgent,
  marketMaker,
  financeManager;

  /// Parse from backend string representation (e.g. "ADMIN", "RISK_OFFICER").
  factory UserRole.fromString(String? value) {
    switch ((value ?? '').toUpperCase()) {
      case 'GUEST':
        return UserRole.guest;
      case 'VERIFIED_USER':
        return UserRole.verifiedUser;
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
      case 'TRADER':
      default:
        return UserRole.trader;
    }
  }

  /// Human-readable label for display in UI.
  String get displayName {
    switch (this) {
      case UserRole.guest:
        return 'Guest';
      case UserRole.trader:
        return 'Trader';
      case UserRole.verifiedUser:
        return 'Verified User';
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
    }
  }
}
