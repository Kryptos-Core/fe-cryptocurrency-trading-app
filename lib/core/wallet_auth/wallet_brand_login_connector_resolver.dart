import 'package:flutter/foundation.dart';

import 'package:crypto_trading_app/core/wallet_auth/desktop_native_wallet_login_connector.dart';
import 'package:crypto_trading_app/core/wallet_auth/mobile_deep_link_wallet_login_connector.dart';
import 'package:crypto_trading_app/core/wallet_auth/wallet_brand_login_connector.dart';
import 'package:crypto_trading_app/core/wallet_auth/wallet_platform.dart';
import 'package:crypto_trading_app/core/wallet_auth/web_injected_wallet_login_connector.dart';

/// Chọn [WalletBrandLoginConnector] theo `kIsWeb` / desktop native / mobile.
class WalletBrandLoginConnectorResolver {
  WalletBrandLoginConnectorResolver._();

  static WalletBrandLoginConnector get current {
    if (kIsWeb) return WebInjectedWalletLoginConnector.instance;
    if (isWalletDesktopNative()) {
      return DesktopNativeWalletLoginConnector.instance;
    }
    return MobileDeepLinkWalletLoginConnector.instance;
  }
}
