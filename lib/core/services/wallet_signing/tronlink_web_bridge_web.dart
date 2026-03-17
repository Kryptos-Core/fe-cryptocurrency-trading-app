// Web-only implementation - loaded only on Flutter web via conditional import.
// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

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
  final hasTronEnv = globalContext.callMethod<JSAny?>(
    'eval'.toJS,
    '!!(window.tronLink || window.tronWeb)'.toJS,
  );
  if (hasTronEnv?.dartify() != true) {
    return const TronLinkWebSignResult(
      signature: null,
      notInstalled: true,
      accountMismatch: false,
      connectedAddress: null,
      message:
          'TronLink provider is not detected. If extension is already installed, ensure it is enabled for this browser profile, unlocked, and has access to this site, then refresh and try again.',
    );
  }

  final tronLinkRaw = globalContext['tronLink'];
  final tronLink = tronLinkRaw is JSObject ? tronLinkRaw : null;
  final tronWebRaw = globalContext['tronWeb'];
  final tronWeb = tronWebRaw is JSObject ? tronWebRaw : null;

  try {
    if (tronLink != null) {
      await _tryRequestAccounts(tronLink);
    }

    // Lấy địa chỉ qua eval để tránh Proxy edge cases
    final connectedAddress = _getAddressViaEval();

    if (connectedAddress.isEmpty) {
      return const TronLinkWebSignResult(
        signature: null,
        notInstalled: false,
        accountMismatch: false,
        connectedAddress: null,
        message:
            'No TronLink account available. Please unlock TronLink and connect this site first.',
      );
    }

    final expectedLower = expectedAddress.toLowerCase();
    final connectedLower = connectedAddress.toLowerCase();
    if (connectedLower != expectedLower) {
      return TronLinkWebSignResult(
        signature: null,
        notInstalled: false,
        accountMismatch: true,
        connectedAddress: connectedAddress,
        message:
            'Address mismatch: connected $connectedAddress but expected $expectedAddress.',
      );
    }

    final signature = await _requestSignature(
      tronLink: tronLink,
      tronWeb: tronWeb,
      message: message,
    );

    if (signature.isEmpty) {
      return const TronLinkWebSignResult(
        signature: null,
        notInstalled: false,
        accountMismatch: false,
        connectedAddress: null,
        message: 'TronLink did not return a signature. Please try again.',
      );
    }

    return TronLinkWebSignResult(
      signature: signature,
      notInstalled: false,
      accountMismatch: false,
      connectedAddress: connectedAddress,
      message: 'Signature collected from TronLink extension.',
    );
  } catch (e) {
    return TronLinkWebSignResult(
      signature: null,
      notInstalled: false,
      accountMismatch: false,
      connectedAddress: null,
      message: 'TronLink sign request was cancelled or failed: $e',
    );
  }
}

/// Lấy địa chỉ TRON hiện tại qua JS eval — hoàn toàn bỏ qua Dart interop Proxy issues.
String _getAddressViaEval() {
  final result = globalContext.callMethod<JSAny?>(
    'eval'.toJS,
    r'''(function() {
      try {
        var tw = window.tronWeb || (window.tronLink && window.tronLink.tronWeb);
        if (!tw || !tw.defaultAddress) return '';
        var b58 = tw.defaultAddress.base58;
        if (b58 && typeof b58 === 'string' && b58.length === 34 && b58[0] === 'T') return b58;
        var hex = tw.defaultAddress.hex;
        if (hex && typeof hex === 'string' && hex.length === 42 && hex.indexOf('41') === 0) return hex;
        return '';
      } catch(e) { return ''; }
    })()'''.toJS,
  );
  final addr = result?.dartify();
  return (addr is String) ? addr : '';
}

/// Lấy địa chỉ TronLink đang kết nối, trả null nếu không có.
Future<String?> tronLinkGetAddressOnWeb() async {
  final hasTronEnv = globalContext.callMethod<JSAny?>(
    'eval'.toJS,
    '!!(window.tronLink || window.tronWeb)'.toJS,
  );
  if (hasTronEnv?.dartify() != true) return null;

  // Yêu cầu kết nối để TronLink unlock account
  final tronLinkRaw = globalContext['tronLink'];
  if (tronLinkRaw is JSObject) {
    try {
      await _tryRequestAccounts(tronLinkRaw);
      await Future<void>.delayed(const Duration(milliseconds: 500));
    } catch (_) {}
  }

  final addr = _getAddressViaEval();
  return addr.isNotEmpty ? addr : null;
}

Future<void> _tryRequestAccounts(JSObject tronLink) async {
  try {
    final req = <Object, Object>{'method': 'tron_requestAccounts'};
    final promise = tronLink.callMethod<JSPromise<JSAny?>>(
      'request'.toJS,
      req.jsify()!,
    );
    await promise.toDart;
  } catch (_) {
    // Some TronLink versions do not expose request() or may already be connected.
  }
}


Future<String> _requestSignature({
  required JSObject? tronLink,
  required JSObject? tronWeb,
  required String message,
}) async {
  if (tronLink != null) {
    final byRequest = await _trySignThroughRequest(tronLink, message);
    if (byRequest.isNotEmpty) return byRequest;
  }

  if (tronWeb != null) {
    final byTronWeb = await _trySignThroughTronWeb(tronWeb, message);
    if (byTronWeb.isNotEmpty) return byTronWeb;
  }

  return '';
}

Future<String> _trySignThroughRequest(JSObject tronLink, String message) async {
  final candidates = <Map<String, Object>>[
    {
      'method': 'tron_signMessageV2',
      'params': <String>[message]
    },
    {
      'method': 'tron_signMessage',
      'params': <String>[message]
    },
    {
      'method': 'tron_signMessageV2',
      'params': <String, String>{'message': message},
    },
    {
      'method': 'tron_signMessage',
      'params': <String, String>{'message': message},
    },
  ];

  for (final payload in candidates) {
    try {
      final promise = tronLink.callMethod<JSPromise<JSAny?>>(
        'request'.toJS,
        payload.jsify()!,
      );
      final result = await promise.toDart;
      final signature = _extractSignature(result?.dartify());
      if (signature.isNotEmpty) return signature;
    } catch (_) {
      // Try the next known payload shape.
    }
  }

  return '';
}

Future<String> _trySignThroughTronWeb(JSObject tronWeb, String message) async {
  final trxRaw = tronWeb['trx'];
  if (trxRaw is! JSObject) return '';

  final attempts = <String>['signMessageV2', 'sign'];

  for (final methodName in attempts) {
    try {
      final promise = trxRaw.callMethod<JSPromise<JSAny?>>(
        methodName.toJS,
        message.toJS,
      );
      final result = await promise.toDart;
      final signature = _extractSignature(result?.dartify());
      if (signature.isNotEmpty) return signature;
    } catch (_) {
      // Try the next method fallback.
    }
  }

  return '';
}

String _extractSignature(Object? raw) {
  if (raw == null) return '';

  if (raw is String) {
    return raw;
  }

  if (raw is List && raw.isNotEmpty) {
    final first = raw.first;
    if (first is String) return first;
    return first?.toString() ?? '';
  }

  if (raw is Map) {
    final direct = raw['signature']?.toString() ?? '';
    if (direct.isNotEmpty) return direct;

    final result = raw['result']?.toString() ?? '';
    if (result.isNotEmpty) return result;

    final data = raw['data']?.toString() ?? '';
    if (data.isNotEmpty) return data;
  }

  return raw.toString();
}
