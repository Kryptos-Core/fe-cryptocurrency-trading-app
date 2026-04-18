import 'package:flutter/material.dart';

import 'package:crypto_trading_app/core/utils/wallet_web_extension_auth.dart';
import 'package:crypto_trading_app/core/wallet_auth/wallet_brand.dart';

/// Strategy đăng nhập TronLink theo nền tảng (web extension / desktop hint / mobile deep link).
///
/// Triển khai: [WebInjectedWalletLoginConnector], [DesktopNativeWalletLoginConnector],
/// [MobileDeepLinkWalletLoginConnector]. Factory: [WalletBrandLoginConnectorResolver].
abstract class WalletBrandLoginConnector {
  /// Kết nối ví [brand] (hiện chỉ [WalletBrand.tronlink]), nonce + ký + verify qua [fetchNonce].
  Future<void> connect(
    BuildContext context, {
    required WalletBrand brand,
    required WalletNonceFetcher fetchNonce,
    required VoidCallback onSuccess,
  });
}
