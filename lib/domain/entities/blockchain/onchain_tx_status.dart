enum OnchainTxStatus {
  pending,
  confirming,
  completed,
  failed,
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
    }
  }

  static OnchainTxStatus fromApiValue(String value) {
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
        throw ArgumentError('Unsupported on-chain tx status: $value');
    }
  }
}
