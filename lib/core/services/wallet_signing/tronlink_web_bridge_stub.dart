class TronLinkWebSignResult {
  final String? signature;
  final bool notInstalled;
  final bool accountMismatch;
  final String? connectedAddress;
  final String message;

  const TronLinkWebSignResult({
    required this.signature,
    required this.notInstalled,
    required this.accountMismatch,
    required this.connectedAddress,
    required this.message,
  });
}

Future<TronLinkWebSignResult> tronLinkSignOnWeb({
  required String message,
  required String expectedAddress,
}) async {
  return const TronLinkWebSignResult(
    signature: null,
    notInstalled: false,
    accountMismatch: false,
    connectedAddress: null,
    message: 'TronLink direct signing is only available on web.',
  );
}

/// Lấy địa chỉ TronLink đang kết nối (stub — non-web).
Future<String?> tronLinkGetAddressOnWeb() async => null;
