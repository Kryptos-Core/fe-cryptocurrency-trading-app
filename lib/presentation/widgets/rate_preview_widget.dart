import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/domain/entities/exchange_rate_preview.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';

class RatePreviewWidget extends StatelessWidget {
  final ExchangeRatePreview? preview;
  final bool isLoading;

  const RatePreviewWidget({
    super.key,
    required this.preview,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(),
      );
    }

    if (preview == null) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final priceVnd = _formatPriceVnd(preview!.marketRate);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.payosDepositRatePreviewTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.payosDepositRateOneUsdt(priceVnd),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            l10n.payosDepositSpreadBps(preview!.spreadBps),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.payosDepositYouReceive(
              FormatUtils.formatDecimalAmountDisplay(preview!.netAmount),
              preview!.quoteCurrency,
            ),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  String _formatPriceVnd(String marketRate) {
    final rate = double.tryParse(marketRate);
    if (rate == null || rate <= 0) {
      return '--';
    }

    final vnd = 1 / rate;
    return NumberFormat('#,###').format(vnd);
  }
}
