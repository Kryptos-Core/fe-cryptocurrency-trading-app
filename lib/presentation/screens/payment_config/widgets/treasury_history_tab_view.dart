import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/data/models/treasury_model.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_provider.dart';
import 'package:crypto_trading_app/presentation/constants/treasury_chains.dart';
import 'package:crypto_trading_app/presentation/widgets/app_dropdown_field.dart';
import 'package:crypto_trading_app/presentation/widgets/debounced_search_text_field.dart';
import 'package:crypto_trading_app/presentation/widgets/treasury_chain_dropdown.dart';

String _treasuryHistoryTypeLabel(AppLocalizations l10n, String type) {
  switch (type.toUpperCase()) {
    case 'FUND':
      return l10n.treasuryHistoryTypeFund;
    case 'SWEEP':
      return l10n.treasuryHistoryTypeSweep;
    default:
      return type;
  }
}

String _treasuryHistoryStatusLabel(AppLocalizations l10n, String status) {
  switch (status.toUpperCase()) {
    case 'PENDING':
      return l10n.treasuryHistoryStatusPending;
    case 'PROCESSING':
      return l10n.treasuryHistoryStatusProcessing;
    case 'CONFIRMING':
      return l10n.treasuryHistoryStatusConfirming;
    case 'COMPLETED':
      return l10n.treasuryHistoryStatusCompleted;
    case 'FAILED':
      return l10n.treasuryHistoryStatusFailed;
    default:
      return status;
  }
}

class TreasuryHistoryTabView extends StatefulWidget {
  const TreasuryHistoryTabView({super.key});

  @override
  State<TreasuryHistoryTabView> createState() => _TreasuryHistoryTabViewState();
}

class _TreasuryHistoryTabViewState extends State<TreasuryHistoryTabView> {
  final ScrollController _scrollController = ScrollController();
  bool _loadMoreInFlight = false;
  bool _scrollMetricsPostFramePending = false;

