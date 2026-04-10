import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';

/// Model chứa thông tin WalletConnect session proposal
/// Được trả về từ BE khi FE gọi POST /blockchain/wallets/wc/init
class WcSessionProposal {
  /// Session ID dùng để poll status và submit signature
  final String sessionId;

  /// WalletConnect URI — nội dung QR Code hoặc deep link
  /// Format: wc:{topic}@2?relay-protocol=irn&symKey={key}&projectId={id}
  final String wcUri;

  /// Thời điểm hết hạn của session (UTC)
  final DateTime expiresAt;

  /// Chain mà session này được tạo cho
  final BlockchainNetwork chain;

  /// CAIP-2 chain identifier (e.g. "eip155:97" cho BSC Chapel)
  final String caip2Chain;

  const WcSessionProposal({
    required this.sessionId,
    required this.wcUri,
    required this.expiresAt,
    required this.chain,
    required this.caip2Chain,
  });

  /// Deep link URI để mở wallet app trực tiếp (mobile)
  /// Trust Wallet, MetaMask Mobile đều support protocol này
  String get deepLinkUri => 'wc://?uri=${Uri.encodeComponent(wcUri)}';

  /// Universal link dự phòng cho Trust Wallet
  String get trustWalletDeepLink =>
      'trust://wc?uri=${Uri.encodeComponent(wcUri)}';

  /// Universal link dự phòng cho MetaMask Mobile
  String get metamaskDeepLink =>
      'metamask://wc?uri=${Uri.encodeComponent(wcUri)}';

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get remainingTime {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  factory WcSessionProposal.fromJson(Map<String, dynamic> json) {
    final expiresIn = json['expiresIn'] as int? ?? 300;
    return WcSessionProposal(
      sessionId: json['sessionId'] as String,
      wcUri: json['wcUri'] as String,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
      chain: BlockchainNetworkX.fromApiValue(json['chain'] as String? ?? 'BSC_CHAPEL'),
      caip2Chain: json['caip2Chain'] as String? ?? '',
    );
  }
}
