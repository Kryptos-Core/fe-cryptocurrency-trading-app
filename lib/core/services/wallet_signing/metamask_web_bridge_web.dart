// Web-only implementation - loaded only on Flutter web via conditional import.
// dart:js_interop and dart:js_interop_unsafe are Dart SDK libraries (no pubspec entry needed).
// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

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
  // globalContext is window on the browser.
  final ethereumRaw = globalContext['ethereum'];
  if (ethereumRaw == null) {
    return const MetaMaskWebSignResult(
      signature: null,
      notInstalled: true,
      accountMismatch: false,
      connectedAddress: null,
      message:
          'MetaMask provider is not detected. If extension is already installed, make sure it is enabled for this site/profile, unlocked, and allowed on localhost, then refresh and try again.',
    );
  }

  final ethereum = ethereumRaw as JSObject;

  try {
    final accountsPromise = ethereum.callMethod<JSPromise<JSAny?>>(
      'request'.toJS,
      {'method': 'eth_requestAccounts'}.jsify()!,
    );

    final accountsResult = await accountsPromise.toDart;
    final accounts = <String>[];
    final accountsAsDart = accountsResult?.dartify();
    if (accountsAsDart is List) {
      for (final account in accountsAsDart) {
        if (account != null) accounts.add(account.toString());
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

    final signPromise = ethereum.callMethod<JSPromise<JSAny?>>(
      'request'.toJS,
      {
        'method': 'personal_sign',
        'params': [message, selected],
      }.jsify()!,
    );

    final signResult = await signPromise.toDart;
    final signature = signResult?.dartify()?.toString() ?? '';

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

/// Lấy địa chỉ MetaMask đang kết nối (eth_requestAccounts), trả null nếu không có.
Future<String?> metaMaskGetAddressOnWeb() async {
  final ethereumRaw = globalContext['ethereum'];
  if (ethereumRaw == null) return null;
  final ethereum = ethereumRaw as JSObject;
  try {
    final promise = ethereum.callMethod<JSPromise<JSAny?>>(
      'request'.toJS,
      {'method': 'eth_requestAccounts'}.jsify()!,
    );
    final result = await promise.toDart;
    final accounts = <String>[];
    final dartified = result?.dartify();
    if (dartified is List) {
      for (final a in dartified) {
        if (a != null) accounts.add(a.toString());
      }
    }
    return accounts.isNotEmpty ? accounts.first : null;
  } catch (_) {
    return null;
  }
}
