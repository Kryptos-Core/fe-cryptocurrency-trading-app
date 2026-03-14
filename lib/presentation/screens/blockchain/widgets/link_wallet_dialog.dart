import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/wallet_service.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/presentation/providers/blockchain_provider.dart';

class LinkWalletDialog extends StatefulWidget {
  const LinkWalletDialog({super.key});

  @override
  State<LinkWalletDialog> createState() => _LinkWalletDialogState();
}

class _LinkWalletDialogState extends State<LinkWalletDialog> {
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

    final provider = context.read<BlockchainProvider>();
    final response = await provider.initiateWalletLink(
      chain: _selectedNetwork,
      address: _addressController.text.trim(),
      label: _labelController.text.trim().isEmpty ? null : _labelController.text.trim(),
    );

    if (!mounted) return;

    if (response == null) {
      showAppSnackBar(
        context,
        message: provider.error ?? 'Failed to request challenge',
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
      message: 'Challenge received. Expires in ${response.expiresIn}s',
      type: SnackBarType.info,
    );
  }

  Future<void> _signWithWallet() async {
    if (_challengeMessage == null) return;

    if (_testMode) {
      await Clipboard.setData(ClipboardData(text: _challengeMessage!));
      if (!mounted) return;
      showAppSnackBar(
        context,
        message: 'Manual mode: challenge copied. Sign it in wallet manually, then paste signature below.',
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

    showAppSnackBar(
      context,
      message: result.message,
      type: result.openedExternalWallet ? SnackBarType.success : SnackBarType.warning,
    );
  }

  Future<void> _verify() async {
    final signature = _signatureController.text.trim();
    if (_challengeMessage == null) {
      showAppSnackBar(
        context,
        message: 'Please request challenge first.',
        type: SnackBarType.warning,
      );
      return;
    }
    if (signature.isEmpty) {
      showAppSnackBar(
        context,
        message: 'Signature is required.',
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
        message: 'Wallet linked successfully.',
        type: SnackBarType.success,
      );
      Navigator.of(context).pop();
    } else {
      showAppSnackBar(
        context,
        message: provider.error ?? 'Verify failed',
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

  List<String> _desktopGuideSteps() {
    if (_testMode) {
      return const [
        'Step 2 copies the challenge text to your clipboard.',
        'Open your wallet or signer tool manually and sign the exact challenge text.',
        'Paste the resulting signature into the Signature field, then click Verify Link.',
      ];
    }

    switch (_selectedNetwork) {
      case BlockchainNetwork.ethSepolia:
        return const [
          'Install MetaMask browser extension and unlock it.',
          'Use an account on Sepolia network that matches the wallet address you entered.',
          'Click Step 2 to trigger deep-link; if nothing opens, sign manually in MetaMask and paste signature below.',
        ];
      case BlockchainNetwork.solanaDevnet:
        return const [
          'Install Phantom extension or desktop app and unlock it.',
          'Switch wallet to Solana Devnet and use the same address you entered.',
          'Click Step 2; if deep-link fails, sign the challenge manually and paste signature below.',
        ];
      case BlockchainNetwork.tronNile:
      case BlockchainNetwork.tronShasta:
        return const [
          'Install TronLink extension/app and unlock it.',
          'Switch to Nile or Shasta account matching your entered address.',
          'Click Step 2; if app does not open, open TronLink manually, sign challenge, then paste signature below.',
        ];
    }
  }

  Widget _buildSigningGuideCard() {
    final walletName = _walletNameForNetwork();
    final steps = _desktopGuideSteps();

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
                _testMode ? Icons.science_outlined : Icons.desktop_windows_outlined,
                size: 18,
                color: _testMode ? Colors.orange.shade700 : Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                _testMode
                    ? 'Manual signing guide (Test mode)'
                    : 'Desktop signing guide ($walletName)',
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
      title: const Text('Link Wallet'),
      content: SizedBox(
        width: 500,
        child: Consumer<BlockchainProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<BlockchainNetwork>(
                      initialValue: _selectedNetwork,
                      decoration: const InputDecoration(
                        labelText: 'Network',
                        border: OutlineInputBorder(),
                      ),
                      items: BlockchainNetwork.values
                          .map(
                            (network) => DropdownMenuItem(
                              value: network,
                              child: Text(network.label),
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
                    TextFormField(
                      controller: _addressController,
                      enabled: !provider.isSubmitting,
                      decoration: const InputDecoration(
                        labelText: 'Wallet address',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Address is required';
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
                          icon: const Icon(Icons.account_balance_wallet_outlined),
                          label: Text('Use connected account (${_suggestedConnectedAddress!})'),
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
                                    message:
                                        'Wallet address updated from MetaMask. Request a new challenge before signing.',
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
                      decoration: const InputDecoration(
                        labelText: 'Label (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enable test mode (manual signature fallback)'),
                      value: _testMode,
                      onChanged: provider.isSubmitting
                          ? null
                          : (value) => setState(() => _testMode = value),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: provider.isSubmitting ? null : _requestChallenge,
                        icon: const Icon(Icons.key),
                        label: Text(
                          provider.isSubmitting ? 'Requesting...' : '1) Request Challenge',
                        ),
                      ),
                    ),
                    if (_challengeMessage != null) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Challenge message',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                          onPressed: provider.isSubmitting ? null : _signWithWallet,
                          icon: const Icon(Icons.open_in_new),
                          label: Text(
                            _testMode
                                ? '2) Copy Challenge (Manual)'
                                : '2) Open Wallet & Sign',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildSigningGuideCard(),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _signatureController,
                        maxLines: 3,
                        enabled: !provider.isSubmitting,
                        decoration: const InputDecoration(
                          labelText: 'Signature',
                          hintText: 'Paste wallet signature here',
                          border: OutlineInputBorder(),
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
          child: const Text('Close'),
        ),
        Consumer<BlockchainProvider>(
          builder: (context, provider, _) => FilledButton(
            onPressed: provider.isSubmitting ? null : _verify,
            child: Text(provider.isSubmitting ? 'Verifying...' : '3) Verify Link'),
          ),
        ),
      ],
    );
  }
}