  /// Same idea as [MarketsListScreen]: load next page near the bottom. Also handles
  /// "short viewport" (no scroll) by loading until the list scrolls or hasMore is false.
  void _maybeLoadMoreFromScrollPosition() {
    if (!mounted || _loadMoreInFlight) return;
    if (!_scrollController.hasClients) return;

    final provider = context.read<TreasuryProvider>();
    if (!provider.hasMoreHistory || provider.isLoadingMoreHistory || provider.isLoadingHistory) {
      return;
    }

    final pos = _scrollController.position;
    final maxExt = pos.maxScrollExtent;
    // Market tab uses 80% of maxScrollExtent; when content fits the screen, maxExt is 0 — treat as "at end".
    final nearEnd = maxExt <= 0 || pos.pixels >= maxExt * 0.8;
    if (!nearEnd) return;

    _loadMoreInFlight = true;
    provider.loadMoreHistory().whenComplete(() {
      if (!mounted) return;
      _loadMoreInFlight = false;
      // After new rows append, metrics may still fit in viewport — chain load (TanStack-style infinite query).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _maybeLoadMoreFromScrollPosition();
      });
    });
  }

  void _onScroll() => _maybeLoadMoreFromScrollPosition();

  bool _onScrollMetrics(ScrollMetricsNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    if (_scrollMetricsPostFramePending) return false;
    _scrollMetricsPostFramePending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollMetricsPostFramePending = false;
      if (mounted) _maybeLoadMoreFromScrollPosition();
    });
    return false;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.depositDetailCopied), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Consumer<TreasuryProvider>(
      builder: (context, provider, _) {
        final bottomInset = MediaQuery.of(context).padding.bottom;
        return RefreshIndicator(
          onRefresh: () => provider.loadHistory(force: true),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 12 + bottomInset),
            child: NotificationListener<ScrollMetricsNotification>(
              onNotification: _onScrollMetrics,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
              SliverToBoxAdapter(
                child: _TreasuryHistoryFilterBar(provider: provider),
              ),
              if (provider.error != null && provider.error!.isNotEmpty) ...[
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(
                  child: Material(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.error!,
                              style: TextStyle(color: theme.colorScheme.onErrorContainer, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: _SectionHeader(
                  icon: Icons.settings_suggest_outlined,
                  title: l10n.treasuryOperationsTitle,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 6)),
              if (provider.isLoadingHistory && provider.operations.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (provider.operations.isEmpty)
                SliverToBoxAdapter(
                  child: _EmptyHint(icon: Icons.inbox_outlined, message: l10n.treasuryNoOperations),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final op = provider.operations[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _TreasuryOperationTile(
                          l10n: l10n,
                          op: op,
                          onCopy: (s) => _copy(context, s),
                        ),
                      );
                    },
                    childCount: provider.operations.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 6)),
              SliverToBoxAdapter(
                child: _SectionHeader(
                  icon: Icons.receipt_long_outlined,
                  title: l10n.treasuryTransactionsTitle,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 6)),
              if (provider.transactions.isEmpty)
                SliverToBoxAdapter(
                  child: _EmptyHint(icon: Icons.payments_outlined, message: l10n.treasuryNoTransactions),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tx = provider.transactions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _TreasuryTransactionTile(
                          l10n: l10n,
                          tx: tx,
                          onCopy: (s) => _copy(context, s),
                        ),
                      );
                    },
                    childCount: provider.transactions.length,
                  ),
                ),
              if (provider.isLoadingMoreHistory)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.15,
          ),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyHint({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: theme.colorScheme.outline),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _TreasuryOperationTile extends StatelessWidget {
  final AppLocalizations l10n;
  final TreasuryOperationModel op;
  final void Function(String) onCopy;

  const _TreasuryOperationTile({
    required this.l10n,
    required this.op,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fmt = DateFormat('yyyy-MM-dd HH:mm');
    final isFund = op.type.toUpperCase() == 'FUND';

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(
                    isFund ? Icons.south_west : Icons.north_east,
                    color: scheme.onPrimaryContainer,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _TypeChip(l10n: l10n, typeCode: op.type),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              op.chain,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (op.createdAt != null)
                        Text(
                          fmt.format(op.createdAt!.toLocal()),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.1,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  FormatUtils.formatDecimalAmountDisplay(op.amount),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _StatusChip(l10n: l10n, status: op.status),
                if (op.failureReason != null && op.failureReason!.isNotEmpty)
                  Text(
                    op.failureReason!,
                    style: theme.textTheme.labelSmall?.copyWith(color: scheme.error),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            _IdRow(label: l10n.treasuryHistoryIdLabel, value: op.operationId, onCopy: onCopy),
            if (op.txHash != null && op.txHash!.isNotEmpty) ...[
              const SizedBox(height: 4),
              _HashRowCompact(l10n: l10n, hash: op.txHash!, onCopy: onCopy),
            ],
          ],
        ),
      ),
    );
  }
}

class _TreasuryTransactionTile extends StatelessWidget {
  final AppLocalizations l10n;
  final TreasuryTransactionModel tx;
  final void Function(String) onCopy;

  const _TreasuryTransactionTile({
    required this.l10n,
    required this.tx,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fmt = DateFormat('yyyy-MM-dd HH:mm');
    final isFund = tx.type.toUpperCase() == 'FUND';

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: scheme.secondaryContainer,
                  child: Icon(
                    isFund ? Icons.south_west : Icons.north_east,
                    color: scheme.onSecondaryContainer,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _TypeChip(l10n: l10n, typeCode: tx.type),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              tx.chain,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (tx.createdAt != null)
                        Text(
                          fmt.format(tx.createdAt!.toLocal()),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.1,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  FormatUtils.formatDecimalAmountDisplay(tx.amount),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _StatusChip(l10n: l10n, status: tx.status),
            const SizedBox(height: 4),
            _IdRow(label: l10n.treasuryHistoryIdLabel, value: tx.txId, onCopy: onCopy),
            const SizedBox(height: 2),
            _AddressRow(
              label: l10n.treasuryHistoryFrom,
              address: tx.fromAddress,
              onCopy: onCopy,
            ),
            const SizedBox(height: 2),
            _AddressRow(
              label: l10n.treasuryHistoryTo,
              address: tx.toAddress,
              onCopy: onCopy,
            ),
            if (tx.txHash != null && tx.txHash!.isNotEmpty) ...[
              const SizedBox(height: 4),
              _HashRowCompact(l10n: l10n, hash: tx.txHash!, onCopy: onCopy),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final AppLocalizations l10n;
  final String typeCode;

  const _TypeChip({required this.l10n, required this.typeCode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = _treasuryHistoryTypeLabel(l10n, typeCode);
    return Tooltip(
      message: typeCode,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.primary,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final AppLocalizations l10n;
  final String status;

  const _StatusChip({required this.l10n, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = status.toUpperCase();
    final label = _treasuryHistoryStatusLabel(l10n, status);
    late Color bg;
    late Color fg;
    IconData icon;
    switch (s) {
      case 'COMPLETED':
        bg = scheme.primary.withValues(alpha: 0.15);
        fg = scheme.primary;
        icon = Icons.check_circle_outline;
        break;
      case 'FAILED':
        bg = scheme.error.withValues(alpha: 0.12);
        fg = scheme.error;
        icon = Icons.error_outline;
        break;
      case 'PENDING':
        bg = scheme.tertiary.withValues(alpha: 0.15);
        fg = scheme.tertiary;
        icon = Icons.schedule;
        break;
      case 'CONFIRMING':
        bg = scheme.secondary.withValues(alpha: 0.18);
        fg = scheme.secondary;
        icon = Icons.sync;
        break;
      default:
        bg = scheme.surfaceContainerHigh;
        fg = scheme.onSurfaceVariant;
        icon = Icons.help_outline;
    }
    return Tooltip(
      message: status,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdRow extends StatelessWidget {
  final String label;
  final String value;
  final void Function(String) onCopy;

  const _IdRow({required this.label, required this.value, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: Tooltip(
            message: value,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontFamily: 'monospace',
                fontFamilyFallback: const ['monospace'],
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: AppLocalizations.of(context).copyAddressTooltip,
          icon: const Icon(Icons.copy_rounded, size: 16),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () => onCopy(value),
        ),
      ],
    );
  }
}

/// Single-line tx hash (saves vertical space vs stacked label + box).
class _HashRowCompact extends StatelessWidget {
  final AppLocalizations l10n;
  final String hash;
  final void Function(String) onCopy;

  const _HashRowCompact({required this.l10n, required this.hash, required this.onCopy});

  String _short(String h) {
    if (h.length <= 22) return h;
    return '${h.substring(0, 10)}…${h.substring(h.length - 8)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Text(
            l10n.treasuryHistoryTxHash,
            style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Tooltip(
              message: hash,
              child: Text(
                _short(hash),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: 'monospace',
                  fontFamilyFallback: const ['monospace'],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context).copyAddressTooltip,
            icon: const Icon(Icons.copy_rounded, size: 16),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => onCopy(hash),
          ),
        ],
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final String label;
  final String address;
  final void Function(String) onCopy;

  const _AddressRow({required this.label, required this.address, required this.onCopy});

  String _shortAddr(String a) {
    if (a.length <= 16) return a;
    return '${a.substring(0, 8)}…${a.substring(a.length - 6)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (address.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Tooltip(
            message: address,
            child: Text(
              _shortAddr(address),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontFamily: 'monospace',
                fontFamilyFallback: const ['monospace'],
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: AppLocalizations.of(context).copyAddressTooltip,
          icon: const Icon(Icons.copy_rounded, size: 16),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () => onCopy(address),
        ),
      ],
    );
  }
}

class _TreasuryHistoryFilterBar extends StatelessWidget {
  final TreasuryProvider provider;

  const _TreasuryHistoryFilterBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final menuHeight = MediaQuery.sizeOf(context).height * 0.35;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TreasuryChainDropdown(
                chains: kTreasuryHistoryFilterChainValues,
                value: provider.historyChain,
                allowAllOption: true,
                labelText: l10n.treasuryChainLabel,
                hintText: l10n.treasuryFilterAll,
                menuMaxHeight: menuHeight,
                onChanged: (value) async {
                  provider.setHistoryFilters(
                    chain: value,
                    type: provider.historyType,
                    status: provider.historyStatus,
                    query: provider.historyQuery,
                  );
                  await provider.loadHistory(force: true);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppDropdownField<String?>(
                value: provider.historyType,
                labelText: l10n.treasuryTypeLabel,
                hintText: l10n.treasuryFilterAll,
                menuMaxHeight: menuHeight,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.treasuryFilterAll),
                  ),
                  DropdownMenuItem(value: 'SWEEP', child: Text(l10n.treasuryHistoryTypeSweep)),
                  DropdownMenuItem(value: 'FUND', child: Text(l10n.treasuryHistoryTypeFund)),
                ],
                onChanged: (value) async {
                  provider.setHistoryFilters(
                    chain: provider.historyChain,
                    type: value,
                    status: provider.historyStatus,
                    query: provider.historyQuery,
                  );
                  await provider.loadHistory(force: true);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        DebouncedSearchTextField(
          labelText: l10n.treasuryHistorySearchLabel,
          hintText: l10n.treasurySearchHint,
          initialValue: provider.historyQuery ?? '',
          onDebouncedChanged: (raw) async {
            final q = raw.trim().isEmpty ? null : raw.trim();
            provider.setHistoryFilters(
              chain: provider.historyChain,
              type: provider.historyType,
              status: provider.historyStatus,
              query: q,
            );
            await provider.loadHistory(force: true);
          },
        ),
      ],
    );
  }
}
