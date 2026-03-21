import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/presentation/providers/withdrawal_management_provider.dart';
import 'package:crypto_trading_app/data/models/admin_withdrawal_model.dart';
import 'package:crypto_trading_app/presentation/screens/withdrawal_management/withdrawal_detail_screen.dart';

class WithdrawalManagementScreen extends StatefulWidget {
  const WithdrawalManagementScreen({super.key});

  @override
  State<WithdrawalManagementScreen> createState() =>
      _WithdrawalManagementScreenState();
}

class _WithdrawalManagementScreenState extends State<WithdrawalManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<WithdrawalManagementProvider>();
      p.loadWithdrawals(status: 'PENDING', page: 1);
      p.loadStats();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final p = context.read<WithdrawalManagementProvider>();
      p.loadWithdrawals(
        status: _tabs.index == 0 ? 'PENDING' : p.filterStatus,
        chain: p.filterChain,
        search: v.trim().isEmpty ? null : v.trim(),
        dateFrom: p.filterDateFrom,
        dateTo: p.filterDateTo,
        page: 1,
      );
    });
  }

  void _onTabChange() {
    final p = context.read<WithdrawalManagementProvider>();
    final status = _tabs.index == 0 ? 'PENDING' : null;
    p.loadWithdrawals(
      status: status,
      chain: p.filterChain,
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      dateFrom: p.filterDateFrom,
      dateTo: p.filterDateTo,
      page: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.withdrawalManagementTitle),
        bottom: TabBar(
          controller: _tabs,
          onTap: (_) => _onTabChange(),
          tabs: [
            Tab(icon: const Icon(Icons.pending_outlined), text: l10n.withdrawalManagementTabPending),
            Tab(icon: const Icon(Icons.list), text: l10n.withdrawalManagementTabAll),
          ],
        ),
      ),
      body: Column(
        children: [
          _StatsBanner(),
          _FilterBar(
            searchController: _searchController,
            onSearch: _onSearch,
          ),
          const Divider(height: 1),
          Expanded(child: _WithdrawalList(onTabChange: _onTabChange)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final p = context.read<WithdrawalManagementProvider>();
          if (p.isSubmitting) return;
          final l10n = AppLocalizations.of(context);
          final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.withdrawalApproveAllSmallTitle),
              content: Text(l10n.withdrawalApproveAllSmallContent),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.withdrawalApproveAllProcess),
                ),
              ],
            ),
          );
          if (ok == true) {
            await p.batchProcessPending();
            if (p.error != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(p.error!)),
              );
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.withdrawalProcessedSnack)),
              );
            }
          }
        },
        icon: const Icon(Icons.play_arrow),
        label: Text(l10n.withdrawalApproveAllSmallTitle),
      ),
    );
  }
}

