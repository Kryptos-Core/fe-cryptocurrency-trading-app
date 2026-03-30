import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/core/utils/wallet_web_extension_auth.dart';
import 'package:crypto_trading_app/data/datasources/auth_remote_datasource.dart';
import 'package:crypto_trading_app/presentation/widgets/wallet_connect_auth_login_dialog.dart';

enum _WalletType { metamask, tronlink }

/// Windows / macOS / Linux native: không gọi `metamask://` — OS mở Microsoft Store
/// vì không có handler. MetaMask desktop dùng dialog WalletConnect public (`/auth/wallet/wc/*`).
bool _isDesktopNative() {
  if (kIsWeb) return false;
  switch (defaultTargetPlatform) {
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
      return true;
    default:
      return false;
  }
}

Future<void> _showDesktopWalletLoginHint(
  BuildContext context,
  _WalletType walletType,
) async {
  final isMetaMask = walletType == _WalletType.metamask;
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(isMetaMask ? 'MetaMask trên desktop' : 'TronLink trên desktop'),
      content: Text(
        isMetaMask
            ? 'Dùng nút «WalletConnect (QR)» trên desktop: app sẽ mở '
                'QR đăng nhập (Reown hoặc luồng server legacy). Hoặc chạy bản web Chrome với extension MetaMask, '
                'hoặc đăng nhập email.'
            : 'Tron không phải EVM; TronLink chỉ hoạt động qua extension trên Chrome. '
                'Trên desktop native không có TronLink như MetaMask mobile.\n\n'
                'Hãy dùng bản web trên Chrome hoặc đăng nhập bằng email.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Đã hiểu'),
        ),
      ],
    ),
  );
}

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
    required AuthRemoteDataSource datasource,
    required VoidCallback onSuccess,
  }) =>
      _handleWalletAuth(
        context,
        walletType: _WalletType.tronlink,
        datasource: datasource,
        onSuccess: onSuccess,
      );

  /// Flutter Web: MetaMask hoặc TronLink extension — `/auth/wallet-nonce` + ký + `/auth/wallet-verify`
  /// (không cần QR / dán chữ ký). Dùng làm luồng chính trên web thay cho Reown khi chưa thêm SDK.
  /// Ủy quyền sang [loginWithWebBrowserExtension] (logic tách file tránh vòng import với dialog WC).
  static Future<bool> signInWithWebExtension(
    BuildContext context, {
    required bool metaMask,
    required AuthRemoteDataSource datasource,
    required VoidCallback onSuccess,
  }) =>
      loginWithWebBrowserExtension(
        context,
        metaMask: metaMask,
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

    if (kIsWeb) {
      await loginWithWebBrowserExtension(
        context,
        metaMask: walletType == _WalletType.metamask,
        datasource: datasource,
        onSuccess: onSuccess,
      );
      return;
    }

    if (_isDesktopNative()) {
      if (walletType == _WalletType.metamask) {
        final ok = await showWalletConnectAuthLoginDialog(context: context);
        if (ok == true && context.mounted) onSuccess();
        return;
      }
      if (context.mounted) {
        await _showDesktopWalletLoginHint(context, walletType);
      }
      return;
    } else {
      // Android / iOS: thử mở app ví (có thể cài MetaMask / TronLink mobile)
      final deepLink = walletType == _WalletType.metamask
          ? 'metamask://'
          : 'tronlinkoutside://';
      final uri = Uri.parse(deepLink);
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!context.mounted) return;
      if (opened) {
        showAppSnackBar(
          context,
          message: walletType == _WalletType.metamask
              ? 'Mở MetaMask trên điện thoại, sau đó quay lại ứng dụng.'
              : 'Mở TronLink trên điện thoại, sau đó quay lại ứng dụng.',
          type: SnackBarType.info,
        );
      } else {
        showAppSnackBar(
          context,
          message: walletType == _WalletType.metamask
              ? 'Không mở được MetaMask. Cài app hoặc dùng bản web Chrome.'
              : 'Không mở được TronLink. Cài app hoặc dùng Chrome (extension).',
          type: SnackBarType.error,
        );
      }
      return;
    }
  }
}
