import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/presentation/providers/wallets_provider.dart';
import 'package:crypto_trading_app/domain/entities/wallet_transaction.dart';
import 'package:crypto_trading_app/screens/wallet_debug_screen.dart';
import 'package:crypto_trading_app/data/datasources/currencies_remote_datasource.dart';
import 'package:crypto_trading_app/data/models/currency_model.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';

/// Wallet API Screen - Hiển thị wallet balance từ API thật
class WalletApiScreen extends StatefulWidget {
  const WalletApiScreen({super.key});

  @override
  State<WalletApiScreen> createState() => _WalletApiScreenState();
}

class _WalletApiScreenState extends State<WalletApiScreen> {
  int? _selectedCurrencyId;
  List<CurrencyModel> _currencies = [];
  bool _isLoadingCurrencies = true;
  String? _currenciesError;

  final CurrenciesRemoteDataSource _currenciesDataSource =
      sl<CurrenciesRemoteDataSource>();

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    try {
      setState(() {
        _isLoadingCurrencies = true;
        _currenciesError = null;
      });

      final currencies = await _currenciesDataSource.getActiveCurrencies();

      setState(() {
        _currencies = currencies;
        _isLoadingCurrencies = false;

        // Select first currency (usually BTC) by default
        if (_currencies.isNotEmpty && _selectedCurrencyId == null) {
          _selectedCurrencyId = _currencies.first.currencyId;
          // Fetch balance after selecting currency
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fetchBalance();
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingCurrencies = false;
        _currenciesError = e.toString();
      });
      print('[WalletApiScreen] Error loading currencies: $e');
    }
  }

  void _fetchBalance() {
    if (_selectedCurrencyId != null && _currencies.isNotEmpty) {
      final selectedCurrency = _currencies.firstWhere(
        (c) => c.currencyId == _selectedCurrencyId,
        orElse: () => _currencies.first,
      );
      print(
          '[WalletApiScreen] Fetching balance for ${selectedCurrency.symbol} (currencyId: $_selectedCurrencyId)');

      context.read<WalletsProvider>().fetchWalletBalance(
            _selectedCurrencyId!,
            forceRefresh: true,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadCurrencies();
              _fetchBalance();
            },
          ),
        ],
      ),
      body: Consumer<WalletsProvider>(
        builder: (context, provider, child) {
          // Loading currencies state
          if (_isLoadingCurrencies) {
            return const Center(child: CircularProgressIndicator());
          }

          // Currency loading error
          if (_currenciesError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currenciesError!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCurrencies,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // No currencies
          if (_currencies.isEmpty) {
            return const Center(
              child: Text('No active currencies found'),
            );
          }

          return Column(
            children: [
              // Currency Selector
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<int>(
                  value: _selectedCurrencyId,
                  decoration: InputDecoration(
                    labelText: 'Select Currency',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.currency_bitcoin),
                  ),
                  items: _currencies.map((currency) {
                    return DropdownMenuItem<int>(
                      value: currency.currencyId,
                      child: Text('${currency.symbol} (${currency.name})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrencyId = value;
                    });
                    _fetchBalance();
                  },
                ),
              ),

              // Balance content
              Expanded(
                child: _buildBalanceContent(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBalanceContent(WalletsProvider provider) {
    // Loading balance
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Balance error
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              provider.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchBalance,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Balance data
    if (provider.walletBalance != null) {
      return RefreshIndicator(
        onRefresh: () async {
          _fetchBalance();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Summary Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBalanceRow(
                        'Available',
                        provider.walletBalance!.available,
                        Colors.green,
                        Icons.account_balance_wallet,
                      ),
                      const Divider(height: 32),
                      _buildBalanceRow(
                        'Frozen',
                        provider.walletBalance!.frozen,
                        Colors.orange,
                        Icons.lock,
                      ),
                      const Divider(height: 32),
                      _buildBalanceRow(
                        'Total',
                        provider.walletBalance!.total,
                        Colors.blue,
                        Icons.account_balance,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              const Text(
                'Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildActionButton(
                    'Deposit',
                    Icons.add_circle,
                    Colors.green,
                    () => _showDepositDialog(),
                  ),
                  _buildActionButton(
                    'Withdraw',
                    Icons.remove_circle,
                    Colors.red,
                    () => _showWithdrawDialog(),
                  ),
                  _buildActionButton(
                    'Transfer',
                    Icons.send,
                    Colors.blue,
                    () => _showTransferDialog(),
                  ),
                ],
              ),

              // Last Transaction
              if (provider.lastTransaction != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'Last Transaction',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: Icon(
                      _getActionIcon(provider.lastTransaction!.action),
                      color: _getActionColor(provider.lastTransaction!.action),
                    ),
                    title: Text(
                      provider.lastTransaction!.action.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Amount: ${provider.lastTransaction!.amount}',
                    ),
                    trailing: Text(
                      provider.lastTransaction!.timestamp
                          .toString()
                          .substring(0, 19),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBalanceRow(
      String label, String amount, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }

  IconData _getActionIcon(WalletTransactionAction action) {
    switch (action) {
      case WalletTransactionAction.credit:
        return Icons.add_circle;
      case WalletTransactionAction.debit:
        return Icons.remove_circle;
      case WalletTransactionAction.freeze:
        return Icons.lock;
      case WalletTransactionAction.unfreeze:
        return Icons.lock_open;
      case WalletTransactionAction.transfer:
        return Icons.send;
    }
  }

  Color _getActionColor(WalletTransactionAction action) {
    switch (action) {
      case WalletTransactionAction.credit:
        return Colors.green;
      case WalletTransactionAction.debit:
        return Colors.red;
      case WalletTransactionAction.freeze:
        return Colors.orange;
      case WalletTransactionAction.unfreeze:
        return Colors.blue;
      case WalletTransactionAction.transfer:
        return Colors.purple;
    }
  }

  void _showDepositDialog() {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deposit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: '0.00',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<WalletsProvider>();
              final success = await provider.deposit(
                currencyId: _selectedCurrencyId!,
                amount: amountController.text,
                refId: DateTime.now().millisecondsSinceEpoch,
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deposit successful!')),
                );
                _fetchBalance();
              }
            },
            child: const Text('Deposit'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: '0.00',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<WalletsProvider>();
              final success = await provider.withdraw(
                currencyId: _selectedCurrencyId!,
                amount: amountController.text,
                refId: DateTime.now().millisecondsSinceEpoch,
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Withdraw successful!')),
                );
                _fetchBalance();
              }
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog() {
    final amountController = TextEditingController();
    final toUserIdController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: toUserIdController,
              decoration: const InputDecoration(
                labelText: 'To User ID',
                hintText: '1',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: '0.00',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<WalletsProvider>();
              final success = await provider.transfer(
                currencyId: _selectedCurrencyId!,
                amount: amountController.text,
                toUserId: int.parse(toUserIdController.text),
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transfer successful!')),
                );
                _fetchBalance();
              }
            },
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
  }
}
