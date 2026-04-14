import 'package:flutter/widgets.dart';
import 'package:crypto_trading_app/core/wallet_auth/wallet_brand.dart';
import 'package:crypto_trading_app/core/wallet_auth/wallet_brand_login_connector_resolver.dart';
import 'package:crypto_trading_app/data/datasources/auth_remote_datasource.dart';
import 'package:crypto_trading_app/features/auth/presentation/widgets/wallet_connect_auth_login_dialog.dart';

class AuthWalletFlowService {
  final AuthRemoteDataSource _datasource;

  const AuthWalletFlowService({required AuthRemoteDataSource datasource})
      : _datasource = datasource;

  Future<void> openWalletConnectQrLogin(
    BuildContext context, {
    required VoidCallback onSuccess,
  }) async {
    if (!context.mounted) return;
    final ok = await showWalletConnectAuthLoginDialog(context: context);
    if (ok == true && context.mounted) onSuccess();
  }

  Future<void> connectTronLink(
    BuildContext context, {
    required VoidCallback onSuccess,
  }) {
    return WalletBrandLoginConnectorResolver.current.connect(
      context,
      brand: WalletBrand.tronlink,
      datasource: _datasource,
      onSuccess: onSuccess,
    );
  }
}
