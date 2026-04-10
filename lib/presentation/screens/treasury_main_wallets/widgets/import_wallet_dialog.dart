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

  static const double _radius = 20;
  static const double _fieldRadius = 12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();

    final dialogShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_radius),
    );

    if (!auth.hasRealEmailForOtp) {
      return AlertDialog(
        surfaceTintColor: Colors.transparent,
        backgroundColor: cs.surface,
        shape: dialogShape,
        icon: Icon(Icons.mark_email_unread_outlined, color: cs.primary, size: 28),
        title: Text(
          l10n.contactEmailRequiredForOtpShort,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        content: Text(
          l10n.contactEmailRequiredForOtpBody,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        actionsAlignment: MainAxisAlignment.end,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
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
    final chainLabel = treasuryWalletCreationDisplayLabel(l10n, currentChain);

    final otpBusy = _isSendingOtp || isSubmitting;
    final canConfirmOtp =
        !_otpVerified && !_isVerifyingOtp && !otpBusy;

    final outlineDecoration = ({String? label, String? error, String? helper}) =>
        InputDecoration(
          labelText: label,
          errorText: error,
          helperText: helper,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(_fieldRadius)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_fieldRadius),
            borderSide: BorderSide(color: cs.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_fieldRadius),
            borderSide: BorderSide(color: cs.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_fieldRadius),
            borderSide: BorderSide(color: cs.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_fieldRadius),
            borderSide: BorderSide(color: cs.error, width: 2),
          ),
        );

    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: cs.surface,
      shape: dialogShape,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      constraints: const BoxConstraints(maxWidth: 420),
      icon: Icon(Icons.account_balance_wallet_outlined, color: cs.primary, size: 28),
      title: Text(
        l10n.treasuryImportWalletDialogHeading,
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.treasuryImportWalletDialogChainLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Chip(
                avatar: Icon(Icons.hub_outlined, size: 18, color: cs.primary),
                label: Text(chainLabel),
                backgroundColor: cs.surfaceContainerHighest,
                side: BorderSide(color: cs.outlineVariant),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.treasuryImportWalletOtpStepHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mfaCodeController,
              focusNode: _mfaFocus,
              enabled: !_otpVerified,
              keyboardType: TextInputType.number,
              decoration: outlineDecoration(
                label: l10n.treasuryImportWalletMfaCode,
                error: _mfaFieldError,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton.icon(
                onPressed: otpBusy || _otpVerified ? null : _sendMfaOtp,
                icon: _isSendingOtp
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.primary,
                        ),
                      )
                    : Icon(Icons.mark_email_read_outlined, size: 20, color: cs.primary),
                label: Text(l10n.treasuryImportWalletSendOtp),
              ),
            ),
            if (_otpVerified) ...[
              const SizedBox(height: 16),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(_fieldRadius),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.verified_outlined, color: cs.primary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.treasuryImportWalletOtpVerifiedBanner,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onPrimaryContainer,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_walletFieldsUnlocked) ...[
              const SizedBox(height: 20),
              TextField(
                controller: _labelController,
                decoration: outlineDecoration(label: l10n.treasuryImportWalletLabelOptional),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _privateKeyController,
                focusNode: _privateKeyFocus,
                decoration: outlineDecoration(label: l10n.treasuryImportWalletPrivateKey),
                obscureText: true,
              ),
            ],
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: isSubmitting ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        if (!_otpVerified)
          FilledButton(
            onPressed: canConfirmOtp ? _confirmOtp : null,
            child: _isVerifyingOtp
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.onPrimary,
                    ),
                  )
                : Text(l10n.treasuryImportWalletConfirmOtp),
          )
        else
          FilledButton(
            onPressed: isSubmitting ? null : _submit,
            child: isSubmitting
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.onPrimary,
                    ),
                  )
                : Text(l10n.treasuryImportWalletImport),
          ),
      ],
    );
  }
}
