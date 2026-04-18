/// Response from POST /auth/wallet-nonce
class WalletNonceResponse {
  final String message;
  final int expiresIn;

  const WalletNonceResponse({required this.message, required this.expiresIn});

  factory WalletNonceResponse.fromJson(Map<String, dynamic> json) {
    return WalletNonceResponse(
      message: json['message'] as String,
      expiresIn: json['expiresIn'] as int,
    );
  }
}
