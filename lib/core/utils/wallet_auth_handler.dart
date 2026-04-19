import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:crypto_trading_app/app/di/injection_container.dart';
import 'package:crypto_trading_app/core/wallet_auth/wallet_brand.dart';
import 'package:crypto_trading_app/core/wallet_auth/wallet_brand_login_connector_resolver.dart';
import 'package:crypto_trading_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:crypto_trading_app/features/auth/presentation/widgets/wallet_connect_auth_login_dialog.dart';

/// Flow đăng nhập/đăng ký bằng ví dùng chung cho LoginScreen và RegisterScreen.
///
/// EVM: [openWalletConnectQrLogin] (Reown trên mobile, QR server trên desktop/web).
/// Tron: [connectTronLink] — web = extension; native = QR WC `/auth/wallet/wc/*` (giống liên kết ví Tron).
class WalletAuthHandler {
  const WalletAuthHandler._();

  /// Đăng nhập / đăng ký qua WalletConnect (endpoint public), mọi nền tảng.
  static Future<void> openWalletConnectQrLogin(
    BuildContext context, {
    required VoidCallback onSuccess,
  }) async {
    if (!context.mounted) return;
    final ok = await showWalletConnectAuthLoginDialog(context: context);
    if (ok == true && context.mounted) onSuccess();
  }

  /// Kết nối TronLink và đăng nhập/đăng ký.
  static Future<void> connectTronLink(
    BuildContext context, {
    required VoidCallback onSuccess,
  }) async {
    if (kIsWeb) {
      await WalletBrandLoginConnectorResolver.current.connect(
        context,
        brand: WalletBrand.tronlink,
        fetchNonce: ({required chain, required address}) async {
          final r = await sl<AuthRepository>().walletNonce(
            chain: chain,
            address: address,
          );
          return r.fold((f) => throw Exception(f.message), (v) => v);
        },
        onSuccess: onSuccess,
      );
      return;
    }
    if (!context.mounted) return;
    final ok = await showWalletConnectAuthLoginDialog(
      context: context,
      tronMobileQrEntry: true,
    );
    if (ok == true && context.mounted) onSuccess();
  }
}

