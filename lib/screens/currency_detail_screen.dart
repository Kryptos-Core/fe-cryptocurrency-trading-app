import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/presentation/providers/currencies_provider.dart';

/// Currency Detail Screen
/// Displays detailed information about a currency
class CurrencyDetailScreen extends StatefulWidget {
  final String currencyId;

  const CurrencyDetailScreen({
    super.key,
    required this.currencyId,
  });

  @override
  State<CurrencyDetailScreen> createState() => _CurrencyDetailScreenState();
}

class _CurrencyDetailScreenState extends State<CurrencyDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrenciesProvider>().getCurrencyById(widget.currencyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Details'),
      ),
      body: Consumer<CurrenciesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.selectedCurrency == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.selectedCurrency == null) {
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
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final currency = provider.selectedCurrency;
          if (currency == null) {
            return const Center(child: Text('Currency not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Currency Header
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
                // Currency Details
                _buildDetailCard(
                  'Symbol',
                  currency.symbol,
                  Icons.tag,
                ),
                _buildDetailCard(
                  'Name',
                  currency.name,
                  Icons.info,
                ),
                _buildDetailCard(
                  'Precision Scale',
                  '${currency.precisionScale} decimal places',
                  Icons.precision_manufacturing,
                ),
                _buildDetailCard(
                  'Min Withdraw',
                  '${currency.minWithdraw} ${currency.symbol}',
                  Icons.arrow_downward,
                ),
                _buildDetailCard(
                  'Status',
                  currency.isActive ? 'Active' : 'Inactive',
                  currency.isActive ? Icons.check_circle : Icons.cancel,
                  color: currency.isActive ? Colors.green : Colors.red,
                ),
                _buildDetailCard(
                  'Tradable',
                  currency.isTradable ? 'Yes' : 'No',
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

  Widget _buildDetailCard(String label, String value, IconData icon, {Color? color}) {
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
}
