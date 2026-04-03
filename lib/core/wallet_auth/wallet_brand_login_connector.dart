import 'package:flutter/material.dart';

import 'package:crypto_trading_app/core/wallet_auth/wallet_brand.dart';
import 'package:crypto_trading_app/data/datasources/auth_remote_datasource.dart';

/// Strategy đăng nhập TronLink theo nền tảng (web extension / desktop hint / mobile deep link).
///
/// Triển khai: [WebInjectedWalletLoginConnector], [DesktopNativeWalletLoginConnector],
/// [MobileDeepLinkWalletLoginConnector]. Factory: [WalletBrandLoginConnectorResolver].
abstract class WalletBrandLoginConnector {
  /// Kết nối ví [brand] (hiện chỉ [WalletBrand.tronlink]), nonce + ký + verify qua [datasource].
  Future<void> connect(
    BuildContext context, {
    required WalletBrand brand,
    required AuthRemoteDataSource datasource,
    required VoidCallback onSuccess,
  });
}
