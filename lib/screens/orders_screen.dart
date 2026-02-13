import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/domain/entities/order.dart';
import 'package:crypto_trading_app/domain/entities/order_book_level.dart';
import 'package:crypto_trading_app/domain/repositories/orders_repository.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/presentation/providers/orders_provider.dart';

/// Màn hình Orders: Danh sách lệnh của user + Order book (theo pair).
///
/// Sử dụng OrdersProvider (CreateOrder, CancelOrder, GetOrderBook, GetMyOrders).
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _priceController = TextEditingController();
  final _amountController = TextEditingController();
  String _side = 'BUY';
  String _orderType = 'LIMIT';
  MarketPair? _selectedMarket;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().fetchMyOrders(refresh: true);
      context.read<MarketsProvider>().fetchActiveMarkets();
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orders),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OrdersProvider>().fetchMyOrders(refresh: true);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<OrdersProvider>().fetchMyOrders(refresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPlaceOrderSection(context),
              const SizedBox(height: 24),
              _buildOrderBookSection(context),
              const SizedBox(height: 24),
              _buildMyOrdersSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceOrderSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ordersProvider = context.watch<OrdersProvider>();
    final marketsProvider = context.watch<MarketsProvider>();
    final theme = Theme.of(context);
    final markets = marketsProvider.markets;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.placeOrder,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MarketPair>(
              value: _selectedMarket,
              decoration: InputDecoration(
                labelText: l10n.tradingPair,
                border: const OutlineInputBorder(),
              ),
              hint: Text(markets.isEmpty ? l10n.loading : l10n.tradingPair),
              items: markets
                  .map((m) => DropdownMenuItem<MarketPair>(
                        value: m,
                        child: Text(_formatSymbol(m.symbol)),
                      ))
                  .toList(),
              onChanged: markets.isEmpty
                  ? null
                  : (MarketPair? v) => setState(() => _selectedMarket = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'BUY', label: Text(l10n.buy), icon: Icon(Icons.arrow_upward, size: 18, color: Colors.green.shade700)),
                      ButtonSegment(value: 'SELL', label: Text(l10n.sell), icon: Icon(Icons.arrow_downward, size: 18, color: Colors.red.shade700)),
                    ],
                    selected: {_side},
                    onSelectionChanged: (Set<String> s) => setState(() => _side = s.first),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('${l10n.orderType}: ', style: theme.textTheme.bodyMedium),
                Expanded(
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'LIMIT', label: Text(l10n.limitOrder)),
                      ButtonSegment(value: 'MARKET', label: Text(l10n.marketOrder)),
                    ],
                    selected: {_orderType},
                    onSelectionChanged: (Set<String> s) => setState(() => _orderType = s.first),
                  ),
                ),
              ],
            ),
            if (_orderType == 'LIMIT') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.price,
                  border: const OutlineInputBorder(),
                  hintText: 'e.g. 50000.00',
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.amount,
                border: const OutlineInputBorder(),
                hintText: 'e.g. 0.01',
              ),
            ),
            if (ordersProvider.error != null) ...[
              const SizedBox(height: 8),
              Text(
                ordersProvider.error!,
                style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: ordersProvider.isLoading ? null : () => _submitOrder(context),
              icon: ordersProvider.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
              label: Text(l10n.placeOrder),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatSymbol(String symbol) {
    if (symbol.contains('/')) return symbol;
    if (symbol.length >= 6 && symbol.endsWith('USDT')) {
      return '${symbol.substring(0, symbol.length - 4)}/USDT';
    }
    return symbol;
  }

  Future<void> _submitOrder(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<OrdersProvider>();
    if (_selectedMarket == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.tradingPair} ${l10n.retry}')));
      return;
    }
    final pairId = _selectedMarket!.pairId;
    final amount = _amountController.text.trim();
    if (amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.amount} required')));
      return;
    }
    if (_orderType == 'LIMIT') {
      final price = _priceController.text.trim();
      if (price.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.price} required for Limit order')));
        return;
      }
    }
    final idempotencyKey = '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(0x7FFFFFFF)}';
    final request = CreateOrderRequest(
      pairId: pairId,
      side: _side,
      type: _orderType,
      price: _orderType == 'LIMIT' ? _priceController.text.trim() : null,
      amount: amount,
      idempotencyKey: idempotencyKey,
    );
    final order = await provider.createOrder(request);
    if (!context.mounted) return;
    if (order != null) {
      provider.clearError();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.orderPlacedSuccess)));
      _amountController.clear();
      if (_orderType == 'LIMIT') _priceController.clear();
      provider.fetchOrderBook(pairId);
      provider.fetchMyOrders(refresh: true);
    }
  }

  Widget _buildOrderBookSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<OrdersProvider>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.orderBook,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_selectedMarket != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    ' (${_formatSymbol(_selectedMarket!.symbol)})',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: provider.isLoading || _selectedMarket == null
                  ? null
                  : () => provider.fetchOrderBook(_selectedMarket!.pairId),
              child: Text(l10n.refresh),
            ),
            if (_selectedMarket == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.tradingPair,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ),
            if (provider.error != null) ...[
              const SizedBox(height: 8),
              Text(
                provider.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (provider.orderBookBids.isNotEmpty ||
                provider.orderBookAsks.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _OrderBookTable(
                      title: AppLocalizations.of(context)!.bidsBuy,
                      levels: provider.orderBookBids,
                      isBid: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _OrderBookTable(
                      title: AppLocalizations.of(context)!.asksSell,
                      levels: provider.orderBookAsks,
                      isBid: false,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMyOrdersSection(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    if (provider.error != null && provider.myOrders.isEmpty) {
      return Center(
        child: Column(
          children: [
            Text(provider.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => provider.fetchMyOrders(refresh: true),
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }
    if (provider.isLoading && provider.myOrders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.myOrders.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.orderBookEmpty,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Orders (${provider.myOrdersTotal})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () => provider.fetchMyOrders(refresh: true),
                  child: Text(AppLocalizations.of(context)!.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.myOrders.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final order = provider.myOrders[index];
                return _OrderListTile(
                  order: order,
                  onCancel: () async {
                    final p = context.read<OrdersProvider>();
                    await p.cancelOrder(order.orderId);
                    if (context.mounted) p.fetchMyOrders(refresh: true);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderBookTable extends StatelessWidget {
  final String title;
  final List<OrderBookLevel> levels;
  final bool isBid;

  const _OrderBookTable({
    required this.title,
    required this.levels,
    required this.isBid,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              children: [
                _cell('Price', isHeader: true),
                _cell('Size', isHeader: true),
                _cell('Count', isHeader: true),
              ],
            ),
            ...levels.take(10).map((l) => TableRow(
                  children: [
                    _cell(l.price, isBid: isBid),
                    _cell(l.remaining),
                    _cell('${l.orderCount}'),
                  ],
                )),
          ],
        ),
      ],
    );
  }

  Widget _cell(String text, {bool isHeader = false, bool? isBid}) {
    Color? color;
    if (isBid == true) color = Colors.green.shade700;
    if (isBid == false) color = Colors.red.shade700;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : null,
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _OrderListTile extends StatelessWidget {
  final Order order;
  final VoidCallback onCancel;

  const _OrderListTile({required this.order, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        '${order.side.value} ${order.type.value}',
        style: TextStyle(
          color: order.side == OrderSide.buy ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
      subtitle: Text(
        'Price: ${order.price ?? "MKT"} | Amount: ${order.amount} | Filled: ${order.filledAmount} | ${order.status.value}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: order.isCancellable
          ? TextButton(
              onPressed: onCancel,
              child: Text(AppLocalizations.of(context)!.cancel),
            )
          : null,
    );
  }
}
