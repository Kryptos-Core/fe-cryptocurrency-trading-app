enum LinkedWalletStatus {
  pending,
  verified,
  revoked,
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
        throw ArgumentError('Unsupported linked wallet status: $value');
    }
  }
}
