import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/data/datasources/auth_remote_datasource.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/metamask_web_bridge_stub.dart'
    if (dart.library.html) 'package:crypto_trading_app/core/services/wallet_signing/metamask_web_bridge_web.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/tronlink_web_bridge_stub.dart'
    if (dart.library.html) 'package:crypto_trading_app/core/services/wallet_signing/tronlink_web_bridge_web.dart';

enum _WebWalletKind { metamask, tronlink }

/// Đăng nhập trên Flutter Web qua MetaMask / TronLink extension (nonce + ký + wallet-verify).
Future<bool> loginWithWebBrowserExtension(
  BuildContext context, {
  required bool metaMask,
  required AuthRemoteDataSource datasource,
  required VoidCallback onSuccess,
}) async {
  if (!kIsWeb || !context.mounted) return false;

  final kind = metaMask ? _WebWalletKind.metamask : _WebWalletKind.tronlink;
  final sandbox =
      parseOnChainOperatorMode(dotenv.env) == OnChainOperatorMode.sandbox;
  final chain = metaMask
      ? (sandbox ? BlockchainNetwork.bscChapel : BlockchainNetwork.ethMainnet)
      : (sandbox ? BlockchainNetwork.tronNile : BlockchainNetwork.tronMainnet);

  final address = metaMask
      ? await metaMaskGetAddressOnWeb()
      : await tronLinkGetAddressOnWeb();

  if (!context.mounted) return false;

  if (address == null || address.isEmpty) {
    if (context.mounted) {
      final name = metaMask ? 'MetaMask' : 'TronLink';
      showAppSnackBar(
        context,
        message:
            '$name không phát hiện được. Cài extension Chrome và mở app trên trình duyệt.',
        type: SnackBarType.error,
      );
    }
    return false;
  }

  return _completeWalletAuthAfterAddress(
    context,
    kind: kind,
    address: address,
    chain: chain,
    datasource: datasource,
    onSuccess: onSuccess,
  );
}

Future<bool> _completeWalletAuthAfterAddress(
  BuildContext context, {
  required _WebWalletKind kind,
  required String address,
  required BlockchainNetwork chain,
  required AuthRemoteDataSource datasource,
  required VoidCallback onSuccess,
}) async {
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
    return false;
  }

  String? signature;
  if (kind == _WebWalletKind.metamask) {
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
      return false;
    }
    signature = result.signature;
    if (signature == null && context.mounted) {
      showAppSnackBar(
        context,
        message: result.message,
        type: SnackBarType.error,
      );
      return false;
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
      return false;
    }
    signature = result.signature;
    if (signature == null && context.mounted) {
      showAppSnackBar(
        context,
        message: result.message,
        type: SnackBarType.error,
      );
      return false;
    }
  }

  if (!context.mounted) return false;

  final authProvider = context.read<AuthProvider>();
  final authResult = await authProvider.loginWithWallet(
    chain: chain.apiValue,
    address: address,
    signature: signature!,
  );

  if (!context.mounted) return false;
  var ok = false;
  authResult.fold(
    (failure) {
      showAppSnackBar(
        context,
        message: 'Xác thực thất bại: ${failure.message}',
        type: SnackBarType.error,
      );
    },
    (_) {
      ok = true;
      onSuccess();
    },
  );
  return ok;
}
