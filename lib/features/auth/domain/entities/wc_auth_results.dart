import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/wc_session_status.dart';

/// POST /auth/wallet/wc/init
class WcAuthInitResult {
  final String sessionId;
  final String wcUri;
  final String message;
  final int expiresIn;
  final String caip2Chain;

  /// BE dùng SignClient + relay thật (Sepolia + có project id trên server).
  final bool relayPairing;

  const WcAuthInitResult({
    required this.sessionId,
    required this.wcUri,
    required this.message,
    required this.expiresIn,
    required this.caip2Chain,
    this.relayPairing = false,
  });

  factory WcAuthInitResult.fromJson(Map<String, dynamic> json) {
    return WcAuthInitResult(
      sessionId: json['sessionId'] as String,
      wcUri: json['wcUri'] as String,
      message: json['message'] as String,
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 300,
      caip2Chain: json['caip2Chain'] as String? ?? '',
      relayPairing: json['relayPairing'] == true,
    );
  }
}

/// GET /auth/wallet/wc/status/:sessionId
class WcAuthStatusResult {
  final String sessionId;
  final WcSessionStatus status;
  final String? address;
  final String? signature;
  final int? expiresAtMs;
  final String? message;
  final String? wcUri;

  const WcAuthStatusResult({
    required this.sessionId,
    required this.status,
    this.address,
    this.signature,
    this.expiresAtMs,
    this.message,
    this.wcUri,
  });

  factory WcAuthStatusResult.fromJson(Map<String, dynamic> json) {
    final raw = json['status'] as String? ?? 'pending';
    final exp = json['expiresAt'];
    int? expiresAtMs;
    if (exp is int) {
      expiresAtMs = exp;
    } else if (exp is num) {
      expiresAtMs = exp.toInt();
    }
    return WcAuthStatusResult(
      sessionId: json['sessionId'] as String,
      status: WcSessionStatusX.fromApiValue(raw),
      address: json['address'] as String?,
      signature: json['signature'] as String?,
      expiresAtMs: expiresAtMs,
      message: json['message'] as String?,
      wcUri: json['wcUri'] as String?,
    );
  }
}
