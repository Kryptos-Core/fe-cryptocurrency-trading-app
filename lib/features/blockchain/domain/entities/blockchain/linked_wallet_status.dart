enum LinkedWalletStatus {
  pending,
  verified,
  revoked,

  /// BE added a new status string not yet supported in this build.
  unknown,
}

extension LinkedWalletStatusX on LinkedWalletStatus {
  String get apiValue {
    switch (this) {
      case LinkedWalletStatus.pending:
        return 'PENDING';
      case LinkedWalletStatus.verified:
        return 'VERIFIED';
      case LinkedWalletStatus.revoked:
        return 'REVOKED';
      case LinkedWalletStatus.unknown:
        return 'UNKNOWN';
    }
  }

  static LinkedWalletStatus fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return LinkedWalletStatus.pending;
      case 'VERIFIED':
        return LinkedWalletStatus.verified;
      case 'REVOKED':
        return LinkedWalletStatus.revoked;
      default:
        return LinkedWalletStatus.unknown;
    }
  }
}
