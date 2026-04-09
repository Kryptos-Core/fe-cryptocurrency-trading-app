import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/wallet_extension_precheck_service.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/screens/blockchain/widgets/signing_guide_card.dart';
import 'package:crypto_trading_app/presentation/screens/blockchain/widgets/windows_extension_precheck_card.dart';

class WalletChallengeSection extends StatelessWidget {
  final String challengeMessage;
  final bool testMode;
  final bool isWebDialog;
  final bool isSubmitting;
  final BlockchainNetwork network;
  final VoidCallback? onSignPressed;
  final TextEditingController signatureController;
  final bool showWindowsPrecheck;
  final bool windowsPrechecked;
  final WalletExtensionPrecheckService extensionPrecheckService;
  final GlobalKey<WindowsExtensionPrecheckCardState> windowsPrecheckKey;
  final ValueChanged<bool> onWindowsPrecheckChanged;

  const WalletChallengeSection({
    super.key,
    required this.challengeMessage,
    required this.testMode,
    required this.isWebDialog,
    required this.isSubmitting,
    required this.network,
    required this.onSignPressed,
    required this.signatureController,
    required this.showWindowsPrecheck,
    required this.windowsPrechecked,
    required this.extensionPrecheckService,
    required this.windowsPrecheckKey,
    required this.onWindowsPrecheckChanged,
  });

  bool get _showWindowsNativeTronNotice {
    return !isWebDialog && network.isTronFamily;
  }

  String _step2Label(AppLocalizations l10n) {
    if (testMode) return l10n.copyChallengManual;
    if (isWebDialog) return l10n.openExtensionSign;

    if (network.isTronFamily) {
      return l10n.openWalletManualSign;
    }

    return l10n.openWalletSign;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.challengeMessageTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            challengeMessage,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isSubmitting ? null : onSignPressed,
            icon: const Icon(Icons.open_in_new),
            label: Text(_step2Label(l10n)),
          ),
        ),
        if (_showWindowsNativeTronNotice) ...[
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.blue.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              l10n.walletWindowsNativeSignNotice,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        if (showWindowsPrecheck) ...[
          WindowsExtensionPrecheckCard(
            key: windowsPrecheckKey,
            network: network,
            isPrechecked: windowsPrechecked,
            enabled: !isSubmitting,
            precheckService: extensionPrecheckService,
            onPrecheckChanged: onWindowsPrecheckChanged,
          ),
          const SizedBox(height: 8),
        ],
        SigningGuideCard(
          network: network,
          isWebDialog: isWebDialog,
          testMode: testMode,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: signatureController,
          maxLines: 3,
          enabled: !isSubmitting,
          decoration: InputDecoration(
            labelText: l10n.signatureLabel,
            hintText: l10n.pasteSignatureHint,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
