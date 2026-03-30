import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/domain/entities/wallet.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';

/// Wallet Card Widget
/// Displays wallet balance information
class WalletCard extends StatelessWidget {
  final Wallet wallet;
  final double? usdValue;
  final VoidCallback? onTap;

  const WalletCard({
    super.key,
    required this.wallet,
    this.usdValue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = wallet.currency.precisionScale;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        mouseCursor:
            onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Currency Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        wallet.currency.symbol.substring(0, 1),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Currency Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wallet.currency.symbol,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          wallet.currency.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Balances
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBalanceColumn(
                    AppLocalizations.of(context).walletAvailable,
                    wallet.available,
                    scale,
                    wallet.currency.symbol,
                  ),
                  _buildBalanceColumn(
                    AppLocalizations.of(context).walletFrozen,
                    wallet.frozen,
                    scale,
                    wallet.currency.symbol,
                  ),
                  _buildBalanceColumn(
                    AppLocalizations.of(context).walletTotal,
                    wallet.total,
                    scale,
                    wallet.currency.symbol,
                  ),
                ],
              ),
              // USD Value
              if (usdValue != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).walletUsdValue,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        FormatUtils.formatUsdValue(usdValue!),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceColumn(
    String label,
    String amountStr,
    int precisionScale,
    String symbol,
  ) {
    final formatted = FormatUtils.formatDecimalAmountForScale(
      amountStr,
      precisionScale,
    );
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$formatted $symbol',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
