import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/constants/treasury_chains.dart';
import 'package:crypto_trading_app/presentation/constants/treasury_private_key_format.dart';
import 'package:crypto_trading_app/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_main_wallet_provider.dart';
import 'package:crypto_trading_app/screens/profile_screen.dart';

class ImportWalletDialog extends StatefulWidget {
  const ImportWalletDialog({super.key});

  @override
  State<ImportWalletDialog> createState() => _ImportWalletDialogState();
}

class _ImportWalletDialogState extends State<ImportWalletDialog> {
  static const String _kInvalidMfaCode = 'INVALID_MFA_CODE';

  final _labelController = TextEditingController();
  final _privateKeyController = TextEditingController();
  final _mfaCodeController = TextEditingController();
  final _privateKeyFocus = FocusNode();
  final _mfaFocus = FocusNode();

  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  bool _otpVerified = false;
  /// Stays true after the first successful OTP confirm so label/private key stay visible if email OTP expires on import.
  bool _walletFieldsUnlocked = false;
  String? _verifiedCode;
  String? _mfaFieldError;

  @override
  void initState() {
    super.initState();
    _mfaCodeController.addListener(_onOtpTextChanged);
  }

  void _onOtpTextChanged() {
    if (_mfaFieldError != null) {
      setState(() => _mfaFieldError = null);
    }
    if (!mounted || !_otpVerified || _verifiedCode == null) return;
    if (_mfaCodeController.text.trim() != _verifiedCode) {
      setState(() {
        _otpVerified = false;
        _verifiedCode = null;
      });
    }
  }

  Future<void> _sendMfaOtp() async {
    setState(() => _isSendingOtp = true);
    final provider = context.read<TreasuryMainWalletProvider>();
    final success = await provider.sendMfaOtp();
    if (!mounted) return;
    setState(() => _isSendingOtp = false);
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (success) {
      if (mounted) setState(() => _mfaFieldError = null);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.treasuryImportWalletMfaSentSnack)),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.treasuryImportWalletMfaFailedSnack(provider.error ?? ''),
          ),
        ),
      );
    }
  }

  Future<void> _confirmOtp() async {
    final l10n = AppLocalizations.of(context);
    final code = _mfaCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.treasuryImportWalletOtpEmpty)),
      );
      return;
    }

    setState(() => _isVerifyingOtp = true);
    final provider = context.read<TreasuryMainWalletProvider>();
    final ok = await provider.verifyMfaOtp(code);
    if (!mounted) return;
    setState(() => _isVerifyingOtp = false);
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      setState(() {
        _otpVerified = true;
        _verifiedCode = code;
        _walletFieldsUnlocked = true;
        _mfaFieldError = null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _privateKeyFocus.requestFocus();
        }
      });
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.treasuryImportWalletOtpVerifyFailed(provider.error ?? ''),
          ),
        ),
      );
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_otpVerified) return;

    final label = _labelController.text.trim();
    final pk = _privateKeyController.text.trim();
    final mfa = _mfaCodeController.text.trim();

    if (pk.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.treasuryImportWalletPrivateKeyRequired)),
      );
      return;
    }
    if (mfa.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.treasuryImportWalletOtpEmpty)),
      );
      return;
    }

    final currentChain = context.read<TreasuryMainWalletProvider>().currentChain;
    final formatIssue = detectTreasuryImportPrivateKeyFormatIssue(currentChain, pk);
    if (formatIssue != null) {
      final hint = switch (formatIssue) {
        TreasuryImportPrivateKeyFormatIssue.tronAddressInsteadOfKey =>
          l10n.treasuryImportWalletMistakeTronAddress,
        TreasuryImportPrivateKeyFormatIssue.evmAddressInsteadOfKey =>
          l10n.treasuryImportWalletMistakeEvmAddress,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(hint)),
      );
      return;
    }

    final provider = context.read<TreasuryMainWalletProvider>();
    final success = await provider.importMainWallet(
      label: label,
      privateKey: pk,
      mfaCode: mfa,
    );

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (success) {
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.treasuryImportWalletSuccessSnack)),
      );
    } else {
      final failureCode = provider.importFailureCode;
      if (failureCode == _kInvalidMfaCode) {
        setState(() {
          _otpVerified = false;
          _verifiedCode = null;
          _mfaFieldError = l10n.treasuryImportWalletMfaExpiredOnImport;
        });
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.treasuryImportWalletMfaExpiredOnImportSnack),
            behavior: SnackBarBehavior.floating,
          ),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _mfaFocus.requestFocus();
        });
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              l10n.treasuryImportWalletErrorSnack(provider.error ?? ''),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _mfaCodeController.removeListener(_onOtpTextChanged);
    _labelController.dispose();
    _privateKeyController.dispose();
    _mfaCodeController.dispose();
    _privateKeyFocus.dispose();
    _mfaFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    if (!auth.hasRealEmailForOtp) {
      return AlertDialog(
        title: Text(l10n.contactEmailRequiredForOtpShort),
        content: Text(l10n.contactEmailRequiredForOtpBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
            child: Text(l10n.contactEmailGoToProfile),
          ),
        ],
      );
    }

    final isSubmitting =
        context.watch<TreasuryMainWalletProvider>().isSubmitting;
    final currentChain =
        context.watch<TreasuryMainWalletProvider>().currentChain;
    final chainLabel = treasuryChainDisplayLabel(l10n, currentChain);

    final otpBusy = _isSendingOtp || isSubmitting;
    final canConfirmOtp =
        !_otpVerified && !_isVerifyingOtp && !otpBusy;

    return AlertDialog(
      title: Text(l10n.treasuryImportWalletDialogTitle(chainLabel)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.treasuryImportWalletOtpStepHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _mfaCodeController,
                    focusNode: _mfaFocus,
                    enabled: !_otpVerified,
                    decoration: InputDecoration(
                      labelText: l10n.treasuryImportWalletMfaCode,
                      errorText: _mfaFieldError,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: otpBusy || _otpVerified ? null : _sendMfaOtp,
                  child: _isSendingOtp
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.treasuryImportWalletSendOtp),
                ),
              ],
            ),
            if (_walletFieldsUnlocked) ...[
              const SizedBox(height: 20),
              TextField(
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: l10n.treasuryImportWalletLabelOptional,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _privateKeyController,
                focusNode: _privateKeyFocus,
                decoration: InputDecoration(
                  labelText: l10n.treasuryImportWalletPrivateKey,
                ),
                obscureText: true,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        if (!_otpVerified)
          ElevatedButton(
            onPressed: canConfirmOtp ? _confirmOtp : null,
            child: _isVerifyingOtp
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.treasuryImportWalletConfirmOtp),
          )
        else
          ElevatedButton(
            onPressed: isSubmitting ? null : _submit,
            child: isSubmitting
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.treasuryImportWalletImport),
          ),
      ],
    );
  }
}
