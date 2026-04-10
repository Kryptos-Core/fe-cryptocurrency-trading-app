import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';

typedef OpenExternalUrlFn = Future<bool> Function(String url);

class WalletExtensionTarget {
  final String name;
  final String installUrl;
  final List<String> extensionPageUrls;

  const WalletExtensionTarget({
    required this.name,
    required this.installUrl,
    this.extensionPageUrls = const <String>[],
  });
}

class WalletExtensionPrecheckService {
  final OpenExternalUrlFn _openExternalUrl;

  WalletExtensionPrecheckService({
    OpenExternalUrlFn? openExternalUrl,
  }) : _openExternalUrl = openExternalUrl ?? _defaultOpenExternalUrl;

  static Future<bool> _defaultOpenExternalUrl(String url) {
    return launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  bool isWindowsNativeDesktop({
    bool isWeb = kIsWeb,
    TargetPlatform? platform,
  }) {
    if (isWeb) return false;
    return (platform ?? defaultTargetPlatform) == TargetPlatform.windows;
  }

  bool requiresPrecheck({
    required BlockchainNetwork network,
    required bool isWebDialog,
    required bool isTestMode,
    bool isWeb = kIsWeb,
    TargetPlatform? platform,
  }) {
    if (isWebDialog || isTestMode) {
      return false;
    }

    if (!isWindowsNativeDesktop(isWeb: isWeb, platform: platform)) {
      return false;
    }

    return targetForNetwork(network) != null;
  }

  WalletExtensionTarget? targetForNetwork(BlockchainNetwork network) {
    switch (network) {
      case BlockchainNetwork.ethMainnet:
      case BlockchainNetwork.bscMainnet:
      case BlockchainNetwork.bscChapel:
        return const WalletExtensionTarget(
          name: 'MetaMask',
          installUrl: 'https://metamask.io/download/',
          extensionPageUrls: <String>[
            'https://chromewebstore.google.com/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn',
          ],
        );
      case BlockchainNetwork.tronMainnet:
      case BlockchainNetwork.tronNile:
      case BlockchainNetwork.tronShasta:
        return const WalletExtensionTarget(
          name: 'TronLink',
          installUrl:
              'https://chromewebstore.google.com/detail/tronlink/ibnejdfjmmkpcnlpebklmnkoeoihofec',
          extensionPageUrls: <String>[
            'https://chromewebstore.google.com/detail/tronlink/ibnejdfjmmkpcnlpebklmnkoeoihofec',
          ],
        );
      case BlockchainNetwork.solanaMainnet:
      case BlockchainNetwork.solanaDevnet:
        return const WalletExtensionTarget(
          name: 'Phantom',
          installUrl: 'https://phantom.app/download',
          extensionPageUrls: <String>[
            'https://chromewebstore.google.com/detail/phantom/bfnaelmomeimhlpmgjnjophhpkkoljpa',
          ],
        );
    }
  }

  Future<bool> openExtensionInstallPage(BlockchainNetwork network) async {
    final target = targetForNetwork(network);
    if (target == null) return false;
    return _openExternalUrl(target.installUrl);
  }

  Future<bool> openExtensionPage(BlockchainNetwork network) async {
    final target = targetForNetwork(network);
    if (target == null || target.extensionPageUrls.isEmpty) {
      return false;
    }

    for (final url in target.extensionPageUrls) {
      if (url.isEmpty) continue;
      final opened = await _openExternalUrl(url);
      if (opened) return true;
    }

    return false;
  }
}
