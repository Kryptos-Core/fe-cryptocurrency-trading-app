import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';

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
  final String message;

  const WalletSignResult({
    required this.signature,
    required this.openedExternalWallet,
    required this.requiresManualInput,
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
    // WalletConnect is not wired yet in this project; we deep-link to MetaMask app
    // and keep a manual signature fallback for test/demo flows.
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
          : 'Could not open MetaMask. Use manual signature input (test mode).',
    );
  }
}

class PhantomWalletService implements WalletService {
  @override
  WalletClient get client => WalletClient.phantom;

  @override
  Future<WalletSignResult> signMessage(WalletSignRequest request) async {
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
          : 'Could not open Phantom. Use manual signature input (test mode).',
    );
  }
}

class TronLinkWalletService implements WalletService {
  @override
  WalletClient get client => WalletClient.tronlink;

  @override
  Future<WalletSignResult> signMessage(WalletSignRequest request) async {
    final opened = await launchUrl(
      Uri.parse('tronlinkoutside://'),
      mode: LaunchMode.externalApplication,
    );

    return WalletSignResult(
      signature: null,
      openedExternalWallet: opened,
      requiresManualInput: true,
      message: opened
          ? 'Opened TronLink. Sign the challenge and paste the signature below.'
          : 'Could not open TronLink. Use manual signature input (test mode).',
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

  WalletService forNetwork(BlockchainNetwork network, {required bool testMode}) {
    if (testMode || kDebugMode) {
      return _manualTestWalletService;
    }

    switch (network) {
      case BlockchainNetwork.ethSepolia:
        return _metamaskWalletService;
      case BlockchainNetwork.solanaDevnet:
        return _phantomWalletService;
      case BlockchainNetwork.tronNile:
      case BlockchainNetwork.tronShasta:
        return _tronLinkWalletService;
    }
  }
}
