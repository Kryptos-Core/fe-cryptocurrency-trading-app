import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/presentation/providers/admin_transactions_provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() =>
      _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<AdminTransactionsProvider>();
      p.fetchOrders(refresh: true);
      p.fetchDeposits(refresh: true);
      p.fetchWithdrawals(refresh: true);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.drawerTransactionMonitoring),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(icon: const Icon(Icons.list_alt_outlined), text: l10n.adminTabOrders),
            Tab(icon: const Icon(Icons.arrow_downward), text: l10n.adminTabDeposits),
            Tab(icon: const Icon(Icons.arrow_upward), text: l10n.adminTabWithdrawals),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _OrdersTab(),
          _DepositsTab(),
          _WithdrawalsTab(),
        ],
      ),
    );
  }
}

// ── Orders Tab ────────────────────────────────────────────────────────────────

class _OrdersTab extends StatefulWidget {
  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _scroll = ScrollController();
  final _userController = TextEditingController();
  Timer? _debounce;

  String? _selectedStatus;

  static List<(String, String?)> _orderStatuses(AppLocalizations l10n) => [
    (l10n.adminFilterAll, null),
    (l10n.orderStatusOpen, 'OPEN'),
    (l10n.orderStatusPartial, 'PARTIAL'),
    (l10n.orderStatusFilled, 'FILLED'),
    (l10n.orderStatusCancelled, 'CANCELLED'),
    (l10n.orderStatusRejected, 'REJECTED'),
  ];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >=
          _scroll.position.maxScrollExtent - 200) {
        context.read<AdminTransactionsProvider>().loadMoreOrders();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _userController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onUserSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context
          .read<AdminTransactionsProvider>()
          .applyOrderFilters(userId: v.trim(), status: _selectedStatus);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        _buildFilterBar(),
        const Divider(height: 1),
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        children: [
          TextField(
            controller: _userController,
            onChanged: _onUserSearch,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).filterByUserId,
              prefixIcon: const Icon(Icons.person_search_outlined),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              suffixIcon: _userController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _userController.clear();
                        context
                            .read<AdminTransactionsProvider>()
                            .applyOrderFilters(status: _selectedStatus);
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _orderStatuses(AppLocalizations.of(context)).map((s) {
                final sel = _selectedStatus == s.$2;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(s.$1),
                    selected: sel,
                    visualDensity: VisualDensity.compact,
                    onSelected: (_) {
                      setState(() => _selectedStatus = s.$2);
                      context.read<AdminTransactionsProvider>().applyOrderFilters(
                            userId: _userController.text.trim(),
                            status: s.$2,
                          );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Consumer<AdminTransactionsProvider>(
      builder: (_, p, __) {
        if (p.isLoadingOrders && p.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (p.ordersError != null && p.orders.isEmpty) {
          return _ErrorPanel(
            message: p.ordersError!,
            onRetry: () =>
                p.fetchOrders(refresh: true),
          );
        }
        if (p.orders.isEmpty) {
          return _EmptyPanel(
              message: AppLocalizations.of(context).adminOrdersEmpty);
        }

        final l10n = AppLocalizations.of(context);
        return Column(
          children: [
            _CountBanner(
                l10n: l10n,
                total: p.ordersTotal,
                shown: p.orders.length,
                label: l10n.adminOrdersCountLabel),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => p.fetchOrders(refresh: true),
                child: ListView.separated(
                  controller: _scroll,
                  itemCount: p.orders.length + (p.ordersHasMore ? 1 : 0),
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    if (i >= p.orders.length) {
                      return const _LoadMoreIndicator();
                    }
                    return _OrderTile(
                        order: p.orders[i],
                        l10n: AppLocalizations.of(context));
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Deposits Tab ──────────────────────────────────────────────────────────────

class _DepositsTab extends StatefulWidget {
  @override
  State<_DepositsTab> createState() => _DepositsTabState();
}

class _DepositsTabState extends State<_DepositsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _scroll = ScrollController();
  final _userController = TextEditingController();
  Timer? _debounce;
  String? _selectedStatus;

  static List<(String, String?)> _depositStatuses(AppLocalizations l10n) => [
    (l10n.adminFilterAll, null),
    (l10n.depositStatusPending, 'PENDING'),
    (l10n.depositStatusPaid, 'PAID'),
    (l10n.depositStatusCancelled, 'CANCELLED'),
  ];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >=
          _scroll.position.maxScrollExtent - 200) {
        context.read<AdminTransactionsProvider>().loadMoreDeposits();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _userController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onUserSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context
          .read<AdminTransactionsProvider>()
          .applyDepositFilters(userId: v.trim(), status: _selectedStatus);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Column(
            children: [
              TextField(
                controller: _userController,
                onChanged: _onUserSearch,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).filterByUserId,
                  prefixIcon: const Icon(Icons.person_search_outlined),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _depositStatuses(AppLocalizations.of(context)).map((s) {
                    final sel = _selectedStatus == s.$2;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(s.$1),
                        selected: sel,
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) {
                          setState(() => _selectedStatus = s.$2);
                          context
                              .read<AdminTransactionsProvider>()
                              .applyDepositFilters(
                                userId: _userController.text.trim(),
                                status: s.$2,
                              );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Consumer<AdminTransactionsProvider>(
            builder: (_, p, __) {
              if (p.isLoadingDeposits && p.deposits.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (p.depositsError != null && p.deposits.isEmpty) {
                return _ErrorPanel(
                  message: p.depositsError!,
                  onRetry: () => p.fetchDeposits(refresh: true),
                );
              }
              if (p.deposits.isEmpty) {
                return _EmptyPanel(
                    message: AppLocalizations.of(context).adminDepositsEmpty);
              }
              final l10n = AppLocalizations.of(context);
              return Column(
                children: [
                  _CountBanner(
                      l10n: l10n,
                      total: p.depositsTotal,
                      shown: p.deposits.length,
                      label: l10n.adminDepositsCountLabel),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => p.fetchDeposits(refresh: true),
                      child: ListView.separated(
                        controller: _scroll,
                        itemCount: p.deposits.length +
                            (p.depositsHasMore ? 1 : 0),
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1),
                        itemBuilder: (_, i) {
                          if (i >= p.deposits.length) {
                            return const _LoadMoreIndicator();
                          }
                          return _DepositTile(
                              deposit: p.deposits[i],
                              l10n: AppLocalizations.of(context));
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Withdrawals Tab ───────────────────────────────────────────────────────────

class _WithdrawalsTab extends StatefulWidget {
  @override
  State<_WithdrawalsTab> createState() => _WithdrawalsTabState();
}

class _WithdrawalsTabState extends State<_WithdrawalsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _scroll = ScrollController();
  final _userController = TextEditingController();
  Timer? _debounce;
  String? _selectedStatus;

  static List<(String, String?)> _withdrawalStatuses(AppLocalizations l10n) => [
    (l10n.adminFilterAll, null),
    (l10n.withdrawalStatusPending, 'PENDING'),
    (l10n.withdrawalStatusConfirming, 'CONFIRMING'),
    (l10n.withdrawalStatusCompleted, 'COMPLETED'),
    (l10n.withdrawalStatusFailed, 'FAILED'),
  ];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >=
          _scroll.position.maxScrollExtent - 200) {
        context.read<AdminTransactionsProvider>().loadMoreWithdrawals();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _userController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onUserSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context
          .read<AdminTransactionsProvider>()
          .applyWithdrawalFilters(userId: v.trim(), status: _selectedStatus);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Column(
            children: [
              TextField(
                controller: _userController,
                onChanged: _onUserSearch,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).filterByUserId,
                  prefixIcon: const Icon(Icons.person_search_outlined),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _withdrawalStatuses(AppLocalizations.of(context)).map((s) {
                    final sel = _selectedStatus == s.$2;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(s.$1),
                        selected: sel,
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) {
                          setState(() => _selectedStatus = s.$2);
                          context
                              .read<AdminTransactionsProvider>()
                              .applyWithdrawalFilters(
                                userId: _userController.text.trim(),
                                status: s.$2,
                              );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Consumer<AdminTransactionsProvider>(
            builder: (_, p, __) {
              if (p.isLoadingWithdrawals && p.withdrawals.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (p.withdrawalsError != null && p.withdrawals.isEmpty) {
                return _ErrorPanel(
                  message: p.withdrawalsError!,
                  onRetry: () => p.fetchWithdrawals(refresh: true),
                );
              }
              if (p.withdrawals.isEmpty) {
                return _EmptyPanel(
                    message: AppLocalizations.of(context).adminWithdrawalsEmpty);
              }
              final l10n = AppLocalizations.of(context);
              return Column(
                children: [
                  _CountBanner(
                      l10n: l10n,
                      total: p.withdrawalsTotal,
                      shown: p.withdrawals.length,
                      label: l10n.adminWithdrawalsCountLabel),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => p.fetchWithdrawals(refresh: true),
                      child: ListView.separated(
                        controller: _scroll,
                        itemCount: p.withdrawals.length +
                            (p.withdrawalsHasMore ? 1 : 0),
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1),
                        itemBuilder: (_, i) {
                          if (i >= p.withdrawals.length) {
                            return const _LoadMoreIndicator();
                          }
                          return _WithdrawalTile(
                              tx: p.withdrawals[i],
                              l10n: AppLocalizations.of(context));
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Tile Widgets ──────────────────────────────────────────────────────────────

class _OrderTile extends StatelessWidget {
  final Map<String, dynamic> order;
  final AppLocalizations l10n;
  const _OrderTile({required this.order, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final side = order['side']?.toString() ?? '';
    final isBuy = side == 'BUY';
    final sideColor = isBuy ? Colors.green : Colors.red;
    final status = order['status']?.toString() ?? '';
    final amount = order['amount']?.toString() ?? '0';
    final price = order['price']?.toString();
    final pairSymbol = order['pair_symbol']?.toString() ??
        order['pairSymbol']?.toString() ??
        order['market_symbol']?.toString() ?? '';
    final userId = order['user_id']?.toString() ?? order['userId']?.toString() ?? '';
    final createdAt = _parseDate(order['created_at'] ?? order['createdAt']);
    final (statusColor, statusLabel) = _statusInfo(l10n, status);

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: sideColor.withValues(alpha: 0.1),
        child: Icon(
          isBuy ? Icons.trending_up : Icons.trending_down,
          color: sideColor,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Text(
            '${isBuy ? l10n.buy : l10n.sell} $pairSymbol',
            style:
                TextStyle(fontWeight: FontWeight.w600, color: sideColor),
          ),
          const SizedBox(width: 8),
          _StatusBadge(label: statusLabel, color: statusColor),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              '${l10n.amount}: ${FormatUtils.formatDecimalAmountDisplay(amount)}'
              '${price != null ? ' · ${l10n.adminOrderPriceLabel}: ${FormatUtils.formatDecimalAmountDisplay(price)}' : ''}',
              style: const TextStyle(fontSize: 12)),
          if (userId.isNotEmpty)
            Text('${l10n.adminUserLabel}: ${_truncate(userId, 16)}',
                style: const TextStyle(fontSize: 11)),
          if (createdAt != null)
            Text(DateFormat('dd/MM/yyyy HH:mm').format(createdAt.toLocal()),
                style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      isThreeLine: true,
    );
  }

  (Color, String) _statusInfo(AppLocalizations l10n, String s) {
    switch (s) {
      case 'FILLED':
        return (Colors.green, l10n.orderStatusFilled);
      case 'PARTIAL':
        return (Colors.blue, l10n.orderStatusPartial);
      case 'OPEN':
        return (Colors.orange, l10n.orderStatusOpen);
      case 'CANCELLED':
        return (Colors.grey, l10n.orderStatusCancelled);
      default:
        return (Colors.red, s);
    }
  }
}

class _DepositTile extends StatelessWidget {
  final Map<String, dynamic> deposit;
  final AppLocalizations l10n;
  const _DepositTile({required this.deposit, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final amount = deposit['amount']?.toString() ?? '0';
    final status = deposit['status']?.toString() ?? '';
    final userId = deposit['user_id']?.toString() ?? deposit['userId']?.toString() ?? '';
    final orderCode = deposit['order_code']?.toString() ?? deposit['orderCode']?.toString() ?? '';
    final createdAt = _parseDate(deposit['created_at'] ?? deposit['createdAt']);
    final (statusColor, statusLabel) = _depositStatusInfo(l10n, status);

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: statusColor.withValues(alpha: 0.1),
        child: Icon(
          status == 'PAID' ? Icons.check_circle_outline : Icons.pending_outlined,
          color: statusColor,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Text(
              '${FormatUtils.formatFiatIntegerDisplay(amount)} VND',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          _StatusBadge(label: statusLabel, color: statusColor),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (userId.isNotEmpty)
            Text('${l10n.adminUserLabel}: ${_truncate(userId, 16)}',
                style: const TextStyle(fontSize: 11)),
          if (orderCode.isNotEmpty)
            Text('${l10n.adminOrderCodeLabel}: $orderCode',
                style: const TextStyle(fontSize: 11)),
          if (createdAt != null)
            Text(DateFormat('dd/MM/yyyy HH:mm').format(createdAt.toLocal()),
                style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      isThreeLine: true,
    );
  }

  (Color, String) _depositStatusInfo(AppLocalizations l10n, String s) {
    switch (s) {
      case 'PAID':
        return (Colors.green, l10n.depositStatusPaid);
      case 'PENDING':
        return (Colors.orange, l10n.depositStatusPending);
      case 'CANCELLED':
        return (Colors.grey, l10n.depositStatusCancelled);
      default:
        return (Colors.grey, s);
    }
  }
}

class _WithdrawalTile extends StatelessWidget {
  final Map<String, dynamic> tx;
  final AppLocalizations l10n;
  const _WithdrawalTile({required this.tx, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final amount = tx['amount']?.toString() ?? '0';
    final status = tx['status']?.toString() ?? '';
    final chain = tx['chain']?.toString() ?? '';
    final userId = tx['user_id']?.toString() ?? tx['userId']?.toString() ?? '';
    final txHash = tx['tx_hash']?.toString() ?? tx['txHash']?.toString();
    final createdAt = _parseDate(tx['created_at'] ?? tx['createdAt']);
    final (statusColor, statusLabel) = _statusInfo(l10n, status);

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: statusColor.withValues(alpha: 0.1),
        child: Icon(
          status == 'COMPLETED'
              ? Icons.check_circle_outline
              : status == 'FAILED'
                  ? Icons.error_outline
                  : Icons.hourglass_empty,
          color: statusColor,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Text(
              '-${FormatUtils.formatDecimalAmountDisplay(amount)}',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.red)),
          const SizedBox(width: 8),
          _StatusBadge(label: statusLabel, color: statusColor),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$chain${userId.isNotEmpty ? ' · ${l10n.adminUserLabel}: ${_truncate(userId, 10)}' : ''}',
              style: const TextStyle(fontSize: 12)),
          if (txHash != null && txHash.isNotEmpty)
            Text('${l10n.adminTxHashLabel}: ${_truncate(txHash, 20)}',
                style: const TextStyle(
                    fontSize: 11, fontFamily: 'monospace')),
          if (createdAt != null)
            Text(DateFormat('dd/MM/yyyy HH:mm').format(createdAt.toLocal()),
                style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      isThreeLine: true,
    );
  }

  (Color, String) _statusInfo(AppLocalizations l10n, String s) {
    switch (s) {
      case 'COMPLETED':
        return (Colors.green, l10n.withdrawalStatusCompleted);
      case 'CONFIRMING':
        return (Colors.blue, l10n.withdrawalStatusConfirming);
      case 'PENDING':
        return (Colors.orange, l10n.withdrawalStatusPending);
      case 'FAILED':
        return (Colors.red, l10n.withdrawalStatusFailed);
      default:
        return (Colors.grey, s);
    }
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  return DateTime.tryParse(v.toString());
}

String _truncate(String s, int maxLen) =>
    s.length > maxLen ? '${s.substring(0, maxLen)}...' : s;

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _CountBanner extends StatelessWidget {
  final AppLocalizations l10n;
  final int total;
  final int shown;
  final String label;
  const _CountBanner(
      {required this.l10n, required this.total, required this.shown, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            l10n.adminShowingCount(shown, total, label),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final String message;
  const _EmptyPanel({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorPanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline,
              size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context).adminRetryButton)),
        ],
      ),
    );
  }
}

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
