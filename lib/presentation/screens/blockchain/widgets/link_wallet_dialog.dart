import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/wallet_service.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/presentation/providers/blockchain_provider.dart';

class LinkWalletDialog extends StatelessWidget {
  const LinkWalletDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? const WebLinkWalletDialog()
        : const NativeLinkWalletDialog();
  }
}

class WebLinkWalletDialog extends _PlatformLinkWalletDialog {
  const WebLinkWalletDialog({super.key});

  @override
  bool get isWebDialog => true;

  @override
  String get dialogTitle => 'Link Wallet (Web)';

  @override
  double get dialogWidth => 640;
}

class NativeLinkWalletDialog extends _PlatformLinkWalletDialog {
  const NativeLinkWalletDialog({super.key});

  @override
  bool get isWebDialog => false;

  @override
  String get dialogTitle => 'Link Wallet';

  @override
  double get dialogWidth => 500;
}

abstract class _PlatformLinkWalletDialog extends StatefulWidget {
  const _PlatformLinkWalletDialog({super.key});

  bool get isWebDialog;
  String get dialogTitle;
  double get dialogWidth;

  @override
  State<_PlatformLinkWalletDialog> createState() =>
      _PlatformLinkWalletDialogState();
}

class _PlatformLinkWalletDialogState extends State<_PlatformLinkWalletDialog> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _labelController = TextEditingController();
  final _signatureController = TextEditingController();

  BlockchainNetwork _selectedNetwork = BlockchainNetwork.ethSepolia;
  bool _testMode = false;
  String? _challengeMessage;
  String? _suggestedConnectedAddress;

  @override
  void dispose() {
    _addressController.dispose();
    _labelController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _requestChallenge() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);

    final provider = context.read<BlockchainProvider>();
    final response = await provider.initiateWalletLink(
      chain: _selectedNetwork,
      address: _addressController.text.trim(),
      label: _labelController.text.trim().isEmpty
          ? null
          : _labelController.text.trim(),
    );

    if (!mounted) return;

    if (response == null) {
      showAppSnackBar(
        context,
        message: provider.error ?? l10n.failedToRequestChallenge,
        type: SnackBarType.error,
      );
      return;
    }

    setState(() {
      _challengeMessage = response.message;
      _signatureController.clear();
      _suggestedConnectedAddress = null;
    });

    showAppSnackBar(
      context,
      message: l10n.challengeReceived(response.expiresIn),
      type: SnackBarType.info,
    );
  }

  Future<void> _signWithWallet() async {
    if (_challengeMessage == null) return;
    final l10n = AppLocalizations.of(context);

    if (_testMode) {
      await Clipboard.setData(ClipboardData(text: _challengeMessage!));
      if (!mounted) return;
      showAppSnackBar(
        context,
        message: l10n.manualModeCopied,
        type: SnackBarType.info,
      );
      return;
    }

    final walletServiceFactory = sl<WalletServiceFactory>();
    final walletService = walletServiceFactory.forNetwork(
      _selectedNetwork,
      testMode: _testMode,
    );

    final result = await walletService.signMessage(
      WalletSignRequest(
        network: _selectedNetwork,
        address: _addressController.text.trim(),
        message: _challengeMessage!,
      ),
    );

    if (!mounted) return;

    if (result.signature != null && result.signature!.isNotEmpty) {
      _signatureController.text = result.signature!;
    }

    setState(() {
      _suggestedConnectedAddress = result.suggestedAddress;
    });

    if (!mounted) return;
    showAppSnackBar(
      context,
      message: result.message,
      type: result.openedExternalWallet
          ? SnackBarType.success
          : SnackBarType.warning,
    );
  }

  Future<void> _verify() async {
    final signature = _signatureController.text.trim();
    final l10n = AppLocalizations.of(context);
    if (_challengeMessage == null) {
      showAppSnackBar(
        context,
        message: l10n.requestChallengeFirst,
        type: SnackBarType.warning,
      );
      return;
    }
    if (signature.isEmpty) {
      showAppSnackBar(
        context,
        message: l10n.signatureRequired,
        type: SnackBarType.warning,
      );
      return;
    }

    final provider = context.read<BlockchainProvider>();
    final ok = await provider.verifyWalletLink(
      chain: _selectedNetwork,
      address: _addressController.text.trim(),
      signature: signature,
    );

    if (!mounted) return;

    if (ok) {
      showAppSnackBar(
        context,
        message: l10n.walletLinkedSuccess,
        type: SnackBarType.success,
      );
      Navigator.of(context).pop();
    } else {
      showAppSnackBar(
        context,
        message: provider.error ?? l10n.verifyFailed,
        type: SnackBarType.error,
      );
    }
  }

  String _walletNameForNetwork() {
    switch (_selectedNetwork) {
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
    if (_testMode) {
      return [
        l10n.walletGuideTestStep1,
        l10n.walletGuideNativeTestStep2,
        l10n.walletGuideNativeTestStep3,
      ];
    }

    switch (_selectedNetwork) {
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
    if (_testMode) {
      return [
        l10n.walletGuideTestStep1,
        l10n.walletGuideWebTestStep2,
        l10n.walletGuideWebTestStep3,
      ];
    }

    switch (_selectedNetwork) {
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

  Widget _buildPlatformNoticeCard(AppLocalizations l10n) {
    if (widget.isWebDialog) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          border: Border.all(color: Colors.green.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.language_outlined,
                size: 18, color: Colors.green.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.webModeNotice,
                style: const TextStyle(fontSize: 12.5),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        border: Border.all(color: Colors.indigo.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.devices_outlined, size: 18, color: Colors.indigo.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.appModeNotice,
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSigningGuideCard(AppLocalizations l10n) {
    final walletName = _walletNameForNetwork();
    final steps =
        widget.isWebDialog ? _webGuideSteps(l10n) : _nativeGuideSteps(l10n);
    final guideTitle = _testMode
        ? l10n.manualSignGuideTitle
        : (widget.isWebDialog
            ? l10n.browserSignGuideTitle(walletName)
            : l10n.desktopSignGuideTitle(walletName));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _testMode ? Colors.amber.shade50 : Colors.blue.shade50,
        border: Border.all(
          color: _testMode ? Colors.amber.shade200 : Colors.blue.shade200,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _testMode
                    ? Icons.science_outlined
                    : Icons.desktop_windows_outlined,
                size: 18,
                color:
                    _testMode ? Colors.orange.shade700 : Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                guideTitle,
                style: const TextStyle(fontWeight: FontWeight.w600),
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isWebDialog
          ? AppLocalizations.of(context).linkWalletWeb
          : AppLocalizations.of(context).linkWallet),
      content: SizedBox(
        width: widget.dialogWidth,
        child: Consumer<BlockchainProvider>(
          builder: (context, provider, _) {
            final l10n = AppLocalizations.of(context);
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<BlockchainNetwork>(
                      value: _selectedNetwork,
                      isExpanded: true,
                      menuMaxHeight: 300,
                      decoration: InputDecoration(
                        labelText: l10n.networkLabel,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      ),
                      items: BlockchainNetwork.values
                          .map(
                            (network) => DropdownMenuItem(
                              value: network,
                              child: Text(
                                network.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: provider.isSubmitting
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedNetwork = value;
                                  _challengeMessage = null;
                                  _signatureController.clear();
                                  _suggestedConnectedAddress = null;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 10),
                    _buildPlatformNoticeCard(l10n),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _addressController,
                      enabled: !provider.isSubmitting,
                      decoration: InputDecoration(
                        labelText: l10n.walletAddressLabel,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.walletAddressRequired;
                        }
                        return null;
                      },
                    ),
                    if (_suggestedConnectedAddress != null &&
                        _suggestedConnectedAddress!.isNotEmpty &&
                        _suggestedConnectedAddress!.toLowerCase() !=
                            _addressController.text.trim().toLowerCase()) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          icon:
                              const Icon(Icons.account_balance_wallet_outlined),
                          label: Text(l10n.useConnectedAccount(
                              _suggestedConnectedAddress!)),
                          onPressed: provider.isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    _addressController.text =
                                        _suggestedConnectedAddress!;
                                    _challengeMessage = null;
                                    _signatureController.clear();
                                    _suggestedConnectedAddress = null;
                                  });

                                  showAppSnackBar(
                                    context,
                                    message: AppLocalizations.of(context)
                                        .walletAddressUpdatedMetamask,
                                    type: SnackBarType.info,
                                  );
                                },
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _labelController,
                      enabled: !provider.isSubmitting,
                      decoration: InputDecoration(
                        labelText: l10n.labelOptional,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.enableTestMode),
                      value: _testMode,
                      onChanged: provider.isSubmitting
                          ? null
                          : (value) => setState(() => _testMode = value),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed:
                            provider.isSubmitting ? null : _requestChallenge,
                        icon: const Icon(Icons.key),
                        label: Text(
                          provider.isSubmitting
                              ? l10n.requestingChallenge
                              : l10n.requestChallengeStep,
                        ),
                      ),
                    ),
                    if (_challengeMessage != null) ...[
                      const SizedBox(height: 12),
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
                          _challengeMessage!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed:
                              provider.isSubmitting ? null : _signWithWallet,
                          icon: const Icon(Icons.open_in_new),
                          label: Text(
                            _testMode
                                ? l10n.copyChallengManual
                                : (widget.isWebDialog
                                    ? l10n.openExtensionSign
                                    : l10n.openWalletSign),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildSigningGuideCard(l10n),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _signatureController,
                        maxLines: 3,
                        enabled: !provider.isSubmitting,
                        decoration: InputDecoration(
                          labelText: l10n.signatureLabel,
                          hintText: l10n.pasteSignatureHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).close),
        ),
        Consumer<BlockchainProvider>(
          builder: (context, provider, _) => FilledButton(
            onPressed: provider.isSubmitting ? null : _verify,
            child: Text(provider.isSubmitting
                ? AppLocalizations.of(context).verifyingLink
                : AppLocalizations.of(context).verifyLinkStep),
          ),
        ),
      ],
    );
  }
}
