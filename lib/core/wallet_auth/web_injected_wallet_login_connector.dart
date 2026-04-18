import 'package:flutter/material.dart';

import 'package:crypto_trading_app/core/utils/wallet_web_extension_auth.dart';
import 'package:crypto_trading_app/core/wallet_auth/wallet_brand.dart';
import 'package:crypto_trading_app/core/wallet_auth/wallet_brand_login_connector.dart';

/// Flutter Web: TronLink extension (đăng nhập qua nonce + verify).
class WebInjectedWalletLoginConnector implements WalletBrandLoginConnector {
  WebInjectedWalletLoginConnector._();
  static final WebInjectedWalletLoginConnector instance =
      WebInjectedWalletLoginConnector._();

  @override
  Future<void> connect(
    BuildContext context, {
    required WalletBrand brand,
    required WalletNonceFetcher fetchNonce,
    required VoidCallback onSuccess,
  }) async {
    if (!context.mounted) return;
    await loginWithWebBrowserExtension(
      context,
      metaMask: false,
      fetchNonce: fetchNonce,
      onSuccess: onSuccess,
    );
  }
}
