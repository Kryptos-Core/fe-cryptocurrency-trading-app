import 'package:flutter/material.dart';

/// Empty list state aligned with treasury ops / history hints (icon + caption).
class TreasuryMainWalletsEmptyPlaceholder extends StatelessWidget {
  const TreasuryMainWalletsEmptyPlaceholder({
    super.key,
    required this.message,
    this.icon = Icons.account_balance_wallet_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: scheme.outline),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
