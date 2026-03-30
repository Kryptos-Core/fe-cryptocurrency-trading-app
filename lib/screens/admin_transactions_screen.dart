import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart' show sl;
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/data/models/user_model.dart';
import 'package:crypto_trading_app/presentation/providers/admin_transactions_provider.dart';
import 'package:crypto_trading_app/presentation/providers/admin_users_provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'admin_user_detail_screen.dart';

String _adminReconcileStoppedReasonLabel(AppLocalizations l10n, String code) {
  switch (code) {
    case 'all_matched':
      return l10n.adminReconcileReasonAllMatched;
    case 'no_progress':
      return l10n.adminReconcileReasonNoProgress;
    case 'max_rounds':
      return l10n.adminReconcileReasonMaxRounds;
    default:
      return code;
  }
}

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
  final _pairController = TextEditingController();
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
    _pairController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _applyOrderFiltersFromFields() {
    final pair = _pairController.text.trim();
    context.read<AdminTransactionsProvider>().applyOrderFilters(
          userId: _userController.text.trim(),
          status: _selectedStatus,
          pairId: pair.isEmpty ? null : pair,
        );
  }

  void _onUserSearch(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _applyOrderFiltersFromFields);
  }

  void _onPairFilter(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() {});
      _applyOrderFiltersFromFields();
    });
  }

  Future<void> _onReconcileMatchingPressed(
      BuildContext context, AppLocalizations l10n) async {
    final pairId = _pairController.text.trim();
    if (pairId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminReconcileMatchingPairRequired)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminReconcileMatchingConfirmTitle),
        content: Text(l10n.adminReconcileMatchingConfirmMessage(pairId)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.adminReconcileMatchingCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.adminReconcileMatchingRun),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final provider = context.read<AdminTransactionsProvider>();
    try {
      final r = await provider.reconcileOrdersMatching(pairId);
      if (!context.mounted) return;
      final reasonLabel = _adminReconcileStoppedReasonLabel(l10n, r.stoppedReason);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.adminReconcileMatchingSuccess(
            r.tradesExecuted,
            r.openOrdersRemaining,
            reasonLabel,
          )),
        ),
      );
      await provider.fetchOrders(refresh: true);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
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
    final l10n = AppLocalizations.of(context);
    return Consumer<AdminTransactionsProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Column(
            children: [
              TextField(
                controller: _userController,
                onChanged: _onUserSearch,
                decoration: InputDecoration(
                  hintText: l10n.filterByUserId,
                  prefixIcon: const Icon(Icons.person_search_outlined),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  suffixIcon: _userController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _userController.clear();
                            _applyOrderFiltersFromFields();
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pairController,
                      onChanged: _onPairFilter,
                      decoration: InputDecoration(
                        hintText: l10n.adminPairIdFilterHint,
                        prefixIcon:
                            const Icon(Icons.currency_exchange_outlined),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        suffixIcon: _pairController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _pairController.clear();
                                  setState(() {});
                                  _applyOrderFiltersFromFields();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: provider.isReconcileMatchingLoading
                        ? null
                        : () => _onReconcileMatchingPressed(context, l10n),
                    icon: provider.isReconcileMatchingLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync_alt, size: 20),
                    label: Text(
                      l10n.adminReconcileMatchingButton,
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _orderStatuses(l10n).map((s) {
                    final sel = _selectedStatus == s.$2;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(s.$1),
                        selected: sel,
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) {
                          setState(() => _selectedStatus = s.$2);
                          _applyOrderFiltersFromFields();
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
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
              label: l10n.orders),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => p.fetchOrders(refresh: true),
                child: ListView.separated(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                  itemCount: p.orders.length + (p.ordersHasMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
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
                      label: l10n.adminTabDeposits),
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
                      label: l10n.adminTabWithdrawals),
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final side = order['side']?.toString() ?? '';
    final isBuy = side == 'BUY';
    final sideColor = isBuy ? Colors.green : Colors.red;
    final status = order['status']?.toString() ?? '';
    final amount = order['amount']?.toString() ?? '0';
    final price = order['price']?.toString();
    final pairSymbol = _pairSymbolFromOrder(order);
    final (base, quote) = _baseQuoteFromPairSymbol(pairSymbol);
    final orderType = order['type']?.toString() ?? '';
    final priceStr = price?.toString() ?? '';
    final hasPrice = priceStr.isNotEmpty;
    final (statusColor, statusLabel) = _statusInfo(l10n, status);

    final pairIdRaw = order['pair_id']?.toString() ?? order['pairId']?.toString() ?? '';
    final pairDisplay = pairSymbol.isNotEmpty
        ? pairSymbol
        : (pairIdRaw.isNotEmpty ? _truncate(pairIdRaw, 18) : '');
    final typeLabel = orderType == 'LIMIT'
        ? l10n.orderDetailTypeLimitLabel
        : orderType == 'MARKET'
            ? l10n.orderDetailTypeMarketLabel
            : orderType;
    final buySellPriceLabel = isBuy
        ? l10n.adminOrderListBuyPriceLabel
        : l10n.adminOrderListSellPriceLabel;

    final amountValue = [
      FormatUtils.formatDecimalAmountDisplay(amount),
      if (base.isNotEmpty) base,
    ].join(' ');

    final priceValue = orderType == 'MARKET'
        ? '${l10n.orderDetailTypeMarketLabel} · ${l10n.adminOrderListMarketPriceHint}'
        : (!hasPrice
            ? '—'
            : [
                FormatUtils.formatDecimalAmountDisplay(priceStr),
                if (quote.isNotEmpty) quote,
              ].join(' '));

    return Material(
      color: cs.surfaceContainerLow.withValues(alpha: 0.85),
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: () => _OrderDetailSheet.show(context, order),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: sideColor.withValues(alpha: 0.12),
                child: Icon(
                  isBuy ? Icons.trending_up : Icons.trending_down,
                  color: sideColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                pairDisplay.isNotEmpty ? pairDisplay : '—',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                  height: 1.2,
                                ),
                              ),
                              _OrderPill(
                                label: isBuy ? l10n.buy : l10n.sell,
                                foreground: sideColor,
                                background: sideColor.withValues(alpha: 0.12),
                                border: sideColor.withValues(alpha: 0.35),
                              ),
                              _OrderPill(
                                label: typeLabel,
                                foreground: cs.onSurfaceVariant,
                                background: cs.surfaceContainerHighest
                                    .withValues(alpha: 0.65),
                                border: cs.outlineVariant.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        ),
                        _StatusBadge(label: statusLabel, color: statusColor),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 22,
                          color: cs.outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _OrderListMetric(
                            label: l10n.orderDetailAmount,
                            value: amountValue,
                          ),
                        ),
                        Expanded(
                          child: _OrderListMetric(
                            label: orderType == 'MARKET'
                                ? l10n.orderDetailPrice
                                : buySellPriceLabel,
                            value: priceValue,
                          ),
                        ),
                      ],
                    ),
                    if (pairIdRaw.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SelectableText(
                              '${l10n.adminOrderPairIdLabel}: $pairIdRaw',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                                color: cs.onSurfaceVariant,
                                height: 1.25,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.adminOrderPairIdCopyTooltip,
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              Icons.copy_rounded,
                              size: 20,
                              color: cs.onSurfaceVariant,
                            ),
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: pairIdRaw),
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.adminOrderPairIdCopied),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
      case 'REJECTED':
        return (Colors.red, l10n.orderStatusRejected);
      default:
        return (Colors.red, s);
    }
  }
}

