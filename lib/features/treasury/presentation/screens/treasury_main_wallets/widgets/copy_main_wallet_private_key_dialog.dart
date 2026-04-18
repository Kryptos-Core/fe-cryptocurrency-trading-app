import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/treasury_main_wallet_provider.dart';
import 'package:crypto_trading_app/features/profile/presentation/screens/profile_screen.dart';

/// Reveals private key after email OTP (same verification as import) and copies to clipboard.
class CopyMainWalletPrivateKeyDialog extends StatefulWidget {
  const CopyMainWalletPrivateKeyDialog({super.key, required this.mainWalletId});

  final String mainWalletId;

  @override
  State<CopyMainWalletPrivateKeyDialog> createState() => _CopyMainWalletPrivateKeyDialogState();
}

class _CopyMainWalletPrivateKeyDialogState extends State<CopyMainWalletPrivateKeyDialog> {
  static const String _kInvalidMfaCode = 'INVALID_MFA_CODE';

  final _mfaCodeController = TextEditingController();

  bool _isSendingOtp = false;
  String? _mfaFieldError;

  @override
  void dispose() {
    _mfaCodeController.dispose();
    super.dispose();
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
      setState(() => _mfaFieldError = null);
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

  Future<void> _revealAndCopy() async {
    final l10n = AppLocalizations.of(context);
    final code = _mfaCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.treasuryImportWalletOtpEmpty)),
      );
      return;
    }

    final provider = context.read<TreasuryMainWalletProvider>();
    final pk = await provider.revealMainWalletPrivateKey(
      mainWalletId: widget.mainWalletId,
      mfaCode: code,
    );
    if (!mounted) return;

    if (pk != null) {
      await Clipboard.setData(ClipboardData(text: pk));
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.treasuryMainWalletCopiedPrivateKeySnack)),
      );
      return;
    }

    final failureCode = provider.importFailureCode;
    if (failureCode == _kInvalidMfaCode) {
      setState(() {
        _mfaFieldError = l10n.treasuryImportWalletMfaExpiredOnImport;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.treasuryImportWalletErrorSnack(provider.error ?? ''),
          ),
        ),
      );
    }
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

    final isSubmitting = context.watch<TreasuryMainWalletProvider>().isSubmitting;
    final otpBusy = _isSendingOtp || isSubmitting;

    return AlertDialog(
      title: Text(l10n.treasuryMainWalletRevealKeyTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.treasuryMainWalletRevealKeyHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.treasuryImportWalletMfaCode,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _mfaCodeController,
                    decoration: InputDecoration(
                      isDense: true,
                      errorText: _mfaFieldError,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: otpBusy ? null : _sendMfaOtp,
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: isSubmitting ? null : _revealAndCopy,
          child: isSubmitting
              ? SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : Text(l10n.treasuryMainWalletRevealKeyCopy),
        ),
      ],
    );
  }
}
