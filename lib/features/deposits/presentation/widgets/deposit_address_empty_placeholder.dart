import 'package:crypto_trading_app/core/utils/blockchain_public_error_localization.dart';
import 'package:flutter/material.dart';

/// Inline empty state for the platform deposit address block — avoids harsh raw red text.
class DepositAddressEmptyPlaceholder extends StatelessWidget {
  final String message;
  final DepositAddressEmptyKind kind;

  const DepositAddressEmptyPlaceholder({
    super.key,
    required this.message,
    required this.kind,
  });

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case DepositAddressEmptyKind.generic:
        return Text(
          message,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
          ),
        );
      case DepositAddressEmptyKind.configurationUnavailable:
        return _SoftCallout(
          icon: Icons.info_outline_rounded,
          message: message,
          background: const Color(0xFFEFF6FF),
          borderColor: const Color(0xFFBFDBFE),
          iconColor: const Color(0xFF2563EB),
          textColor: const Color(0xFF1E3A5F),
        );
      case DepositAddressEmptyKind.error:
        return _SoftCallout(
          icon: Icons.error_outline_rounded,
          message: message,
          background: const Color(0xFFFEF2F2),
          borderColor: const Color(0xFFFECACA),
          iconColor: const Color(0xFFDC2626),
          textColor: const Color(0xFF7F1D1D),
        );
    }
  }
}

class _SoftCallout extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color background;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;

  const _SoftCallout({
    required this.icon,
    required this.message,
    required this.background,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