/// Compact capsule used on admin order cards (Mua/Bán, Limit/Market).
class _OrderPill extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;
  final Color border;

  const _OrderPill({
    required this.label,
    required this.foreground,
    required this.background,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: foreground,
          height: 1.1,
        ),
      ),
    );
  }
}

class _OrderListMetric extends StatelessWidget {
  final String label;
  final String value;

  const _OrderListMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ],
    );
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
      trailing: const Icon(Icons.chevron_right, size: 18),
      isThreeLine: true,
      mouseCursor: SystemMouseCursors.click,
      onTap: () => _DepositDetailSheet.show(context, deposit),
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
      trailing: const Icon(Icons.chevron_right, size: 18),
      isThreeLine: true,
      mouseCursor: SystemMouseCursors.click,
      onTap: () => _WithdrawalDetailSheet.show(context, tx),
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

// ── Detail Sheets ─────────────────────────────────────────────────────────────

/// Helper to copy text and show snack.
void _copyToClipboard(BuildContext context, String text, String message) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}

/// Fetch user entity from /users/:id and navigate to AdminUserDetailScreen.
Future<void> _openUserDetail(BuildContext context, String userId) async {
  if (userId.isEmpty) return;
  final scaffold = ScaffoldMessenger.of(context);
  try {
    final dio = sl<DioClient>().dio;
    final resp = await dio.get(ApiConstants.userById(userId));
    final raw = resp.data is Map<String, dynamic>
        ? ((resp.data as Map<String, dynamic>)['data'] ?? resp.data) as Map<String, dynamic>
        : resp.data as Map<String, dynamic>;
    final user = UserModel.fromJson(raw).toEntity();
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<AdminUsersProvider>(),
          child: AdminUserDetailScreen(user: user),
        ),
      ),
    );
  } catch (e) {
    scaffold.showSnackBar(SnackBar(
      content: Text('Không thể tải thông tin user: $e'),
      behavior: SnackBarBehavior.floating,
    ));
  }
}

