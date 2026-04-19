import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:crypto_trading_app/app/di/injection_container.dart';
import 'package:crypto_trading_app/core/wallet_auth/wallet_brand.dart';
import 'package:crypto_trading_app/core/wallet_auth/wallet_brand_login_connector_resolver.dart';
import 'package:crypto_trading_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:crypto_trading_app/features/auth/presentation/widgets/wallet_connect_auth_login_dialog.dart';

class AuthWalletFlowService {
  const AuthWalletFlowService();

  Future<void> openWalletConnectQrLogin(
    BuildContext context, {
    required VoidCallback onSuccess,
  }) async {
    if (!context.mounted) return;
    final ok = await showWalletConnectAuthLoginDialog(context: context);
    if (ok == true && context.mounted) onSuccess();
  }

  /// Web: TronLink extension. Native (Windows/macOS/Linux/mobile): cùng luồng QR
  /// WalletConnect relay `/auth/wallet/wc/*` như nút “Legacy QR” / liên kết ví Tron (TronLink mobile quét).
  Future<void> connectTronLink(
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
