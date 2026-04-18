import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/core/wallet_auth/wallet_brand.dart';
import 'package:crypto_trading_app/core/wallet_auth/wallet_brand_login_connector.dart';
import 'package:crypto_trading_app/core/utils/wallet_web_extension_auth.dart';

/// Android / iOS: mở app TronLink bằng deep link.
class MobileDeepLinkWalletLoginConnector implements WalletBrandLoginConnector {
  MobileDeepLinkWalletLoginConnector._();
  static final MobileDeepLinkWalletLoginConnector instance =
      MobileDeepLinkWalletLoginConnector._();

  @override
  Future<void> connect(
    BuildContext context, {
    required WalletBrand brand,
    required WalletNonceFetcher fetchNonce,
    required VoidCallback onSuccess,
  }) async {
    if (!context.mounted) return;
    const deepLink = 'tronlinkoutside://';
    final opened = await launchUrl(
      Uri.parse(deepLink),
      mode: LaunchMode.externalApplication,
    );
    if (!context.mounted) return;
    if (opened) {
      showAppSnackBar(
        context,
        message: 'Mở TronLink trên điện thoại, sau đó quay lại ứng dụng.',
        type: SnackBarType.info,
      );
    } else {
      showAppSnackBar(
        context,
        message:
            'Không mở được TronLink. Cài app hoặc dùng Chrome (extension).',
        type: SnackBarType.error,
      );
    }
  }
}
