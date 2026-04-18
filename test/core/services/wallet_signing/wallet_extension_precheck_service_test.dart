import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/wallet_extension_precheck_service.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';

void main() {
  group('WalletExtensionPrecheckService', () {
    test('maps EVM testnet (BSC Chapel) to MetaMask target', () {
      final service = WalletExtensionPrecheckService();
      final target = service.targetForNetwork(BlockchainNetwork.bscChapel);

      expect(target, isNotNull);
      expect(target!.name, 'MetaMask');
      expect(target.installUrl, 'https://metamask.io/download/');
    });

    test('maps TRON networks to TronLink target', () {
      final service = WalletExtensionPrecheckService();

      final nileTarget = service.targetForNetwork(BlockchainNetwork.tronNile);
      final shastaTarget =
          service.targetForNetwork(BlockchainNetwork.tronShasta);

      expect(nileTarget, isNotNull);
      expect(nileTarget!.name, 'TronLink');
      expect(shastaTarget, isNotNull);
      expect(
        shastaTarget!.installUrl,
        'https://chromewebstore.google.com/detail/tronlink/ibnejdfjmmkpcnlpebklmnkoeoihofec',
      );
    });

    test('does not require precheck outside windows desktop', () {
      final service = WalletExtensionPrecheckService();

      final required = service.requiresPrecheck(
        network: BlockchainNetwork.bscChapel,
        isWebDialog: false,
        isTestMode: false,
        isWeb: false,
        platform: TargetPlatform.android,
      );

      expect(required, isFalse);
    });

    test('requires precheck on windows when network maps to extension target', () {
      final service = WalletExtensionPrecheckService();

      final evmRequired = service.requiresPrecheck(
        network: BlockchainNetwork.bscChapel,
        isWebDialog: false,
        isTestMode: false,
        isWeb: false,
        platform: TargetPlatform.windows,
      );
      final tronRequired = service.requiresPrecheck(
        network: BlockchainNetwork.tronShasta,
        isWebDialog: false,
        isTestMode: false,
        isWeb: false,
        platform: TargetPlatform.windows,
      );
      final solRequired = service.requiresPrecheck(
        network: BlockchainNetwork.solanaDevnet,
        isWebDialog: false,
        isTestMode: false,
        isWeb: false,
        platform: TargetPlatform.windows,
      );
      final tonRequired = service.requiresPrecheck(
        network: BlockchainNetwork.tonTestnet,
        isWebDialog: false,
        isTestMode: false,
        isWeb: false,
        platform: TargetPlatform.windows,
      );

      expect(evmRequired, isTrue);
      expect(tronRequired, isTrue);
      expect(solRequired, isTrue);
      expect(tonRequired, isFalse);
    });

    test('opens install page using injected opener', () async {
      var openedUrl = '';
      final service = WalletExtensionPrecheckService(
        openExternalUrl: (url) async {
          openedUrl = url;
          return true;
        },
      );

      final opened =
          await service.openExtensionInstallPage(BlockchainNetwork.tronNile);

      expect(opened, isTrue);
      expect(
        openedUrl,
        'https://chromewebstore.google.com/detail/tronlink/ibnejdfjmmkpcnlpebklmnkoeoihofec',
      );
    });

    test('opens extension page using injected opener', () async {
      var openedUrl = '';
      final service = WalletExtensionPrecheckService(
        openExternalUrl: (url) async {
          openedUrl = url;
          return true;
        },
      );

      final opened =
          await service.openExtensionPage(BlockchainNetwork.tronNile);

      expect(opened, isTrue);
      expect(
        openedUrl,
        'https://chromewebstore.google.com/detail/tronlink/ibnejdfjmmkpcnlpebklmnkoeoihofec',
      );
    });

    test('returns false when extension page cannot be opened', () async {
      final service = WalletExtensionPrecheckService(
        openExternalUrl: (_) async => false,
      );

      final opened =
          await service.openExtensionPage(BlockchainNetwork.tronNile);

      expect(opened, isFalse);
    });
  });
}
