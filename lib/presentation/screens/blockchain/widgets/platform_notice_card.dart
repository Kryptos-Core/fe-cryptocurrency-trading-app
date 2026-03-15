import 'package:flutter/material.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';

class PlatformNoticeCard extends StatelessWidget {
  final bool isWebDialog;

  const PlatformNoticeCard({
    super.key,
    required this.isWebDialog,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (isWebDialog) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          border: Border.all(color: Colors.green.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.language_outlined,
              size: 18,
              color: Colors.green.shade700,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.webModeNotice,
                style: const TextStyle(fontSize: 12.5),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        border: Border.all(color: Colors.indigo.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.devices_outlined,
            size: 18,
            color: Colors.indigo.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.appModeNotice,
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}
