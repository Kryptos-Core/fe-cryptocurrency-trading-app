import 'package:flutter/material.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';

class SigningGuideCard extends StatelessWidget {
  final BlockchainNetwork network;
  final bool isWebDialog;
  final bool testMode;

  const SigningGuideCard({
    super.key,
    required this.network,
    required this.isWebDialog,
    required this.testMode,
  });

  String _walletNameForNetwork() {
    switch (network) {
      case BlockchainNetwork.ethSepolia:
        return 'MetaMask';
      case BlockchainNetwork.solanaDevnet:
        return 'Phantom';
      case BlockchainNetwork.tronNile:
      case BlockchainNetwork.tronShasta:
        return 'TronLink';
    }
  }

  List<String> _nativeGuideSteps(AppLocalizations l10n) {
    if (testMode) {
      return [
        l10n.walletGuideTestStep1,
        l10n.walletGuideNativeTestStep2,
        l10n.walletGuideNativeTestStep3,
      ];
    }

    switch (network) {
      case BlockchainNetwork.ethSepolia:
        return [
          l10n.walletGuideNativeEthStep1,
          l10n.walletGuideNativeEthStep2,
          l10n.walletGuideNativeEthStep3,
        ];
      case BlockchainNetwork.solanaDevnet:
        return [
          l10n.walletGuideNativeSolStep1,
          l10n.walletGuideNativeSolStep2,
          l10n.walletGuideNativeSolStep3,
        ];
      case BlockchainNetwork.tronNile:
      case BlockchainNetwork.tronShasta:
        return [
          l10n.walletGuideNativeTronStep1,
          l10n.walletGuideNativeTronStep2,
          l10n.walletGuideNativeTronStep3,
        ];
    }
  }

  List<String> _webGuideSteps(AppLocalizations l10n) {
    if (testMode) {
      return [
        l10n.walletGuideTestStep1,
        l10n.walletGuideWebTestStep2,
        l10n.walletGuideWebTestStep3,
      ];
    }

    switch (network) {
      case BlockchainNetwork.ethSepolia:
        return [
          l10n.walletGuideWebEthStep1,
          l10n.walletGuideWebEthStep2,
          l10n.walletGuideWebEthStep3,
        ];
      case BlockchainNetwork.solanaDevnet:
        return [
          l10n.walletGuideWebSolStep1,
          l10n.walletGuideWebSolStep2,
          l10n.walletGuideWebSolStep3,
        ];
      case BlockchainNetwork.tronNile:
      case BlockchainNetwork.tronShasta:
        return [
          l10n.walletGuideWebTronStep1,
          l10n.walletGuideWebTronStep2,
          l10n.walletGuideWebTronStep3,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final walletName = _walletNameForNetwork();
    final steps = isWebDialog ? _webGuideSteps(l10n) : _nativeGuideSteps(l10n);

    final guideTitle = testMode
        ? l10n.manualSignGuideTitle
        : (isWebDialog
            ? l10n.browserSignGuideTitle(walletName)
            : l10n.desktopSignGuideTitle(walletName));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: testMode ? Colors.amber.shade50 : Colors.blue.shade50,
        border: Border.all(
          color: testMode ? Colors.amber.shade200 : Colors.blue.shade200,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                testMode
                    ? Icons.science_outlined
                    : Icons.desktop_windows_outlined,
                size: 18,
                color: testMode ? Colors.orange.shade700 : Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  guideTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('- $step', style: const TextStyle(fontSize: 12.5)),
            ),
          ),
        ],
      ),
    );
  }
}
