import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/wallet_extension_precheck_service.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';

void main() {
  group('WalletExtensionPrecheckService', () {
    test('maps ETH network to MetaMask target', () {
      final service = WalletExtensionPrecheckService();
      final target = service.targetForNetwork(BlockchainNetwork.ethSepolia);

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
      expect(shastaTarget!.installUrl, 'https://www.tronlink.org/');
    });

    test('does not require precheck outside windows desktop', () {
      final service = WalletExtensionPrecheckService();

      final required = service.requiresPrecheck(
        network: BlockchainNetwork.ethSepolia,
        isWebDialog: false,
        isTestMode: false,
        isWeb: false,
        platform: TargetPlatform.android,
      );

      expect(required, isFalse);
    });

    test('requires precheck on windows for ETH and TRON only', () {
      final service = WalletExtensionPrecheckService();

      final ethRequired = service.requiresPrecheck(
        network: BlockchainNetwork.ethSepolia,
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

      expect(ethRequired, isTrue);
      expect(tronRequired, isTrue);
      expect(solRequired, isFalse);
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
      expect(openedUrl, 'https://www.tronlink.org/');
    });
  });
}
