import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/domain/entities/order.dart';
import 'package:crypto_trading_app/domain/entities/order_book_level.dart';
import 'package:crypto_trading_app/domain/repositories/orders_repository.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
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
  final _pairIdController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().fetchMyOrders(refresh: true);
    });
  }

  @override
  void dispose() {
    _pairIdController.dispose();
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
              _buildOrderBookSection(context),
              const SizedBox(height: 24),
              _buildMyOrdersSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderBookSection(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Book',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _pairIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Pair ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: provider.isLoading
                      ? null
                      : () {
                          final pairId =
                              int.tryParse(_pairIdController.text) ?? 1;
                          provider.fetchOrderBook(pairId);
                        },
                  child: const Text('Load'),
                ),
              ],
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
                      title: 'Bids',
                      levels: provider.orderBookBids,
                      isBid: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _OrderBookTable(
                      title: 'Asks',
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
          'No orders yet',
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
