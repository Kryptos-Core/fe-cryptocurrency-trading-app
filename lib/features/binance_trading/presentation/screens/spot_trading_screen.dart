import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/core/utils/price_formatter.dart';
import '../../application/providers/binance_trading_provider.dart';
import '../../domain/entities/binance_trading_entities.dart';

class SpotTradingScreen extends StatefulWidget {
  final String credentialId;
  final String? label;

  const SpotTradingScreen({
    super.key,
    required this.credentialId,
    this.label,
  });

  @override
  State<SpotTradingScreen> createState() => _SpotTradingScreenState();
}

class _SpotTradingScreenState extends State<SpotTradingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _popularSymbols = [
    'BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'SOLUSDT',
    'XRPUSDT', 'DOGEUSDT', 'ADAUSDT', 'AVAXUSDT',
  ];

  String _selectedSymbol = 'BTCUSDT';
  String _orderSide = 'BUY';
  String _orderType = 'LIMIT';
  final _priceController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trading = context.read<BinanceTradingProvider>();
      trading.setCredentialId(widget.credentialId);
      trading.loadBalances();
      trading.loadOpenOrders(symbol: _selectedSymbol);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _priceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Spot Trading'),
            Text(
              widget.label ?? 'Binance',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<BinanceTradingProvider>().refreshAll(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSymbolSelector(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTradingPanel(),
                ),
                Expanded(
                  flex: 2,
                  child: _buildOrdersPanel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolSelector() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _popularSymbols.length,
        itemBuilder: (context, index) {
          final symbol = _popularSymbols[index];
          final isSelected = symbol == _selectedSymbol;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: ChoiceChip(
              label: Text(symbol),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedSymbol = symbol);
                context.read<BinanceTradingProvider>().setSelectedSymbol(symbol);
                context.read<BinanceTradingProvider>().loadOpenOrders(symbol: symbol);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTradingPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Consumer<BinanceTradingProvider>(
        builder: (context, trading, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBalanceCard(trading),
              const SizedBox(height: 12),
              _buildSideToggle(),
              const SizedBox(height: 12),
              _buildOrderTypeSelector(),
              const SizedBox(height: 12),
              _buildPriceInput(),
              const SizedBox(height: 12),
              _buildAmountInput(trading),
              const SizedBox(height: 12),
              _buildTotalRow(),
              const SizedBox(height: 16),
              _buildSubmitButton(trading),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(BinanceTradingProvider trading) {
    final balances = trading.balances;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Balances',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            if (trading.isLoading)
              const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
            else if (balances.isEmpty)
              Text(
                'No assets with balance',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              )
            else
              ...balances.take(5).map((b) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(b.asset, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${FormatUtils.formatDecimalAmountDisplay(b.free)} free',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildSideToggle() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _orderSide = 'BUY'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _orderSide == 'BUY'
                    ? Colors.green
                    : Colors.green.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                border: Border.all(
                  color: _orderSide == 'BUY' ? Colors.green : Colors.green.withValues(alpha: 0.3),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'BUY',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _orderSide == 'BUY' ? Colors.white : Colors.green,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _orderSide = 'SELL'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _orderSide == 'SELL'
                    ? Colors.red
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                border: Border.all(
                  color: _orderSide == 'SELL' ? Colors.red : Colors.red.withValues(alpha: 0.3),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'SELL',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _orderSide == 'SELL' ? Colors.white : Colors.red,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTypeSelector() {
    return Row(
      children: ['LIMIT', 'MARKET'].map((type) {
        final isSelected = type == _orderType;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _orderType = type),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                type,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceInput() {
    if (_orderType == 'MARKET') return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price (${_selectedSymbol.replaceAll('USDT', '')})',
            style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        TextField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '0.00',
            suffixText: 'USDT',
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput(BinanceTradingProvider trading) {
    final baseAsset = _selectedSymbol.replaceAll('USDT', '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amount ($baseAsset)',
            style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: '0.00',
            suffixText: baseAsset,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [25, 50, 75, 100].map((pct) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  final balance = _getRelevantBalance(trading.balances, _orderSide);
                  if (balance == 0) return;
                  final amount = (balance * pct / 100);
                  _amountController.text = FormatUtils.formatDecimalAmountDisplay(
                    amount.toString(),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text('$pct%', style: const TextStyle(fontSize: 12)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  double _getRelevantBalance(List<BinanceSpotBalance> balances, String side) {
    if (side == 'BUY') {
      final usdt = balances.where((b) => b.asset == 'USDT').firstOrNull;
      return double.tryParse(usdt?.free ?? '0') ?? 0;
    } else {
      final base = _selectedSymbol.replaceAll('USDT', '');
      final asset = balances.where((b) => b.asset == base).firstOrNull;
      return double.tryParse(asset?.free ?? '0') ?? 0;
    }
  }

  Widget _buildTotalRow() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final amount = double.tryParse(_amountController.text) ?? 0;
    final total = price * amount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total', style: Theme.of(context).textTheme.labelLarge),
          Text(
            '${FormatUtils.formatQuoteAmount(total)} USDT',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BinanceTradingProvider trading) {
    final buttonColor = _orderSide == 'BUY' ? Colors.green : Colors.red;
    final label = '$_orderSide ${_selectedSymbol.replaceAll('USDT', '')}';

    return FilledButton(
      onPressed: trading.isPlacing ? null : () => _placeOrder(trading),
      style: FilledButton.styleFrom(
        backgroundColor: buttonColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: trading.isPlacing
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Future<void> _placeOrder(BinanceTradingProvider trading) async {
    final amount = _amountController.text.trim();
    if (amount.isEmpty || (double.tryParse(amount) ?? 0) <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    if (_orderType == 'LIMIT') {
      final price = _priceController.text.trim();
      if (price.isEmpty || (double.tryParse(price) ?? 0) <= 0) {
        _showError('Please enter a valid price');
        return;
      }
    }

    final result = await trading.placeSpotOrder(
      symbol: _selectedSymbol,
      side: _orderSide,
      type: _orderType,
      quantity: amount,
      price: _orderType == 'MARKET' ? null : _priceController.text.trim(),
      timeInForce: 'GTC',
    );

    if (!mounted) return;

    if (result.success) {
      _amountController.clear();
      _priceController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showError(result.error ?? 'Order failed');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildOrdersPanel() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Open Orders'),
            Tab(text: 'History'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOpenOrdersTab(),
              _buildOrderHistoryTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOpenOrdersTab() {
    return Consumer<BinanceTradingProvider>(
      builder: (context, trading, _) {
        if (trading.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (trading.openOrders.isEmpty) {
          return Center(
            child: Text(
              'No open orders',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: trading.openOrders.length,
          itemBuilder: (context, index) {
            final order = trading.openOrders[index];
            return _OrderTile(
              order: order,
              onCancel: () => _cancelOrder(trading, order),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderHistoryTab() {
    return Consumer<BinanceTradingProvider>(
      builder: (context, trading, _) {
        return TextButton(
          onPressed: () {
            trading.loadOrderHistory(symbol: _selectedSymbol, limit: 50);
          },
          child: const Text('Load History'),
        );
      },
    );
  }

  Future<void> _cancelOrder(BinanceTradingProvider trading, BinanceSpotOrder order) async {
    await trading.cancelSpotOrder(symbol: order.symbol, orderId: order.orderId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order cancelled'), backgroundColor: Colors.orange),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final BinanceSpotOrder order;
  final VoidCallback onCancel;

  const _OrderTile({required this.order, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final isBuy = order.side == 'BUY';
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        order.symbol,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: isBuy ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          order.side,
                          style: TextStyle(fontSize: 10, color: isBuy ? Colors.green : Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${order.type} ${order.origQty}/${order.executedQty}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  PriceFormatter.formatPriceStr(order.price),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                    child: Text('Cancel', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.error)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
