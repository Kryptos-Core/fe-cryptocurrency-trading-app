import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/data/repositories/auth_repository_impl.dart';
import 'package:crypto_trading_app/domain/entities/user.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';

/// Xác minh email liên hệ cho tài khoản đăng nhập ví: OTP gửi thẳng tới email mới.
class WalletContactEmailVerificationDialog extends StatefulWidget {
  final AuthRepository authRepo;
  final String token;

  const WalletContactEmailVerificationDialog({
    super.key,
    required this.authRepo,
    required this.token,
  });

  static Future<User?> show(
    BuildContext context, {
    required AuthRepository authRepo,
    required String token,
  }) {
    return showDialog<User>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          WalletContactEmailVerificationDialog(authRepo: authRepo, token: token),
    );
  }

  @override
  State<WalletContactEmailVerificationDialog> createState() =>
      _WalletContactEmailVerificationDialogState();
}

class _WalletContactEmailVerificationDialogState
    extends State<WalletContactEmailVerificationDialog> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _sending = false;
  bool _verifying = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = l10n.emailRequired);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    final r = await widget.authRepo.sendContactEmailVerificationOtp(
      token: widget.token,
      email: email,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    r.fold(
      (f) => setState(() => _error = f.message),
      (_) {
        showAppSnackBar(
          context,
          message: AppLocalizations.of(context).otpSentToEmail,
          type: SnackBarType.success,
        );
      },
    );
  }

  Future<void> _verify() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailCtrl.text.trim();
    final otp = _otpCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = l10n.emailRequired);
      return;
    }
    if (otp.length != 6) {
      setState(() => _error = l10n.otpEnterCodeHint);
      return;
    }
    setState(() {
      _verifying = true;
      _error = null;
    });
    final r = await widget.authRepo.verifyContactEmail(
      token: widget.token,
      email: email,
      otpCode: otp,
    );
    if (!mounted) return;
    setState(() => _verifying = false);
    r.fold(
      (f) => setState(() => _error = f.message),
      (user) => Navigator.of(context).pop(user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.contactEmailVerifyDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.contactEmailVerifyDialogSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.profileChangeEmail,
                hintText: l10n.registerEmailHint,
                errorText: _error,
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: _sending ? null : _sendOtp,
              child: _sending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.contactEmailSendCode),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.otpVerificationTitle,
                hintText: l10n.otpEnterCodeHint,
                counterText: '',
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _verifying ? null : _verify,
          child: _verifying
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.contactEmailVerifySave),
        ),
      ],
    );
  }
}
