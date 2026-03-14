class MetaMaskWebSignResult {
  final String? signature;
  final bool notInstalled;
  final bool accountMismatch;
  final String? connectedAddress;
  final String message;

  const MetaMaskWebSignResult({
    required this.signature,
    required this.notInstalled,
    required this.accountMismatch,
    required this.connectedAddress,
    required this.message,
  });
}

Future<MetaMaskWebSignResult> metaMaskSignOnWeb({
  required String message,
  required String expectedAddress,
}) async {
  return const MetaMaskWebSignResult(
    signature: null,
    notInstalled: false,
    accountMismatch: false,
    connectedAddress: null,
    message: 'MetaMask direct signing is only available on web.',
  );
}
