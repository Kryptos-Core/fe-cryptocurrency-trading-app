import 'package:flutter/material.dart';

import 'package:crypto_trading_app/core/utils/wallet_web_extension_auth.dart';
import 'package:crypto_trading_app/core/wallet_auth/wallet_brand.dart';

/// Strategy đăng nhập TronLink — **web** qua extension ([WebInjectedWalletLoginConnector]).
/// Native (desktop/mobile): luồng QR WC `/auth/wallet/wc/*` qua
/// [showWalletConnectAuthLoginDialog] (`tronMobileQrEntry`), không qua các connector desktop/deep-link.
///
/// Triển khai còn lại: [DesktopNativeWalletLoginConnector], [MobileDeepLinkWalletLoginConnector]
/// (legacy / không dùng từ [AuthWalletFlowService.connectTronLink]). Factory: [WalletBrandLoginConnectorResolver].
abstract class WalletBrandLoginConnector {
  /// Kết nối ví [brand] (hiện chỉ [WalletBrand.tronlink]), nonce + ký + verify qua [fetchNonce].
  Future<void> connect(
    BuildContext context, {
    required WalletBrand brand,
    required WalletNonceFetcher fetchNonce,
    required VoidCallback onSuccess,
  });
}
