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
  final tronLinkRaw = globalContext['tronLink'];
  final tronWebRaw = globalContext['tronWeb'];

  if (tronLinkRaw == null && tronWebRaw == null) {
    return const TronLinkWebSignResult(
      signature: null,
      notInstalled: true,
      accountMismatch: false,
      connectedAddress: null,
      message:
          'TronLink provider is not detected. If extension is already installed, ensure it is enabled for this browser profile, unlocked, and has access to this site, then refresh and try again.',
    );
  }

  final tronLink = tronLinkRaw is JSObject ? tronLinkRaw : null;
  final tronWeb = tronWebRaw is JSObject ? tronWebRaw : null;

  try {
    if (tronLink != null) {
      await _tryRequestAccounts(tronLink);
    }

    final connectedAddress = _resolveConnectedAddress(tronWeb, tronLink);

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
            'Address mismatch: entered $expectedAddress but TronLink connected $connectedAddress. Use the same address, then try again.',
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

/// Lấy địa chỉ TronLink đang kết nối, trả null nếu không có.
Future<String?> tronLinkGetAddressOnWeb() async {
  final tronLinkRaw = globalContext['tronLink'];
  final tronWebRaw = globalContext['tronWeb'];
  if (tronLinkRaw == null && tronWebRaw == null) return null;

  final tronLink = tronLinkRaw is JSObject ? tronLinkRaw : null;
  final tronWeb = tronWebRaw is JSObject ? tronWebRaw : null;

  if (tronLink != null) {
    try {
      await _tryRequestAccounts(tronLink);
      // Đợi TronLink cập nhật defaultAddress sau khi user approve
      await Future<void>.delayed(const Duration(milliseconds: 300));
    } catch (_) {}
  }

  final address = _resolveConnectedAddress(tronWeb, tronLink);
  return address.isNotEmpty ? address : null;
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

/// Kiểm tra chuỗi địa chỉ có phải giá trị hợp lệ (không phải "false"/"null"/"undefined").
bool _isValidAddressString(String? s) =>
    s != null &&
    s.isNotEmpty &&
    s != 'false' &&
    s != 'null' &&
    s != 'undefined';

String _resolveConnectedAddress(JSObject? tronWeb, JSObject? tronLink) {
  String fromTronWeb(JSObject? source) {
    if (source == null) return '';

    final defaultAddressRaw = source['defaultAddress'];
    if (defaultAddressRaw is JSObject) {
      final base58 = defaultAddressRaw['base58']?.dartify()?.toString();
      if (_isValidAddressString(base58)) return base58!;

      final hex = defaultAddressRaw['hex']?.dartify()?.toString();
      if (_isValidAddressString(hex)) return hex!;
    }

    final address = source['address']?.dartify()?.toString();
    return _isValidAddressString(address) ? address! : '';
  }

  final direct = fromTronWeb(tronWeb);
  if (direct.isNotEmpty) return direct;

  if (tronLink != null) {
    final embeddedTronWeb = tronLink['tronWeb'];
    if (embeddedTronWeb is JSObject) {
      final embedded = fromTronWeb(embeddedTronWeb);
      if (embedded.isNotEmpty) return embedded;
    }
  }

  return '';
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
