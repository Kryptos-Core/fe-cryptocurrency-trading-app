import 'package:crypto_trading_app/features/markets/domain/entities/currency.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Currency Card Widget
/// Reusable widget to display currency information
class CurrencyCard extends StatelessWidget {
  final Currency currency;
  final VoidCallback? onTap;
  final bool showStatus;

  const CurrencyCard({
    super.key,
    required this.currency,
    this.onTap,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final changeValue = _parseDouble(currency.priceChangePercent24h);
    final changeColor = _changeColor(changeValue);
    final changeText = _formatChange(changeValue, l10n);

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
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        currency.symbol.substring(0, 1),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currency.symbol,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currency.name,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatPrice(currency.lastPrice, l10n),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: changeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          changeText,
                          style: TextStyle(
                            fontSize: 12,
                            color: changeColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _metricTile(
                      label: l10n.volume24h,
                      value: _formatVolume(currency.volume24h, l10n),
                    ),
                  ),
                  if (showStatus) ...[
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      l10n.active,
                      currency.isActive,
                      currency.isActive ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      l10n.currenciesTradable,
                      currency.isTradable,
                      currency.isTradable ? Colors.blue : Colors.grey,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricTile({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(String? raw, AppLocalizations l10n) {
    final value = _parseDouble(raw);
    if (value == null) return l10n.na;
    if (value >= 1000) return value.toStringAsFixed(2);
    if (value >= 1) return value.toStringAsFixed(4);
    return value.toStringAsFixed(6);
  }

  String _formatVolume(String? raw, AppLocalizations l10n) {
    final value = _parseDouble(raw);
    if (value == null) return l10n.na;
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(2)}B';
    }
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)}K';
    }
    return value.toStringAsFixed(2);
  }

  String _formatChange(double? value, AppLocalizations l10n) {
    if (value == null) return l10n.na;
    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(2)}%';
  }

  Color _changeColor(double? value) {
    if (value == null) return Colors.grey;
    if (value > 0) return Colors.green;
    if (value < 0) return Colors.red;
    return Colors.grey;
  }

  double? _parseDouble(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return double.tryParse(value);
  }

  Widget _buildStatusChip(String label, bool isActive, Color color) {
    final chipColor = isActive ? color : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 12,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
