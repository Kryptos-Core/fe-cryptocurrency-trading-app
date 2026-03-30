/// Trạng thái của WalletConnect session
enum WcSessionStatus {
  /// Đang idle, chưa có session
  idle,

  /// Session URI đã tạo, đang chờ user scan QR / bấm deep link
  pending,

  /// Wallet đã kết nối, đang chờ user ký message trên wallet
  connected,

  /// User đã ký xong — FE cần gọi submit signature để hoàn tất liên kết
  signed,

  /// Session hết TTL (5 phút) — cần tạo session mới
  expired,

  /// Có lỗi xảy ra trong quá trình
  failed,
}

extension WcSessionStatusX on WcSessionStatus {
  static WcSessionStatus fromApiValue(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return WcSessionStatus.pending;
      case 'connected':
        return WcSessionStatus.connected;
      case 'signed':
        return WcSessionStatus.signed;
      case 'expired':
        return WcSessionStatus.expired;
      case 'failed':
        return WcSessionStatus.failed;
      default:
        return WcSessionStatus.pending;
    }
  }

  bool get isTerminal =>
      this == WcSessionStatus.signed ||
      this == WcSessionStatus.expired ||
      this == WcSessionStatus.failed;

  bool get needsAction => this == WcSessionStatus.signed;

  String get displayLabel {
    switch (this) {
      case WcSessionStatus.idle:
        return 'Chờ khởi tạo';
      case WcSessionStatus.pending:
        return 'Chờ scan QR';
      case WcSessionStatus.connected:
        return 'Ví đã kết nối, đang chờ ký...';
      case WcSessionStatus.signed:
        return 'Đã ký thành công!';
      case WcSessionStatus.expired:
        return 'Session hết hạn';
      case WcSessionStatus.failed:
        return 'Có lỗi xảy ra';
    }
  }
}
