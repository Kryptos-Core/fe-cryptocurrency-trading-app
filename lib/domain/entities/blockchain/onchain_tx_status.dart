enum OnchainTxStatus {
  pending,
  confirming,
  completed,
  failed,

  /// BE added a new status string not yet supported in this build.
  unknown,
}

extension OnchainTxStatusX on OnchainTxStatus {
  String get apiValue {
    switch (this) {
      case OnchainTxStatus.pending:
        return 'PENDING';
      case OnchainTxStatus.confirming:
        return 'CONFIRMING';
      case OnchainTxStatus.completed:
        return 'COMPLETED';
      case OnchainTxStatus.failed:
        return 'FAILED';
      case OnchainTxStatus.unknown:
        return 'UNKNOWN';
    }
  }

  static OnchainTxStatus fromApiValue(String value) {
    if (value.isEmpty) return OnchainTxStatus.unknown;
    switch (value.toUpperCase()) {
      case 'PENDING':
        return OnchainTxStatus.pending;
      case 'CONFIRMING':
        return OnchainTxStatus.confirming;
      case 'COMPLETED':
        return OnchainTxStatus.completed;
      case 'FAILED':
        return OnchainTxStatus.failed;
      default:
        return OnchainTxStatus.unknown;
    }
  }
}
