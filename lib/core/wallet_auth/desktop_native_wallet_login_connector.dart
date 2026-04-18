import 'package:flutter/material.dart';

import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/wallet_auth/wallet_brand.dart';
import 'package:crypto_trading_app/core/wallet_auth/wallet_brand_login_connector.dart';
import 'package:crypto_trading_app/core/utils/wallet_web_extension_auth.dart';

/// Windows / macOS / Linux: TronLink → hướng dẫn mở bản web (extension chỉ trên Chrome).
class DesktopNativeWalletLoginConnector implements WalletBrandLoginConnector {
  DesktopNativeWalletLoginConnector._();
  static final DesktopNativeWalletLoginConnector instance =
      DesktopNativeWalletLoginConnector._();

  @override
  Future<void> connect(
    BuildContext context, {
    required WalletBrand brand,
    required WalletNonceFetcher fetchNonce,
    required VoidCallback onSuccess,
  }) async {
    if (!context.mounted) return;
    await _showDesktopTronLinkHint(context);
  }
}

Future<void> _showDesktopTronLinkHint(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.desktopTronlinkDialogTitle),
      content: Text(l10n.desktopTronlinkDialogBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.desktopTronlinkDialogOk),
        ),
      ],
    ),
  );
}
