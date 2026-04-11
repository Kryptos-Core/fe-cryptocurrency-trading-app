/// Parsed payload from GET /enums (inside standard API `data` envelope).
class AdminEnumsSnapshot {
  final List<String> orderStatus;
  final List<String> depositStatus;
  final List<String> withdrawalStatus;
  final List<String> userRole;
  final List<String> userStatus;
  final List<String> treasuryWalletPurpose;

  const AdminEnumsSnapshot({
    required this.orderStatus,
    required this.depositStatus,
    required this.withdrawalStatus,
    required this.userRole,
    required this.userStatus,
    required this.treasuryWalletPurpose,
  });

  /// Client fallback when API is unreachable — mirrors BE [buildAdminEnumsPayload].
  factory AdminEnumsSnapshot.fallback() {
    return const AdminEnumsSnapshot(
      orderStatus: [
        'OPEN',
        'PARTIAL',
        'FILLED',
        'CANCELLED',
        'REJECTED',
      ],
      depositStatus: ['PENDING', 'PAID', 'CANCELLED'],
      withdrawalStatus: [
        'PENDING',
        'CONFIRMING',
        'COMPLETED',
        'FAILED',
      ],
      userRole: [
        'TRADER',
        'ADMIN',
        'RISK_OFFICER',
        'SUPPORT_AGENT',
        'MARKET_MAKER',
        'FINANCE_MANAGER',
      ],
      userStatus: ['ACTIVE', 'BANNED', 'PENDING'],
      treasuryWalletPurpose: ['DEPOSIT', 'WITHDRAWAL', 'BOTH'],
    );
  }

  factory AdminEnumsSnapshot.fromApiMap(Map<String, dynamic> raw) {
    List<String> strings(String key) {
      final v = raw[key];
      if (v is! List) return [];
      return v.map((e) => e.toString()).toList();
    }

    return AdminEnumsSnapshot(
      orderStatus: strings('orderStatus'),
      depositStatus: strings('depositStatus'),
      withdrawalStatus: strings('withdrawalStatus'),
      userRole: strings('userRole'),
      userStatus: strings('userStatus'),
      treasuryWalletPurpose: strings('treasuryWalletPurpose'),
    );
  }

  /// Merge API snapshot with fallback so empty keys do not wipe UI.
  AdminEnumsSnapshot mergedWithFallback() {
    final fb = AdminEnumsSnapshot.fallback();
    return AdminEnumsSnapshot(
      orderStatus: orderStatus.isNotEmpty ? orderStatus : fb.orderStatus,
      depositStatus: depositStatus.isNotEmpty ? depositStatus : fb.depositStatus,
      withdrawalStatus:
          withdrawalStatus.isNotEmpty ? withdrawalStatus : fb.withdrawalStatus,
      userRole: userRole.isNotEmpty ? userRole : fb.userRole,
      userStatus: userStatus.isNotEmpty ? userStatus : fb.userStatus,
      treasuryWalletPurpose: treasuryWalletPurpose.isNotEmpty
          ? treasuryWalletPurpose
          : fb.treasuryWalletPurpose,
    );
  }
}