class _StatsBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<WithdrawalManagementProvider>(
      builder: (_, p, __) {
        final stats = p.stats;
        if (stats == null || stats.pendingCount == 0) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          color: Colors.orange.withValues(alpha: 0.1),
          child: Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: Colors.orange),
              const SizedBox(width: 6),
              Text(
                l10n.withdrawalStatsPendingCount(stats.pendingCount),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
              if (stats.pendingTotalByChain.isNotEmpty) ...[
                const SizedBox(width: 8),
                ...stats.pendingTotalByChain.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        '${e.key}: ${e.value}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    )),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final void Function(String) onSearch;

  const _FilterBar({
    required this.searchController,
    required this.onSearch,
  });

  static List<(String, String?)> _statuses(AppLocalizations l10n) => [
    (l10n.adminFilterAll, null),
    (l10n.withdrawalStatusPending, 'PENDING'),
    (l10n.withdrawalStatusConfirming, 'CONFIRMING'),
    (l10n.withdrawalStatusCompleted, 'COMPLETED'),
    (l10n.withdrawalStatusFailed, 'FAILED'),
  ];

  static const _chains = [
    ('Tất cả', null),
    ('TRON Nile', 'TRON_NILE'),
    ('TRON Shasta', 'TRON_SHASTA'),
    ('ETH Sepolia', 'ETH_SEPOLIA'),
    ('Solana Devnet', 'SOLANA_DEVNET'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: l10n.withdrawalSearchHint,
              prefixIcon: const Icon(Icons.search_outlined),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),
          Consumer<WithdrawalManagementProvider>(
            builder: (_, p, __) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.status,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _statuses(l10n).map((s) {
                      final sel = p.filterStatus == s.$2;
                      return FilterChip(
                        label: Text(s.$1),
                        selected: sel,
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) {
                          p.loadWithdrawals(
                            status: s.$2,
                            chain: p.filterChain,
                            search: p.filterSearch,
                            dateFrom: p.filterDateFrom,
                            dateTo: p.filterDateTo,
                            page: 1,
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.withdrawalNetworkLabel,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _chains.map((c) {
                      final sel = p.filterChain == c.$2;
                      return FilterChip(
                        label: Text(c.$1),
                        selected: sel,
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) {
                          p.loadWithdrawals(
                            status: p.filterStatus,
                            chain: c.$2,
                            search: p.filterSearch,
                            dateFrom: p.filterDateFrom,
                            dateTo: p.filterDateTo,
                            page: 1,
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WithdrawalList extends StatelessWidget {
  final VoidCallback onTabChange;

  const _WithdrawalList({required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<WithdrawalManagementProvider>(
      builder: (_, p, __) {
        if (p.isLoading && p.withdrawals.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (p.error != null && p.withdrawals.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(p.error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => p.loadWithdrawals(
                    status: p.filterStatus,
                    chain: p.filterChain,
                    search: p.filterSearch,
                    page: 1,
                  ),
                  child: Text(AppLocalizations.of(context).retry),
                ),
              ],
            ),
          );
        }
        if (p.withdrawals.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 12),
                Text(l10n.withdrawalNoRequests, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${p.withdrawals.length} / ${p.total} yêu cầu',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await p.loadWithdrawals(
                    status: p.filterStatus,
                    chain: p.filterChain,
                    search: p.filterSearch,
                    dateFrom: p.filterDateFrom,
                    dateTo: p.filterDateTo,
                    page: 1,
                  );
                  await p.loadStats();
                  onTabChange();
                },
                child: ListView.separated(
                  itemCount: p.withdrawals.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final w = p.withdrawals[i];
                    return _WithdrawalTile(
                      withdrawal: w,
                      l10n: l10n,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: p,
                            child: WithdrawalDetailScreen(txId: w.txId),
                          ),
                        ),
                      ).then((_) {
                        p.loadWithdrawals(
                          status: p.filterStatus,
                          chain: p.filterChain,
                          search: p.filterSearch,
                          page: 1,
                        );
                        p.loadStats();
                      }),
                    );
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

class _WithdrawalTile extends StatelessWidget {
  final AdminWithdrawalModel withdrawal;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _WithdrawalTile({required this.withdrawal, required this.onTap, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusLabel) = _statusInfo(l10n, withdrawal.status);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: statusColor.withValues(alpha: 0.1),
        child: Icon(
          withdrawal.status == 'COMPLETED'
              ? Icons.check_circle_outline
              : withdrawal.status == 'FAILED'
                  ? Icons.error_outline
                  : Icons.hourglass_empty,
          color: statusColor,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Text(
            '${FormatUtils.formatDecimalAmountDisplay(withdrawal.amount)} ${withdrawal.chain}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            withdrawal.userDisplayName,
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            '→ ${_truncate(withdrawal.toAddress, 16)}',
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
          ),
          Text(
            DateFormat('dd/MM/yyyy HH:mm').format(withdrawal.createdAt.toLocal()),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      isThreeLine: true,
      onTap: onTap,
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

String _truncate(String s, int maxLen) =>
    s.length > maxLen ? '${s.substring(0, maxLen)}...' : s;
