import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/core/widgets/app_empty_state.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/onchain_chain_picker_provider.dart';
import 'package:crypto_trading_app/features/admin/withdrawal_management/presentation/providers/withdrawal_management_provider.dart';
import 'package:crypto_trading_app/features/admin/withdrawal_management/data/models/admin_withdrawal_model.dart';
import 'package:crypto_trading_app/core/widgets/app_dropdown_field.dart';
import 'package:crypto_trading_app/features/treasury/presentation/widgets/treasury_chain_dropdown.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<OnchainChainPickerProvider>().ensureLoaded();
      if (!mounted) return;
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
    final scheme = Theme.of(context).colorScheme;

    return Consumer<WithdrawalManagementProvider>(
      builder: (_, p, __) {
        final stats = p.stats;
        if (stats == null || stats.pendingCount == 0) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: scheme.tertiaryContainer,
          ),
          child: Row(
            children: [
              Icon(Icons.schedule, size: 16, color: scheme.onTertiaryContainer),
              const SizedBox(width: 8),
              Text(
                l10n.withdrawalStatsPendingCount(stats.pendingCount),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: scheme.onTertiaryContainer,
                ),
              ),
              if (stats.pendingTotalByChain.isNotEmpty) ...[
                const SizedBox(width: 8),
                ...stats.pendingTotalByChain.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        '${e.key}: ${FormatUtils.formatDecimalAmountDisplay(e.value)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onTertiaryContainer,
                        ),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chainPicker = context.watch<OnchainChainPickerProvider>();
    final withdrawalChains = chainPicker.withdrawalAdminFilterChains;
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
              final statusItems = _statuses(l10n);
              final menuHeight = MediaQuery.sizeOf(context).height * 0.35;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppDropdownField<String?>(
                    value: p.filterStatus,
                    labelText: l10n.status,
                    menuMaxHeight: menuHeight,
                    items: statusItems
                        .map(
                          (s) => DropdownMenuItem<String?>(
                            value: s.$2,
                            child: Text(s.$1, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      p.loadWithdrawals(
                        status: v,
                        chain: p.filterChain,
                        search: p.filterSearch,
                        dateFrom: p.filterDateFrom,
                        dateTo: p.filterDateTo,
                        page: 1,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  TreasuryChainDropdown(
                    chains: withdrawalChains,
                    value: p.filterChain,
                    allowAllOption: true,
                    allOptionLabel: l10n.adminFilterAll,
                    labelText: l10n.withdrawalNetworkLabel,
                    menuMaxHeight: menuHeight,
                    onChanged: (v) {
                      p.loadWithdrawals(
                        status: p.filterStatus,
                        chain: v,
                        search: p.filterSearch,
                        dateFrom: p.filterDateFrom,
                        dateTo: p.filterDateTo,
                        page: 1,
                      );
                    },
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
          return AppEmptyState(
            message: l10n.withdrawalNoRequests,
            icon: Icons.output_outlined,
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
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: p.withdrawals.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final w = p.withdrawals[i];
                    return _WithdrawalTile(
                      withdrawal: w,
                      l10n: l10n,
                      onTap: () => _WithdrawalDetailSheet.show(context, w),
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

  (Color, Color, String) _statusInfo(AppLocalizations l10n, String s) {
    switch (s) {
      case 'COMPLETED':
        return (const Color(0xFFEAF8F1), const Color(0xFF0F8A49), l10n.withdrawalStatusCompleted);
      case 'CONFIRMING':
        return (const Color(0xFFEAF2FD), const Color(0xFF0A5DC2), l10n.withdrawalStatusConfirming);
      case 'PENDING':
        return (const Color(0xFFFFF6E8), const Color(0xFFB56900), l10n.withdrawalStatusPending);
      case 'FAILED':
        return (const Color(0xFFFDECEF), const Color(0xFFB3261E), l10n.withdrawalStatusFailed);
      default:
        return (const Color(0xFFF1F5F9), const Color(0xFF64748B), s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor, statusLabel) = _statusInfo(l10n, withdrawal.status);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Material(
        color: scheme.surfaceContainerLow.withValues(alpha: 0.85),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.45)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: fgColor.withValues(alpha: 0.12),
                  child: Icon(
                    withdrawal.status == 'COMPLETED'
                        ? Icons.check_circle_outline
                        : withdrawal.status == 'FAILED'
                            ? Icons.error_outline
                            : Icons.hourglass_empty,
                    color: fgColor,
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
                            child: Text(
                              '${FormatUtils.formatDecimalAmountDisplay(withdrawal.amount)} ${withdrawal.assetSymbol}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface,
                                height: 1.2,
                              ),
                            ),
                          ),
                          _WithdrawalStatusBadge(label: statusLabel, bgColor: bgColor, fgColor: fgColor),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: scheme.outline,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _WithdrawalListMetric(
                              label: l10n.adminUserLabel,
                              value: withdrawal.userDisplayName,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _WithdrawalListMetric(
                              label: l10n.withdrawalDestinationLabel,
                              value: '→ ${_truncate(withdrawal.toAddress, 20)}',
                              isMonospace: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(withdrawal.createdAt.toLocal()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WithdrawalStatusBadge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color fgColor;

  const _WithdrawalStatusBadge({
    required this.label,
    required this.bgColor,
    required this.fgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fgColor,
        ),
      ),
    );
  }
}

class _WithdrawalListMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool isMonospace;

  const _WithdrawalListMetric({
    required this.label,
    required this.value,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            height: 1.2,
            fontFamily: isMonospace ? 'monospace' : null,
          ),
        ),
      ],
    );
  }
}

String _truncate(String s, int maxLen) =>
    s.length > maxLen ? '${s.substring(0, maxLen)}...' : s;

// ── Withdrawal Detail Bottom Sheet ─────────────────────────────────────────────

class _WithdrawalDetailSheet extends StatelessWidget {
  final AdminWithdrawalModel withdrawal;
  final AppLocalizations l10n;

  const _WithdrawalDetailSheet({
    required this.withdrawal,
    required this.l10n,
  });

  static void show(BuildContext context, AdminWithdrawalModel withdrawal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _WithdrawalDetailSheet(
        withdrawal: withdrawal,
        l10n: AppLocalizations.of(context),
      ),
    );
  }

  (Color, Color, String) _statusInfo(String s) {
    switch (s) {
      case 'COMPLETED':
        return (const Color(0xFFEAF8F1), const Color(0xFF0F8A49), l10n.withdrawalStatusCompleted);
      case 'CONFIRMING':
        return (const Color(0xFFEAF2FD), const Color(0xFF0A5DC2), l10n.withdrawalStatusConfirming);
      case 'PENDING':
        return (const Color(0xFFFFF6E8), const Color(0xFFB56900), l10n.withdrawalStatusPending);
      case 'FAILED':
        return (const Color(0xFFFDECEF), const Color(0xFFB3261E), l10n.withdrawalStatusFailed);
      default:
        return (const Color(0xFFF1F5F9), const Color(0xFF64748B), s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bgColor, fgColor, statusLabel) = _statusInfo(withdrawal.status);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
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
                color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
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
                  backgroundColor: fgColor.withValues(alpha: 0.12),
                  child: Icon(
                    withdrawal.status == 'COMPLETED'
                        ? Icons.check_circle_outline
                        : withdrawal.status == 'FAILED'
                            ? Icons.error_outline
                            : Icons.hourglass_empty,
                    color: fgColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${FormatUtils.formatDecimalAmountDisplay(withdrawal.amount)} ${withdrawal.assetSymbol}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _WithdrawalStatusBadge(label: statusLabel, bgColor: bgColor, fgColor: fgColor),
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
          // Actions
          if (withdrawal.status == 'PENDING')
            _ActionButtons(
              withdrawal: withdrawal,
              l10n: l10n,
              onActionResult: ({required bool success, String? errorMessage}) {
                final messenger = ScaffoldMessenger.of(context);
                final errorScheme = Theme.of(context).colorScheme;
                messenger.clearSnackBars();
                if (success) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(l10n.withdrawalApprovedSnack)),
                        ],
                      ),
                      backgroundColor: Colors.green.shade700,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  final navigator = Navigator.of(context);
                  Future.delayed(const Duration(milliseconds: 400), () {
                    if (context.mounted) navigator.pop();
                  });
                } else {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(errorMessage ?? l10n.unknownError)),
                        ],
                      ),
                      backgroundColor: errorScheme.error,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
            ),
          // Body
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(16),
              children: [
                _DetailSection(
                  title: l10n.withdrawalUserInfoTitle,
                  children: [
                    _InfoRow(
                      label: l10n.adminUserLabel,
                      valueWidget: Text(
                        withdrawal.userDisplayName,
                        style: TextStyle(fontWeight: FontWeight.w600, color: scheme.onSurface),
                      ),
                    ),
                    if (withdrawal.userEmail != null)
                      _InfoRow(label: 'Email', value: withdrawal.userEmail!),
                    if (withdrawal.userWalletBalance != null)
                      _InfoRow(
                        label: l10n.withdrawalBalanceLabel,
                        value: FormatUtils.formatDecimalAmountDisplay(withdrawal.userWalletBalance!),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _DetailSection(
                  title: l10n.withdrawalTransactionTitle,
                  children: [
                    _InfoRow(label: l10n.withdrawalNetworkLabel, value: withdrawal.chain),
                    _InfoRow(label: l10n.withdrawalAmountLabel, value: FormatUtils.formatDecimalAmountDisplay(withdrawal.amount)),
                    _InfoRow(label: l10n.withdrawalDestinationLabel, value: withdrawal.toAddress),
                    _InfoRow(
                      label: l10n.withdrawalTimeLabel,
                      value: DateFormat('dd/MM/yyyy HH:mm').format(withdrawal.createdAt.toLocal()),
                    ),
                    if (withdrawal.txHash != null && withdrawal.txHash!.isNotEmpty)
                      _InfoRow(label: l10n.withdrawalTxHashLabel, value: withdrawal.txHash!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
            width: 100,
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
                : SelectableText(
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

class _ActionButtons extends StatefulWidget {
  final AdminWithdrawalModel withdrawal;
  final AppLocalizations l10n;
  final void Function({required bool success, String? errorMessage}) onActionResult;

  const _ActionButtons({
    required this.withdrawal,
    required this.l10n,
    required this.onActionResult,
  });

  @override
  State<_ActionButtons> createState() => _ActionButtonsState();
}

enum _ActionState { idle, loading, success }

class _ActionButtonsState extends State<_ActionButtons> {
  _ActionState _approveState = _ActionState.idle;
  _ActionState _rejectState = _ActionState.idle;
  String? _lastError;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isBusy = _approveState == _ActionState.loading || _rejectState == _ActionState.loading;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isBusy ? null : () => _showRejectDialog(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.error,
                  side: BorderSide(color: scheme.error.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _buildButtonChild(
                  _rejectState,
                  widget.l10n.withdrawalRejectLabel,
                  scheme.error,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: isBusy ? null : () => _showApproveDialog(context),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _buildButtonChild(
                  _approveState,
                  widget.l10n.withdrawalApproveLabel,
                  scheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonChild(_ActionState state, String label, Color baseColor) {
    switch (state) {
      case _ActionState.loading:
        return SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: baseColor,
          ),
        );
      case _ActionState.success:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 18, color: baseColor),
            const SizedBox(width: 6),
            Text(label),
          ],
        );
      default:
        return Text(label);
    }
  }

  void _showApproveDialog(BuildContext context) {
    final l10n = widget.l10n;
    showDialog(
      context: context,
      barrierDismissible: _approveState != _ActionState.loading,
      builder: (ctx) => _ApproveRejectDialog(
        key: ValueKey('approve-${widget.withdrawal.txId}'),
        title: l10n.withdrawalApproveConfirmTitle,
        content: l10n.withdrawalApproveConfirmContent,
        isApprove: true,
        actionState: _approveState,
        lastError: _lastError,
        l10n: l10n,
        onConfirm: () => _handleApprove(ctx),
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final l10n = widget.l10n;
    showDialog(
      context: context,
      barrierDismissible: _rejectState != _ActionState.loading,
      builder: (ctx) => _RejectDialogContent(
        key: ValueKey('reject-${widget.withdrawal.txId}'),
        l10n: l10n,
        actionState: _rejectState,
        lastError: _lastError,
        onConfirm: (reason) => _handleReject(ctx, reason),
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  Future<void> _handleApprove(BuildContext dialogContext) async {
    final l10n = widget.l10n;
    setState(() {
      _approveState = _ActionState.loading;
      _lastError = null;
    });
    // Force dialog rebuild to show loading
    Navigator.pop(dialogContext);

    final p = context.read<WithdrawalManagementProvider>();
    final ok = await p.approve(widget.withdrawal.txId);

    if (!mounted) return;

    final onResult = widget.onActionResult;
    if (ok) {
      setState(() => _approveState = _ActionState.success);
      onResult(success: true);
    } else {
      final errMsg = p.error ?? l10n.unknownError;
      setState(() {
        _approveState = _ActionState.idle;
        _lastError = errMsg;
      });
      onResult(success: false, errorMessage: errMsg);
    }
  }

  Future<void> _handleReject(BuildContext dialogContext, String? reason) async {
    final l10n = widget.l10n;
    setState(() {
      _rejectState = _ActionState.loading;
      _lastError = null;
    });
    Navigator.pop(dialogContext);

    final p = context.read<WithdrawalManagementProvider>();
    final success = await p.reject(widget.withdrawal.txId, reason: reason);

    if (!mounted) return;

    final onResult = widget.onActionResult;
    if (success) {
      setState(() => _rejectState = _ActionState.success);
      onResult(success: true);
    } else {
      final errMsg = p.error ?? l10n.unknownError;
      setState(() {
        _rejectState = _ActionState.idle;
        _lastError = errMsg;
      });
      onResult(success: false, errorMessage: errMsg);
    }
  }
}

class _ApproveRejectDialog extends StatelessWidget {
  final String title;
  final String content;
  final bool isApprove;
  final _ActionState actionState;
  final String? lastError;
  final AppLocalizations l10n;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ApproveRejectDialog({
    super.key,
    required this.title,
    required this.content,
    required this.isApprove,
    required this.actionState,
    required this.lastError,
    required this.l10n,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLoading = actionState == _ActionState.loading;
    final hasError = lastError != null;

    return AlertDialog(
      title: Row(
        children: [
          if (isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isApprove ? scheme.primary : scheme.error,
              ),
            )
          else if (hasError)
            Icon(Icons.error_outline, color: scheme.error)
          else
            Icon(
              isApprove ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: isApprove ? Colors.green : scheme.error,
            ),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content),
          if (hasError) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: scheme.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lastError!,
                      style: TextStyle(color: scheme.onErrorContainer, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!isLoading)
          TextButton(
            onPressed: onCancel,
            child: Text(l10n.cancel),
          ),
        FilledButton(
          onPressed: isLoading ? null : onConfirm,
          style: isApprove
              ? null
              : FilledButton.styleFrom(backgroundColor: scheme.error),
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}

class _RejectDialogContent extends StatefulWidget {
  final AppLocalizations l10n;
  final _ActionState actionState;
  final String? lastError;
  final void Function(String? reason) onConfirm;
  final VoidCallback onCancel;

  const _RejectDialogContent({
    super.key,
    required this.l10n,
    required this.actionState,
    required this.lastError,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<_RejectDialogContent> createState() => _RejectDialogContentState();
}

class _RejectDialogContentState extends State<_RejectDialogContent> {
  late final TextEditingController _reasonCtrl;

  @override
  void initState() {
    super.initState();
    _reasonCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLoading = widget.actionState == _ActionState.loading;
    final hasError = widget.lastError != null;

    return AlertDialog(
      title: Row(
        children: [
          if (isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: scheme.error),
            )
          else if (hasError)
            Icon(Icons.error_outline, color: scheme.error)
          else
            Icon(Icons.cancel_outlined, color: scheme.error),
          const SizedBox(width: 10),
          Expanded(child: Text(widget.l10n.withdrawalRejectConfirmTitle)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading) ...[
            const SizedBox(height: 8),
            Text('Đang xử lý...', style: TextStyle(color: scheme.onSurfaceVariant)),
          ] else ...[
            TextField(
              controller: _reasonCtrl,
              decoration: InputDecoration(
                labelText: widget.l10n.withdrawalRejectReasonLabel,
                hintText: widget.l10n.withdrawalRejectReasonHint,
              ),
              maxLines: 3,
              enabled: !isLoading,
            ),
            if (hasError) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: scheme.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.lastError!,
                        style: TextStyle(color: scheme.onErrorContainer, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
      actions: [
        if (!isLoading)
          TextButton(
            onPressed: widget.onCancel,
            child: Text(widget.l10n.cancel),
          ),
        FilledButton(
          onPressed: isLoading ? null : () => widget.onConfirm(_reasonCtrl.text.isNotEmpty ? _reasonCtrl.text : null),
          style: FilledButton.styleFrom(backgroundColor: scheme.error),
          child: Text(widget.l10n.withdrawalRejectConfirmAction),
        ),
      ],
    );
  }
}
