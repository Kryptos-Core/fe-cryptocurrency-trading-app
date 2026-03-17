import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/data/datasources/auth_remote_datasource.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/metamask_web_bridge_stub.dart'
    if (dart.library.html) 'package:crypto_trading_app/core/services/wallet_signing/metamask_web_bridge_web.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/tronlink_web_bridge_stub.dart'
    if (dart.library.html) 'package:crypto_trading_app/core/services/wallet_signing/tronlink_web_bridge_web.dart';

enum _WalletType { metamask, tronlink }

/// Flow đăng nhập/đăng ký bằng ví dùng chung cho LoginScreen và RegisterScreen.
/// Tái sử dụng bridge web hiện có: metaMaskGetAddressOnWeb, metaMaskSignOnWeb, tronLinkGetAddressOnWeb, tronLinkSignOnWeb.
class WalletAuthHandler {
  const WalletAuthHandler._();

  /// Kết nối MetaMask và đăng nhập/đăng ký.
  static Future<void> connectMetaMask(
    BuildContext context, {
    required AuthRemoteDataSource datasource,
    required VoidCallback onSuccess,
  }) =>
      _handleWalletAuth(
        context,
        walletType: _WalletType.metamask,
        datasource: datasource,
        onSuccess: onSuccess,
      );

  /// Kết nối TronLink và đăng nhập/đăng ký.
  static Future<void> connectTronLink(
    BuildContext context, {
    required AuthRemoteDataSource datasource,
    required VoidCallback onSuccess,
  }) =>
      _handleWalletAuth(
        context,
        walletType: _WalletType.tronlink,
        datasource: datasource,
        onSuccess: onSuccess,
      );

  static Future<void> _handleWalletAuth(
    BuildContext context, {
    required _WalletType walletType,
    required AuthRemoteDataSource datasource,
    required VoidCallback onSuccess,
  }) async {
    if (!context.mounted) return;

    // Bước 1: Lấy địa chỉ từ ví
    String? address;
    final chain = walletType == _WalletType.metamask
        ? BlockchainNetwork.ethSepolia
        : BlockchainNetwork.tronNile;

    if (kIsWeb) {
      if (walletType == _WalletType.metamask) {
        address = await metaMaskGetAddressOnWeb();
      } else {
        address = await tronLinkGetAddressOnWeb();
      }
    } else {
      // Mobile/Desktop: deep-link rồi yêu cầu nhập thủ công (không hỗ trợ auto)
      final deepLink = walletType == _WalletType.metamask
          ? 'metamask://'
          : 'tronlinkoutside://';
      await launchUrl(
        Uri.parse(deepLink),
        mode: LaunchMode.externalApplication,
      );
      if (context.mounted) {
        showAppSnackBar(
          context,
          message: walletType == _WalletType.metamask
              ? 'Mở MetaMask để xác nhận, sau đó quay lại ứng dụng.'
              : 'Mở TronLink để xác nhận, sau đó quay lại ứng dụng.',
          type: SnackBarType.info,
        );
      }
      return;
    }

    if (address == null || address.isEmpty) {
      if (context.mounted) {
        final walletName =
            walletType == _WalletType.metamask ? 'MetaMask' : 'TronLink';
        showAppSnackBar(
          context,
          message:
              '$walletName không phát hiện được. Hãy cài đặt extension và kết nối với trang này.',
          type: SnackBarType.error,
        );
      }
      return;
    }

    // Bước 2: Lấy nonce từ BE
    WalletNonceResponse nonceResponse;
    try {
      nonceResponse = await datasource.walletNonce(
        chain: chain.apiValue,
        address: address,
      );
    } catch (e) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          message: 'Không thể lấy nonce: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
      return;
    }

    // Bước 3: Ký message bằng ví
    String? signature;
    if (walletType == _WalletType.metamask) {
      final result = await metaMaskSignOnWeb(
        message: nonceResponse.message,
        expectedAddress: address,
      );
      if (result.accountMismatch && context.mounted) {
        showAppSnackBar(
          context,
          message:
              'Sai địa chỉ MetaMask. Đang kết nối: ${result.connectedAddress}',
          type: SnackBarType.warning,
        );
        return;
      }
      signature = result.signature;
      if (signature == null && context.mounted) {
        showAppSnackBar(
          context,
          message: result.message,
          type: SnackBarType.error,
        );
        return;
      }
    } else {
      final result = await tronLinkSignOnWeb(
        message: nonceResponse.message,
        expectedAddress: address,
      );
      if (result.accountMismatch && context.mounted) {
        showAppSnackBar(
          context,
          message:
              'Sai địa chỉ TronLink. Đang kết nối: ${result.connectedAddress}',
          type: SnackBarType.warning,
        );
        return;
      }
      signature = result.signature;
      if (signature == null && context.mounted) {
        showAppSnackBar(
          context,
          message: result.message,
          type: SnackBarType.error,
        );
        return;
      }
    }

    if (!context.mounted) return;

    // Bước 4: Xác thực với BE
    final authProvider = context.read<AuthProvider>();
    final authResult = await authProvider.loginWithWallet(
      chain: chain.apiValue,
      address: address,
      signature: signature!,
    );

    if (!context.mounted) return;
    authResult.fold(
      (failure) {
        showAppSnackBar(
          context,
          message: 'Xác thực thất bại: ${failure.message}',
          type: SnackBarType.error,
        );
      },
      (_) => onSuccess(),
    );
  }
}