// ── _OrderDetailSheet ─────────────────────────────────────────────────────────

class _OrderDetailSheet extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderDetailSheet({required this.order});

  static void show(BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OrderDetailSheet(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    final orderId    = order['order_id']?.toString() ?? order['orderId']?.toString() ?? '';
    final userId     = order['user_id']?.toString() ?? order['userId']?.toString() ?? '';
    final side       = order['side']?.toString() ?? '';
    final isBuy      = side == 'BUY';
    final sideColor  = isBuy ? Colors.green : Colors.red;
    final type       = order['type']?.toString() ?? '';
    final status     = order['status']?.toString() ?? '';
    final pairSymbol = _pairSymbolFromOrder(order);
    final amount        = order['amount']?.toString() ?? '0';
    final price         = order['price']?.toString();
    final filledAmount  = order['filled_amount']?.toString() ?? order['filledAmount']?.toString() ?? '0';
    final avgPrice      = order['avg_price']?.toString() ?? order['avgPrice']?.toString();
    final tif           = order['time_in_force']?.toString() ?? order['timeInForce']?.toString() ?? 'GTC';
    final clientOid     = order['client_order_id']?.toString() ?? order['clientOrderId']?.toString();
    final createdAt     = _parseDate(order['created_at'] ?? order['createdAt']);
    final updatedAt     = _parseDate(order['updated_at'] ?? order['updatedAt']);
    final (statusColor, statusLabel) = _resolveStatus(l10n, status);

    // Derived values
    final amountD    = double.tryParse(amount) ?? 0;
    final filledD    = double.tryParse(filledAmount) ?? 0;
    final remaining  = amountD > 0 ? amountD - filledD : 0.0;
    final fillPct    = amountD > 0 ? (filledD / amountD * 100) : 0.0;
    final typeLabel  = type == 'LIMIT'
        ? l10n.orderDetailTypeLimitLabel
        : type == 'MARKET'
            ? l10n.orderDetailTypeMarketLabel
            : type;
    final sideLabel  = isBuy ? l10n.orderDetailSideBuy : l10n.orderDetailSideSell;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: sideColor.withValues(alpha: 0.12),
                  child: Icon(
                    isBuy ? Icons.trending_up : Icons.trending_down,
                    color: sideColor, size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${isBuy ? l10n.buy : l10n.sell} $pairSymbol',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: sideColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          _StatusBadge(label: statusLabel, color: statusColor),
                          if (type.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            _StatusBadge(label: typeLabel, color: cs.primary),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Body
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(16),
              children: [
                _DetailSection(
                  title: 'Thông tin lệnh',
                  children: [
                    if (orderId.isNotEmpty)
                      _CopyableRow(
                        label: l10n.orderDetailOrderId,
                        value: orderId,
                        monospace: true,
                        onCopy: () => _copyToClipboard(context, orderId, l10n.orderDetailCopied),
                      ),
                    if (pairSymbol.isNotEmpty)
                      _InfoRow(label: l10n.orderDetailPair, value: pairSymbol),
                    _InfoRow(
                      label: l10n.orderDetailSide,
                      valueWidget: Text(
                        sideLabel,
                        style: TextStyle(fontWeight: FontWeight.w600, color: sideColor),
                      ),
                    ),
                    _InfoRow(label: l10n.orderDetailType, value: typeLabel),
                    _InfoRow(label: l10n.orderDetailTimeInForce, value: tif),
                  ],
                ),
                const SizedBox(height: 12),
                _DetailSection(
                  title: 'Giá & Khối lượng',
                  children: [
                    _InfoRow(
                      label: l10n.orderDetailAmount,
                      value: '${FormatUtils.formatDecimalAmountDisplay(amount)} ${pairSymbol.split('/').firstOrNull ?? ''}',
                    ),
                    if (price != null && price.isNotEmpty)
                      _InfoRow(
                        label: l10n.orderDetailPrice,
                        value: '${FormatUtils.formatDecimalAmountDisplay(price)} ${pairSymbol.split('/').lastOrNull ?? ''}',
                      ),
                    _InfoRow(
                      label: l10n.orderDetailFilledAmount,
                      value: '${FormatUtils.formatDecimalAmountDisplay(filledAmount)} ${pairSymbol.split('/').firstOrNull ?? ''}',
                    ),
                    if (avgPrice != null && avgPrice.isNotEmpty)
                      _InfoRow(
                        label: l10n.orderDetailAvgPrice,
                        value: '${FormatUtils.formatDecimalAmountDisplay(avgPrice)} ${pairSymbol.split('/').lastOrNull ?? ''}',
                      ),
                    _InfoRow(
                      label: l10n.orderDetailRemainingAmount,
                      value: '${FormatUtils.formatDecimalAmountDisplay(remaining.toStringAsFixed(8))} ${pairSymbol.split('/').firstOrNull ?? ''}',
                    ),
                    _InfoRow(
                      label: l10n.orderDetailFilledPct,
                      valueWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 80,
                            child: LinearProgressIndicator(
                              value: fillPct / 100,
                              backgroundColor: cs.surfaceContainerHighest,
                              color: fillPct >= 100 ? Colors.green : cs.primary,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${fillPct.toStringAsFixed(1)}%',
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DetailSection(
                  title: 'Thời gian',
                  children: [
                    if (createdAt != null)
                      _InfoRow(
                        label: l10n.orderDetailCreatedAt,
                        value: DateFormat('dd/MM/yyyy HH:mm:ss').format(createdAt.toLocal()),
                      ),
                    if (updatedAt != null)
                      _InfoRow(
                        label: l10n.orderDetailUpdatedAt,
                        value: DateFormat('dd/MM/yyyy HH:mm:ss').format(updatedAt.toLocal()),
                      ),
                  ],
                ),
                if (clientOid != null && clientOid.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _DetailSection(
                    title: 'Tham chiếu',
                    children: [
                      _CopyableRow(
                        label: 'Client Order ID',
                        value: clientOid,
                        monospace: true,
                        onCopy: () => _copyToClipboard(context, clientOid, l10n.orderDetailCopied),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                _DetailSection(
                  title: 'Người dùng',
                  children: [
                    if (userId.isNotEmpty)
                      _CopyableRow(
                        label: l10n.orderDetailUserId,
                        value: userId,
                        monospace: true,
                        onCopy: () => _copyToClipboard(context, userId, l10n.orderDetailCopied),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (userId.isNotEmpty)
                  FilledButton.tonal(
                    onPressed: () => _openUserDetail(context, userId),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_search_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.orderDetailViewUser),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, String) _resolveStatus(AppLocalizations l10n, String s) {
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

// ── _DepositDetailSheet ───────────────────────────────────────────────────────

class _DepositDetailSheet extends StatelessWidget {
  final Map<String, dynamic> deposit;
  const _DepositDetailSheet({required this.deposit});

  static void show(BuildContext context, Map<String, dynamic> deposit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DepositDetailSheet(deposit: deposit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    final depositId  = deposit['id']?.toString() ?? deposit['deposit_id']?.toString() ?? '';
    final userId     = deposit['user_id']?.toString() ?? deposit['userId']?.toString() ?? '';
    final amount     = deposit['amount']?.toString() ?? '0';
    final status     = deposit['status']?.toString() ?? '';
    final orderCode  = deposit['order_code']?.toString() ?? deposit['orderCode']?.toString() ?? '';
    final createdAt  = _parseDate(deposit['created_at'] ?? deposit['createdAt']);
    final updatedAt  = _parseDate(deposit['updated_at'] ?? deposit['updatedAt']);
    final (statusColor, statusLabel) = _resolveStatus(l10n, status);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.withValues(alpha: 0.12),
                  child: const Icon(Icons.arrow_downward, color: Colors.green, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.depositDetailTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      const SizedBox(height: 2),
                      _StatusBadge(label: statusLabel, color: statusColor),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(16),
              children: [
                _DetailSection(
                  title: 'Thông tin nạp tiền',
                  children: [
                    _InfoRow(
                      label: l10n.depositDetailAmount,
                      valueWidget: Text(
                        '${FormatUtils.formatFiatIntegerDisplay(amount)} VND',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    _InfoRow(
                      label: l10n.depositDetailStatus,
                      valueWidget: _StatusBadge(label: statusLabel, color: statusColor),
                    ),
                    if (orderCode.isNotEmpty)
                      _CopyableRow(
                        label: l10n.depositDetailOrderCode,
                        value: orderCode,
                        monospace: true,
                        onCopy: () => _copyToClipboard(context, orderCode, l10n.depositDetailCopied),
                      ),
                    if (depositId.isNotEmpty)
                      _CopyableRow(
                        label: 'Deposit ID',
                        value: depositId,
                        monospace: true,
                        onCopy: () => _copyToClipboard(context, depositId, l10n.depositDetailCopied),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _DetailSection(
                  title: 'Thời gian',
                  children: [
                    if (createdAt != null)
                      _InfoRow(
                        label: l10n.depositDetailCreatedAt,
                        value: DateFormat('dd/MM/yyyy HH:mm:ss').format(createdAt.toLocal()),
                      ),
                    if (updatedAt != null)
                      _InfoRow(
                        label: l10n.depositDetailUpdatedAt,
                        value: DateFormat('dd/MM/yyyy HH:mm:ss').format(updatedAt.toLocal()),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _DetailSection(
                  title: 'Người dùng',
                  children: [
                    if (userId.isNotEmpty)
                      _CopyableRow(
                        label: l10n.depositDetailUserId,
                        value: userId,
                        monospace: true,
                        onCopy: () => _copyToClipboard(context, userId, l10n.depositDetailCopied),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (userId.isNotEmpty)
                  FilledButton.tonal(
                    onPressed: () => _openUserDetail(context, userId),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_search_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.depositDetailViewUser),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, String) _resolveStatus(AppLocalizations l10n, String s) {
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

// ── _WithdrawalDetailSheet ────────────────────────────────────────────────────

class _WithdrawalDetailSheet extends StatelessWidget {
  final Map<String, dynamic> tx;
  const _WithdrawalDetailSheet({required this.tx});

  static void show(BuildContext context, Map<String, dynamic> tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _WithdrawalDetailSheet(tx: tx),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    final txId      = tx['id']?.toString() ?? tx['tx_id']?.toString() ?? '';
    final userId    = tx['user_id']?.toString() ?? tx['userId']?.toString() ?? '';
    final amount    = tx['amount']?.toString() ?? '0';
    final chain     = tx['chain']?.toString() ?? '';
    final address   = tx['to_address']?.toString() ?? tx['toAddress']?.toString() ?? tx['address']?.toString() ?? '';
    final txHash    = tx['tx_hash']?.toString() ?? tx['txHash']?.toString() ?? '';
    final symbol    = tx['symbol']?.toString() ?? tx['currency_symbol']?.toString() ?? '';
    final status    = tx['status']?.toString() ?? '';
    final createdAt = _parseDate(tx['created_at'] ?? tx['createdAt']);
    final updatedAt = _parseDate(tx['updated_at'] ?? tx['updatedAt']);
    final (statusColor, statusLabel) = _resolveStatus(l10n, status);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.12),
                  child: Icon(Icons.arrow_upward, color: statusColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.withdrawalDetailInfoTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      const SizedBox(height: 2),
                      _StatusBadge(label: statusLabel, color: statusColor),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(16),
              children: [
                _DetailSection(
                  title: 'Thông tin giao dịch',
                  children: [
                    _InfoRow(
                      label: l10n.withdrawalDetailAmount,
                      valueWidget: Text(
                        '${FormatUtils.formatDecimalAmountDisplay(amount)}${symbol.isNotEmpty ? ' $symbol' : ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red),
                      ),
                    ),
                    if (chain.isNotEmpty)
                      _InfoRow(label: l10n.withdrawalDetailChain, value: chain),
                    _InfoRow(
                      label: l10n.withdrawalDetailStatus,
                      valueWidget: _StatusBadge(label: statusLabel, color: statusColor),
                    ),
                    if (txId.isNotEmpty)
                      _CopyableRow(
                        label: 'Withdrawal ID',
                        value: txId,
                        monospace: true,
                        onCopy: () => _copyToClipboard(context, txId, l10n.withdrawalDetailCopied),
                      ),
                  ],
                ),
                if (address.isNotEmpty || txHash.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _DetailSection(
                    title: 'On-Chain',
                    children: [
                      if (address.isNotEmpty)
                        _CopyableRow(
                          label: l10n.withdrawalDetailAddress,
                          value: address,
                          monospace: true,
                          onCopy: () => _copyToClipboard(context, address, l10n.withdrawalDetailCopied),
                        ),
                      if (txHash.isNotEmpty)
                        _CopyableRow(
                          label: l10n.withdrawalDetailTxHash,
                          value: txHash,
                          monospace: true,
                          onCopy: () => _copyToClipboard(context, txHash, l10n.withdrawalDetailCopied),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                _DetailSection(
                  title: 'Thời gian',
                  children: [
                    if (createdAt != null)
                      _InfoRow(
                        label: l10n.withdrawalDetailCreatedAt,
                        value: DateFormat('dd/MM/yyyy HH:mm:ss').format(createdAt.toLocal()),
                      ),
                    if (updatedAt != null)
                      _InfoRow(
                        label: l10n.withdrawalDetailUpdatedAt,
                        value: DateFormat('dd/MM/yyyy HH:mm:ss').format(updatedAt.toLocal()),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _DetailSection(
                  title: 'Người dùng',
                  children: [
                    if (userId.isNotEmpty)
                      _CopyableRow(
                        label: l10n.withdrawalDetailUserId,
                        value: userId,
                        monospace: true,
                        onCopy: () => _copyToClipboard(context, userId, l10n.withdrawalDetailCopied),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (userId.isNotEmpty)
                  FilledButton.tonal(
                    onPressed: () => _openUserDetail(context, userId),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_search_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.withdrawalDetailViewUser),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, String) _resolveStatus(AppLocalizations l10n, String s) {
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

// ── Detail sub-widgets ────────────────────────────────────────────────────────

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _DetailSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, indent: 16, endIndent: 16,
                      color: cs.outlineVariant.withValues(alpha: 0.4)),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  const _InfoRow({required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    assert(value != null || valueWidget != null, '_InfoRow needs value or valueWidget');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: valueWidget != null
                ? Align(
                    alignment: Alignment.centerRight,
                    child: valueWidget,
                  )
                : Text(
                    value!,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    textAlign: TextAlign.end,
                  ),
          ),
        ],
      ),
    );
  }
}

class _CopyableRow extends StatelessWidget {
  final String label;
  final String value;
  final bool monospace;
  final VoidCallback onCopy;
  const _CopyableRow({
    required this.label,
    required this.value,
    required this.onCopy,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: monospace ? 'monospace' : null,
                fontSize: monospace ? 11 : null,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.copy_outlined, size: 16),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            tooltip: 'Copy',
            onPressed: onCopy,
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

String _pairSymbolFromOrder(Map<String, dynamic> order) {
  final direct = order['pair_symbol']?.toString() ??
      order['pairSymbol']?.toString() ??
      order['market_symbol']?.toString();
  if (direct != null && direct.isNotEmpty) return direct;
  final p = order['pair'];
  if (p is Map) {
    final sym = p['symbol']?.toString();
    if (sym != null && sym.isNotEmpty) return sym;
  }
  return '';
}

(String base, String quote) _baseQuoteFromPairSymbol(String symbol) {
  final parts = symbol.split('/');
  if (parts.length >= 2) {
    return (parts.first.trim(), parts.last.trim());
  }
  return ('', '');
}

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
