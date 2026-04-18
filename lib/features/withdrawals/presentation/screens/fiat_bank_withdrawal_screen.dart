import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

class FiatBankWithdrawalScreen extends StatelessWidget {
  const FiatBankWithdrawalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fiatWithdrawBankTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction_rounded, size: 64, color: scheme.primary),
              const SizedBox(height: 24),
              Text(
                'Tính năng đang được phát triển',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Chức năng rút tiền pháp định đang trong quá trình xây dựng và sẽ sớm ra mắt.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
