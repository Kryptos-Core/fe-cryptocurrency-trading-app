// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'package:js/js_util.dart' as js_util;

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
  final ethereum = js_util.getProperty(html.window, 'ethereum');
  if (ethereum == null) {
    return const MetaMaskWebSignResult(
      signature: null,
      notInstalled: true,
      accountMismatch: false,
      connectedAddress: null,
      message: 'MetaMask extension is not detected in this browser.',
    );
  }

  try {
    final dynamic accountsRaw = await js_util.promiseToFuture<dynamic>(
      js_util.callMethod(ethereum, 'request', [
        js_util.jsify({'method': 'eth_requestAccounts'})
      ]),
    );

    final accounts = <String>[];
    if (accountsRaw is List) {
      for (final account in accountsRaw) {
        accounts.add(account.toString());
      }
    }

    if (accounts.isEmpty) {
      return const MetaMaskWebSignResult(
        signature: null,
        notInstalled: false,
        accountMismatch: false,
        connectedAddress: null,
        message: 'No MetaMask account available. Please unlock MetaMask first.',
      );
    }

    final expectedLower = expectedAddress.toLowerCase();
    final selected = accounts.firstWhere(
      (a) => a.toLowerCase() == expectedLower,
      orElse: () => '',
    );

    if (selected.isEmpty) {
      return MetaMaskWebSignResult(
        signature: null,
        notInstalled: false,
        accountMismatch: true,
        connectedAddress: accounts.first,
        message:
            'Address mismatch: entered $expectedAddress but MetaMask connected ${accounts.first}. Use the same address, then try again.',
      );
    }

    final dynamic signatureRaw = await js_util.promiseToFuture<dynamic>(
      js_util.callMethod(ethereum, 'request', [
        js_util.jsify({
          'method': 'personal_sign',
          'params': [message, selected],
        })
      ]),
    );

    final signature = signatureRaw?.toString() ?? '';
    if (signature.isEmpty) {
      return const MetaMaskWebSignResult(
        signature: null,
        notInstalled: false,
        accountMismatch: false,
        connectedAddress: null,
        message: 'MetaMask did not return a signature. Please try again.',
      );
    }

    return MetaMaskWebSignResult(
      signature: signature,
      notInstalled: false,
      accountMismatch: false,
      connectedAddress: selected,
      message: 'Signature collected from MetaMask extension.',
    );
  } catch (e) {
    return MetaMaskWebSignResult(
      signature: null,
      notInstalled: false,
      accountMismatch: false,
      connectedAddress: null,
      message: 'MetaMask sign request was cancelled or failed: $e',
    );
  }
}
