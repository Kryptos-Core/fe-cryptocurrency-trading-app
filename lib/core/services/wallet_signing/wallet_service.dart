import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/metamask_web_bridge_stub.dart'
    if (dart.library.html) 'package:crypto_trading_app/core/services/wallet_signing/metamask_web_bridge_web.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/tronlink_web_bridge_stub.dart'
    if (dart.library.html) 'package:crypto_trading_app/core/services/wallet_signing/tronlink_web_bridge_web.dart';

Future<bool> _openWebHelpPage(String url) {
  return launchUrl(
    Uri.parse(url),
    webOnlyWindowName: '_blank',
  );
}

bool _isMobileNativePlatform() {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

bool _isDesktopNativePlatform() {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;
}

enum WalletClient {
  metamask,
  phantom,
  tronlink,
  manual,
}

class WalletSignRequest {
  final BlockchainNetwork network;
  final String address;
  final String message;

  const WalletSignRequest({
    required this.network,
    required this.address,
    required this.message,
  });
}

class WalletSignResult {
  final String? signature;
  final bool openedExternalWallet;
  final bool requiresManualInput;
  final String? suggestedAddress;
  final String message;

  const WalletSignResult({
    required this.signature,
    required this.openedExternalWallet,
    required this.requiresManualInput,
    this.suggestedAddress,
    required this.message,
  });
}

abstract class WalletService {
  WalletClient get client;

  Future<WalletSignResult> signMessage(WalletSignRequest request);
}

class MetaMaskWalletService implements WalletService {
  @override
  WalletClient get client => WalletClient.metamask;

  @override
  Future<WalletSignResult> signMessage(WalletSignRequest request) async {
    // On web, try direct extension signing first.
    if (kIsWeb) {
      final webSignResult = await metaMaskSignOnWeb(
        message: request.message,
        expectedAddress: request.address,
      );

      if (webSignResult.signature != null &&
          webSignResult.signature!.isNotEmpty) {
        return WalletSignResult(
          signature: webSignResult.signature,
          openedExternalWallet: true,
          requiresManualInput: false,
          suggestedAddress: webSignResult.connectedAddress,
          message: 'MetaMask signature captured from extension popup.',
        );
      }

      if (webSignResult.notInstalled) {
        final host = Uri.base.host.toLowerCase();
        final isLocalhost =
            host == 'localhost' || host == '127.0.0.1' || host == '::1';

        // On localhost, extension is often installed but blocked/not injected.
        // Avoid forcing a download tab in that case.
        if (!isLocalhost) {
          await _openWebHelpPage('https://metamask.io/download/');
        }
      }

      return WalletSignResult(
        signature: null,
        openedExternalWallet: false,
        requiresManualInput: true,
        suggestedAddress: webSignResult.accountMismatch
            ? webSignResult.connectedAddress
            : null,
        message: webSignResult.message,
      );
    }

    // Mobile native: deep-link directly into wallet app.
    if (_isMobileNativePlatform()) {
      final opened = await launchUrl(
        Uri.parse('metamask://'),
        mode: LaunchMode.externalApplication,
      );

      return WalletSignResult(
        signature: null,
        openedExternalWallet: opened,
        requiresManualInput: true,
        message: opened
            ? 'Opened MetaMask app. Sign the challenge and paste the signature below.'
            : 'Could not open MetaMask app. Install/open MetaMask and try again.',
      );
    }

    // Desktop native (Windows/macOS/Linux): no in-app extension bridge.
    if (_isDesktopNativePlatform()) {
      return const WalletSignResult(
        signature: null,
        openedExternalWallet: false,
        requiresManualInput: true,
        message:
            'Desktop app mode cannot access Chrome extensions directly. For MetaMask extension signing, run app on Chrome (`flutter run -d chrome`). Otherwise use test/manual signature mode.',
      );
    }

    final opened = await launchUrl(
      Uri.parse('metamask://'),
      mode: LaunchMode.externalApplication,
    );

    return WalletSignResult(
      signature: null,
      openedExternalWallet: opened,
      requiresManualInput: true,
      message: opened
          ? 'Opened MetaMask. Sign the challenge and paste the signature below.'
          : 'Could not open MetaMask app (deep-link). Install/open MetaMask first, or enable test mode for manual signature.',
    );
  }
}

class PhantomWalletService implements WalletService {
  @override
  WalletClient get client => WalletClient.phantom;

  @override
  Future<WalletSignResult> signMessage(WalletSignRequest request) async {
    if (kIsWeb) {
      await _openWebHelpPage('https://phantom.app/download');
      return const WalletSignResult(
        signature: null,
        openedExternalWallet: false,
        requiresManualInput: true,
        message:
            'Web mode: opened Phantom install/help page in a new tab. Open Phantom extension, sign challenge manually, then paste signature below.',
      );
    }

    if (_isDesktopNativePlatform()) {
      return const WalletSignResult(
        signature: null,
        openedExternalWallet: false,
        requiresManualInput: true,
        message:
            'Desktop app mode cannot access browser extensions directly. For Phantom extension signing, run app on Chrome (`flutter run -d chrome`). Otherwise use manual signature mode.',
      );
    }

    final encodedMessage = base64Url.encode(utf8.encode(request.message));
    final deepLink = Uri.parse(
      'phantom://ul/v1/signMessage?message=$encodedMessage&display=utf8',
    );

    final opened = await launchUrl(
      deepLink,
      mode: LaunchMode.externalApplication,
    );

    return WalletSignResult(
      signature: null,
      openedExternalWallet: opened,
      requiresManualInput: true,
      message: opened
          ? 'Opened Phantom. Sign the challenge and paste the signature below.'
          : 'Could not open Phantom app (deep-link). Install/open Phantom first, or enable test mode for manual signature.',
    );
  }
}

class TronLinkWalletService implements WalletService {
  @override
  WalletClient get client => WalletClient.tronlink;

  @override
  Future<WalletSignResult> signMessage(WalletSignRequest request) async {
    if (kIsWeb) {
      final webSignResult = await tronLinkSignOnWeb(
        message: request.message,
        expectedAddress: request.address,
      );

      if (webSignResult.signature != null &&
          webSignResult.signature!.isNotEmpty) {
        return WalletSignResult(
          signature: webSignResult.signature,
          openedExternalWallet: true,
          requiresManualInput: false,
          suggestedAddress: webSignResult.connectedAddress,
          message: 'TronLink signature captured from extension popup.',
        );
      }

      if (webSignResult.notInstalled) {
        final host = Uri.base.host.toLowerCase();
        final isLocalhost =
            host == 'localhost' || host == '127.0.0.1' || host == '::1';

        if (!isLocalhost) {
          await _openWebHelpPage('https://www.tronlink.org/');
        }
      }

      return WalletSignResult(
        signature: null,
        openedExternalWallet: false,
        requiresManualInput: true,
        suggestedAddress: webSignResult.accountMismatch
            ? webSignResult.connectedAddress
            : null,
        message: webSignResult.message,
      );
    }

    if (_isDesktopNativePlatform()) {
      return const WalletSignResult(
        signature: null,
        openedExternalWallet: false,
        requiresManualInput: true,
        message:
            'Desktop app mode cannot access browser extensions directly. For TronLink extension signing, run app on Chrome (`flutter run -d chrome`). Otherwise use manual signature mode.',
      );
    }

    final opened = await launchUrl(
      Uri.parse('tronlinkoutside://'),
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      // Fallback to official page so user gets a visible action on desktop.
      await launchUrl(
        Uri.parse('https://www.tronlink.org/'),
        mode: LaunchMode.externalApplication,
      );
    }

    return WalletSignResult(
      signature: null,
      openedExternalWallet: opened,
      requiresManualInput: true,
      message: opened
          ? 'Opened TronLink. Sign the challenge and paste the signature below.'
          : 'Could not open TronLink app (deep-link). Open TronLink manually or enable test mode for manual signature.',
    );
  }
}

class ManualTestWalletService implements WalletService {
  @override
  WalletClient get client => WalletClient.manual;

  @override
  Future<WalletSignResult> signMessage(WalletSignRequest request) async {
    return const WalletSignResult(
      signature: null,
      openedExternalWallet: false,
      requiresManualInput: true,
      message: 'Manual signature mode enabled. Paste signature to continue.',
    );
  }
}

class WalletServiceFactory {
  final MetaMaskWalletService _metamaskWalletService;
  final PhantomWalletService _phantomWalletService;
  final TronLinkWalletService _tronLinkWalletService;
  final ManualTestWalletService _manualTestWalletService;

  WalletServiceFactory({
    required MetaMaskWalletService metamaskWalletService,
    required PhantomWalletService phantomWalletService,
    required TronLinkWalletService tronLinkWalletService,
    required ManualTestWalletService manualTestWalletService,
  })  : _metamaskWalletService = metamaskWalletService,
        _phantomWalletService = phantomWalletService,
        _tronLinkWalletService = tronLinkWalletService,
        _manualTestWalletService = manualTestWalletService;

  WalletService forNetwork(BlockchainNetwork network,
      {required bool testMode}) {
    if (testMode) {
      return _manualTestWalletService;
    }

    switch (network) {
      case BlockchainNetwork.ethMainnet:
      case BlockchainNetwork.ethSepolia:
      case BlockchainNetwork.bscMainnet:
      case BlockchainNetwork.bscChapel:
      case BlockchainNetwork.baseMainnet:
      case BlockchainNetwork.baseSepolia:
      case BlockchainNetwork.arbitrumMainnet:
      case BlockchainNetwork.arbitrumSepolia:
      case BlockchainNetwork.optimismMainnet:
      case BlockchainNetwork.optimismSepolia:
      case BlockchainNetwork.polygonMainnet:
      case BlockchainNetwork.polygonAmoy:
      case BlockchainNetwork.avalancheMainnet:
      case BlockchainNetwork.avalancheFuji:
      case BlockchainNetwork.gnosisMainnet:
      case BlockchainNetwork.gnosisChiado:
      case BlockchainNetwork.lineaMainnet:
      case BlockchainNetwork.lineaSepolia:
      case BlockchainNetwork.fantomMainnet:
      case BlockchainNetwork.fantomTestnet:
        return _metamaskWalletService;
      case BlockchainNetwork.solanaMainnet:
      case BlockchainNetwork.solanaDevnet:
        return _phantomWalletService;
      case BlockchainNetwork.tronMainnet:
      case BlockchainNetwork.tronNile:
      case BlockchainNetwork.tronShasta:
        return _tronLinkWalletService;
      case BlockchainNetwork.tonMainnet:
      case BlockchainNetwork.tonTestnet:
        return _manualTestWalletService;
    }
  }
}
