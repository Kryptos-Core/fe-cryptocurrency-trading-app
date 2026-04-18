import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

/// Tích xanh dưới avatar — người đã xác minh email qua OTP (BE: `email_verified`).
/// Khách (chưa đăng nhập) không dùng widget này.
class UserEmailVerifiedMark extends StatelessWidget {
  final bool verified;

  const UserEmailVerifiedMark({super.key, required this.verified});

  @override
  Widget build(BuildContext context) {
    if (!verified) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final green = Colors.green.shade700;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Tooltip(
        message: l10n.profileEmailVerifiedTooltip,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.verified,
              size: 22,
              color: green,
              semanticLabel: l10n.profileEmailVerifiedTooltip,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.profileEmailVerifiedLabel,
              style: (Theme.of(context).textTheme.labelLarge ??
                      const TextStyle(fontSize: 14))
                  .copyWith(
                color: green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
