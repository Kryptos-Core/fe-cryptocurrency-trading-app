import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/domain/entities/currency.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/currencies_provider.dart';

/// Currency Detail Screen
/// Displays detailed information about a currency
class CurrencyDetailScreen extends StatefulWidget {
  final String currencyId;
  final Currency? initialCurrency;

  const CurrencyDetailScreen({
    super.key,
    required this.currencyId,
    this.initialCurrency,
  });

  @override
  State<CurrencyDetailScreen> createState() => _CurrencyDetailScreenState();
}

class _CurrencyDetailScreenState extends State<CurrencyDetailScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialCurrency == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CurrenciesProvider>().getCurrencyById(widget.currencyId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.currenciesDetailTitle),
      ),
      body: Consumer<CurrenciesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading &&
              provider.selectedCurrency == null &&
              widget.initialCurrency == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null &&
              provider.selectedCurrency == null &&
              widget.initialCurrency == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.getCurrencyById(widget.currencyId);
                    },
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          final currency = provider.selectedCurrency ?? widget.initialCurrency;
          if (currency == null) {
            return Center(child: Text(l10n.currenciesNotFound));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Center(
                          child: Text(
                            currency.symbol.substring(0, 1),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currency.symbol,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currency.name,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.currenciesMarketOverviewTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        l10n.lastPrice,
                        _formatPrice(currency.lastPrice, l10n),
                        Icons.price_change,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        l10n.change24h,
                        _formatChange(currency.priceChangePercent24h, l10n),
                        Icons.trending_up,
                        valueColor:
                            _changeColor(currency.priceChangePercent24h),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMetricCard(
                  l10n.volume24h,
                  _formatVolume(currency.volume24h, l10n),
                  Icons.bar_chart,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.currenciesConfigurationTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailCard(
                  l10n.currenciesSymbolLabel,
                  currency.symbol,
                  Icons.tag,
                ),
                _buildDetailCard(
                  l10n.currenciesNameLabel,
                  currency.name,
                  Icons.info,
                ),
                _buildDetailCard(
                  l10n.currenciesPrecisionScaleLabel,
                  '${currency.precisionScale}',
                  Icons.precision_manufacturing,
                ),
                _buildDetailCard(
                  l10n.currenciesMinWithdrawLabel,
                  '${currency.minWithdraw} ${currency.symbol}',
                  Icons.arrow_downward,
                ),
                _buildDetailCard(
                  l10n.status,
                  currency.isActive ? l10n.active : l10n.inactive,
                  currency.isActive ? Icons.check_circle : Icons.cancel,
                  color: currency.isActive ? Colors.green : Colors.red,
                ),
                _buildDetailCard(
                  l10n.currenciesTradable,
                  currency.isTradable ? l10n.currenciesYes : l10n.currenciesNo,
                  currency.isTradable ? Icons.check_circle : Icons.cancel,
                  color: currency.isTradable ? Colors.blue : Colors.grey,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey.shade700),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon,
      {Color? color}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
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

  String _formatChange(String? raw, AppLocalizations l10n) {
    final value = _parseDouble(raw);
    if (value == null) return l10n.na;
    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(2)}%';
  }

  Color _changeColor(String? raw) {
    final value = _parseDouble(raw);
    if (value == null) return Colors.grey.shade700;
    if (value > 0) return Colors.green;
    if (value < 0) return Colors.red;
    return Colors.grey.shade700;
  }

  double? _parseDouble(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return double.tryParse(value);
  }
}
