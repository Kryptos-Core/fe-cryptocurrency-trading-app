import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto_trading_app/data/repositories/auth_repository_impl.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';

/// Shared OTP verification dialog with resend cooldown.
/// Returns the 6-digit OTP string on verify, null on cancel.
class OtpVerificationDialog extends StatefulWidget {
  final AuthRepository repo;
  final String token;

  const OtpVerificationDialog({
    super.key,
    required this.repo,
    required this.token,
  });

  /// Shows the dialog and returns OTP string or null.
  static Future<String?> show(
    BuildContext context, {
    required AuthRepository repo,
    required String token,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => OtpVerificationDialog(repo: repo, token: token),
    );
  }

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  static const int _cooldownSeconds = 15;

  final _controller = TextEditingController();
  int _countdown = _cooldownSeconds;
  Timer? _timer;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = _cooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  Future<void> _resend() async {
    if (_isSending || _countdown > 0) return;
    setState(() => _isSending = true);
    final result = await widget.repo.send2faOtp(widget.token);
    if (!mounted) return;
    setState(() => _isSending = false);
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (_) => _startCountdown(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canResend = _countdown == 0 && !_isSending;

    return AlertDialog(
      title: Text(l10n.otpVerificationTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            maxLength: 6,
            autofocus: true,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: InputDecoration(
              hintText: l10n.otpEnterCodeHint,
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: canResend ? _resend : null,
            icon: _isSending
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, size: 16),
            label: Text(
              _countdown > 0 ? 'Gửi lại OTP (${_countdown}s)' : 'Gửi lại OTP',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _controller.text.trim().length == 6
              ? () => Navigator.pop(context, _controller.text.trim())
              : null,
          child: Text(l10n.otpVerify),
        ),
      ],
    );
  }
}
