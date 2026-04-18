import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/utils/treasury_api_error_localization.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/features/treasury/domain/entities/treasury_model.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/onchain_chain_picker_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/treasury_provider.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/features/treasury/presentation/constants/treasury_chains.dart';
import 'package:crypto_trading_app/core/widgets/app_dropdown_field.dart';
import 'package:crypto_trading_app/core/widgets/debounced_search_text_field.dart';
import 'package:crypto_trading_app/features/treasury/presentation/widgets/treasury_chain_dropdown.dart';
import 'package:crypto_trading_app/core/responsive/app_responsive.dart';

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

String _shortMiddle(String s, {int head = 10, int tail = 8}) {
  if (s.length <= head + tail + 1) return s;
  return '${s.substring(0, head)}…${s.substring(s.length - tail)}';
}

/// Short ticker for treasury history amounts (`USDT` vs native coin for chain).
String _treasuryHistoryAmountTicker(String chain, String? assetCode) {
  final asset = (assetCode ?? 'NATIVE').toUpperCase();
  if (asset == 'USDT_TRC20') return 'USDT';
  final net = BlockchainNetworkX.tryFromApiValue(chain);
  if (net != null) return net.nativeSymbol;
  if (chain.toUpperCase().contains('TRON')) return 'TRX';
  return '';
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

  /// Load the next page only when the user scrolls near the bottom. We intentionally do **not**
  /// auto-chain loads when `maxScrollExtent <= 0` — that used to prefetch every page until the
  /// list became scrollable (bad for large histories). The manual “Load more” button covers short viewports.
  void _maybeLoadMoreFromScrollPosition() {
    if (!mounted || _loadMoreInFlight) return;
    if (!_scrollController.hasClients) return;

    final provider = context.read<TreasuryProvider>();
    if (!provider.hasMoreHistory || provider.isLoadingMoreHistory || provider.isLoadingHistory) {
      return;
    }

    final pos = _scrollController.position;
    final maxExt = pos.maxScrollExtent;
    if (maxExt <= 0) return;
    if (pos.pixels < maxExt * 0.85) return;

    _loadMoreInFlight = true;
    provider.loadMoreHistory().whenComplete(() {
      if (!mounted) return;
      _loadMoreInFlight = false;
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

  bool _showManualHistoryLoadMore(TreasuryProvider provider) {
    if (!provider.hasMoreHistory) return false;
    if (provider.isLoadingMoreHistory || provider.isLoadingHistory) return false;
    if (!_scrollController.hasClients) return true;
    return _scrollController.position.maxScrollExtent < 48;
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
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: _TreasuryHistoryFilterBar(provider: provider),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.loadHistory(force: true),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottomInset),
                  child: NotificationListener<ScrollMetricsNotification>(
                    onNotification: _onScrollMetrics,
                    child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                        if (provider.error != null && provider.error!.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: Material(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: theme.colorScheme.onErrorContainer, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        localizeTreasuryApiError(
                                          l10n,
                                          code: provider.apiErrorCode,
                                          message: provider.error,
                                        ),
                                        style: TextStyle(
                                          color: theme.colorScheme.onErrorContainer,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 12)),
                        ],
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
                            child: _EmptyHint(
                              icon: Icons.inbox_outlined,
                              message: l10n.treasuryNoOperations,
                            ),
                          )
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final op = provider.operations[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
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
                            child: _EmptyHint(
                              icon: Icons.payments_outlined,
                              message: l10n.treasuryNoTransactions,
                            ),
                          )
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final tx = provider.transactions[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
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
                        if (_showManualHistoryLoadMore(provider))
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Center(
                                child: TextButton.icon(
                                  onPressed: provider.isLoadingMoreHistory
                                      ? null
                                      : () => provider.loadMoreHistory(),
                                  icon: const Icon(Icons.expand_more, size: 20),
                                  label: Text(l10n.treasuryHistoryLoadMore),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
    final timeStr = op.createdAt != null ? fmt.format(op.createdAt!.toLocal()) : '—';
    final amountTicker = _treasuryHistoryAmountTicker(op.chain, op.asset);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.9)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TypeChip(l10n: l10n, typeCode: op.type, isFund: isFund),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${op.chain} · $timeStr',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _StatusChip(l10n: l10n, status: op.status),
                          if (op.failureReason != null && op.failureReason!.isNotEmpty)
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: Text(
                                op.failureReason!,
                                style: theme.textTheme.labelSmall?.copyWith(color: scheme.error),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      FormatUtils.formatDecimalAmountDisplay(op.amount),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                    ),
                    if (amountTicker.isNotEmpty)
                      Text(
                        amountTicker,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.65)),
            ),
            _HistoryCopyRow(
              label: l10n.treasuryHistoryIdLabel,
              fullValue: op.operationId,
              displayValue: _shortMiddle(op.operationId, head: 12, tail: 8),
              onCopy: () => onCopy(op.operationId),
            ),
            if (op.txHash != null && op.txHash!.isNotEmpty) ...[
              const SizedBox(height: 4),
              _HistoryCopyRow(
                label: l10n.treasuryHistoryTxHash,
                fullValue: op.txHash!,
                displayValue: _shortMiddle(op.txHash!, head: 10, tail: 8),
                onCopy: () => onCopy(op.txHash!),
              ),
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
    final timeStr = tx.createdAt != null ? fmt.format(tx.createdAt!.toLocal()) : '—';
    final amountTicker = _treasuryHistoryAmountTicker(tx.chain, tx.asset);

    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= AppBreakpoints.compact;
        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: scheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.9)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TypeChip(l10n: l10n, typeCode: tx.type, isFund: isFund),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${tx.chain} · $timeStr',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          _StatusChip(l10n: l10n, status: tx.status),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          FormatUtils.formatDecimalAmountDisplay(tx.amount),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.primary,
                          ),
                        ),
                        if (amountTicker.isNotEmpty)
                          Text(
                            amountTicker,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.65)),
                ),
                _HistoryCopyRow(
                  label: l10n.treasuryHistoryIdLabel,
                  fullValue: tx.txId,
                  displayValue: _shortMiddle(tx.txId, head: 12, tail: 8),
                  onCopy: () => onCopy(tx.txId),
                ),
                const SizedBox(height: 6),
                if (wide && tx.fromAddress.isNotEmpty && tx.toAddress.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _HistoryCopyRow(
                          label: l10n.treasuryHistoryFrom,
                          fullValue: tx.fromAddress,
                          displayValue: _shortMiddle(tx.fromAddress, head: 8, tail: 6),
                          onCopy: () => onCopy(tx.fromAddress),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _HistoryCopyRow(
                          label: l10n.treasuryHistoryTo,
                          fullValue: tx.toAddress,
                          displayValue: _shortMiddle(tx.toAddress, head: 8, tail: 6),
                          onCopy: () => onCopy(tx.toAddress),
                        ),
                      ),
                    ],
                  )
                else ...[
                  if (tx.fromAddress.isNotEmpty)
                    _HistoryCopyRow(
                      label: l10n.treasuryHistoryFrom,
                      fullValue: tx.fromAddress,
                      displayValue: _shortMiddle(tx.fromAddress, head: 10, tail: 8),
                      onCopy: () => onCopy(tx.fromAddress),
                    ),
                  if (tx.fromAddress.isNotEmpty && tx.toAddress.isNotEmpty)
                    const SizedBox(height: 4),
                  if (tx.toAddress.isNotEmpty)
                    _HistoryCopyRow(
                      label: l10n.treasuryHistoryTo,
                      fullValue: tx.toAddress,
                      displayValue: _shortMiddle(tx.toAddress, head: 10, tail: 8),
                      onCopy: () => onCopy(tx.toAddress),
                    ),
                ],
                if (tx.txHash != null && tx.txHash!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _HistoryCopyRow(
                    label: l10n.treasuryHistoryTxHash,
                    fullValue: tx.txHash!,
                    displayValue: _shortMiddle(tx.txHash!, head: 10, tail: 8),
                    onCopy: () => onCopy(tx.txHash!),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TypeChip extends StatelessWidget {
  final AppLocalizations l10n;
  final String typeCode;
  final bool isFund;

  const _TypeChip({
    required this.l10n,
    required this.typeCode,
    required this.isFund,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final label = _treasuryHistoryTypeLabel(l10n, typeCode);
    final Color bg;
    final Color fg;
    if (isFund) {
      bg = scheme.primary.withValues(alpha: 0.14);
      fg = scheme.primary;
    } else {
      bg = scheme.tertiary.withValues(alpha: 0.18);
      fg = scheme.tertiary;
    }
    return Tooltip(
      message: typeCode,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFund ? Icons.south_west : Icons.north_east,
              size: 14,
              color: fg,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: fg,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCopyRow extends StatelessWidget {
  final String label;
  final String fullValue;
  final String displayValue;
  final VoidCallback onCopy;

  const _HistoryCopyRow({
    required this.label,
    required this.fullValue,
    required this.displayValue,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Tooltip(
      message: fullValue,
      child: InkWell(
        onTap: onCopy,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Text(
                  displayValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: 'monospace',
                    fontFamilyFallback: const ['monospace'],
                  ),
                ),
              ),
              Icon(Icons.copy_rounded, size: 15, color: scheme.outline),
            ],
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
      case 'PROCESSING':
        bg = scheme.secondary.withValues(alpha: 0.16);
        fg = scheme.secondary;
        icon = Icons.autorenew;
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
    final tooltipMessage =
        s == 'PENDING' ? l10n.treasuryHistoryStatusQueuedHint : status;
    return Tooltip(
      message: tooltipMessage,
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

class _TreasuryHistoryFilterBar extends StatelessWidget {
  final TreasuryProvider provider;

  const _TreasuryHistoryFilterBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final menuHeight = MediaQuery.sizeOf(context).height * 0.35;
    final chainPicker = context.watch<OnchainChainPickerProvider>();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TreasuryChainDropdown(
                chains: chainPicker.treasuryHistoryFilterChains,
                value: provider.historyChain,
                allowAllOption: true,
                labelText: l10n.treasuryChainLabel,
                hintText: l10n.treasuryFilterAll,
                menuMaxHeight: menuHeight,
                displayLabelForChain: treasuryWalletCreationDisplayLabel,
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
