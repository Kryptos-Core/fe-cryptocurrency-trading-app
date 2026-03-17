import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/wallet_service.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/wallet_extension_precheck_service.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/presentation/providers/blockchain_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/app_dropdown_field.dart';
import 'package:crypto_trading_app/presentation/screens/blockchain/widgets/windows_extension_precheck_card.dart';
import 'package:crypto_trading_app/presentation/screens/blockchain/widgets/platform_notice_card.dart';
import 'package:crypto_trading_app/presentation/screens/blockchain/widgets/wallet_challenge_section.dart';

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
  final _extensionPrecheckService = sl<WalletExtensionPrecheckService>();
  final _windowsPrecheckKey = GlobalKey<WindowsExtensionPrecheckCardState>();
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _labelController = TextEditingController();
  final _signatureController = TextEditingController();

  BlockchainNetwork _selectedNetwork = BlockchainNetwork.ethSepolia;
  bool _testMode = false;
  String? _challengeMessage;
  String? _suggestedConnectedAddress;
  bool _windowsExtensionPrechecked = false;

  bool get _requiresWindowsExtensionPrecheck {
    return _extensionPrecheckService.requiresPrecheck(
      network: _selectedNetwork,
      isWebDialog: widget.isWebDialog,
      isTestMode: _testMode,
      isWeb: kIsWeb,
      platform: defaultTargetPlatform,
    );
  }

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

    if (_requiresWindowsExtensionPrecheck) {
      if (!_windowsExtensionPrechecked) {
        final ready =
            await _windowsPrecheckKey.currentState?.runPrecheckFlow() ?? false;
        if (!ready || !mounted) return;
      }

      await Clipboard.setData(ClipboardData(text: _challengeMessage!));
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: l10n.walletExtensionPrecheckSuccess,
        type: SnackBarType.success,
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
                    AppDropdownField<BlockchainNetwork>(
                      value: _selectedNetwork,
                      menuMaxHeight: 300,
                      labelText: l10n.networkLabel,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 15),
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
                                  _windowsExtensionPrechecked = false;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 10),
                    PlatformNoticeCard(isWebDialog: widget.isWebDialog),
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
                          : (value) {
                              setState(() {
                                _testMode = value;
                                _windowsExtensionPrechecked = false;
                              });
                            },
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
                      WalletChallengeSection(
                        challengeMessage: _challengeMessage!,
                        testMode: _testMode,
                        isWebDialog: widget.isWebDialog,
                        isSubmitting: provider.isSubmitting,
                        network: _selectedNetwork,
                        onSignPressed: _signWithWallet,
                        signatureController: _signatureController,
                        showWindowsPrecheck: _requiresWindowsExtensionPrecheck,
                        windowsPrechecked: _windowsExtensionPrechecked,
                        extensionPrecheckService: _extensionPrecheckService,
                        windowsPrecheckKey: _windowsPrecheckKey,
                        onWindowsPrecheckChanged: (value) {
                          setState(() {
                            _windowsExtensionPrechecked = value;
                          });
                        },
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
