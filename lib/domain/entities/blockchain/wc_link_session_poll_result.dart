import 'package:crypto_trading_app/domain/entities/blockchain/wc_session_status.dart';

/// Kết quả poll GET /blockchain/wallets/wc/status — dùng để auto-submit sau khi BE ký xong.
class WcLinkSessionPollResult {
  const WcLinkSessionPollResult({
    required this.status,
    this.address,
    this.signature,
  });

  final WcSessionStatus status;
  final String? address;
  final String? signature;
}
