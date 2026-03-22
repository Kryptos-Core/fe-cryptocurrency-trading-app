import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/data/models/treasury_model.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/app_dropdown_field.dart';

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
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TreasuryProvider>().loadHistory();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
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
        return RefreshIndicator(
          onRefresh: provider.loadHistory,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              _TreasuryHistoryFilterBar(searchCtrl: _searchCtrl, provider: provider),
              if (provider.error != null && provider.error!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Material(
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
              ],
              const SizedBox(height: 16),
              _SectionHeader(
                icon: Icons.settings_suggest_outlined,
                title: l10n.treasuryOperationsTitle,
              ),
              const SizedBox(height: 10),
              if (provider.isLoadingHistory && provider.operations.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (provider.operations.isEmpty)
                _EmptyHint(icon: Icons.inbox_outlined, message: l10n.treasuryNoOperations)
              else
                ...provider.operations.map(
                  (op) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TreasuryOperationTile(
                      l10n: l10n,
                      op: op,
                      onCopy: (s) => _copy(context, s),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              _SectionHeader(
                icon: Icons.receipt_long_outlined,
                title: l10n.treasuryTransactionsTitle,
              ),
              const SizedBox(height: 10),
              if (provider.transactions.isEmpty)
                _EmptyHint(icon: Icons.payments_outlined, message: l10n.treasuryNoTransactions)
              else
                ...provider.transactions.map(
                  (tx) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TreasuryTransactionTile(
                      l10n: l10n,
                      tx: tx,
                      onCopy: (s) => _copy(context, s),
                    ),
                  ),
                ),
            ],
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
        Icon(icon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
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
      padding: const EdgeInsets.symmetric(vertical: 20),
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
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(
                    isFund ? Icons.south_west : Icons.north_east,
                    color: scheme.onPrimaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _TypeChip(l10n: l10n, typeCode: op.type),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              op.chain,
                              style: theme.textTheme.labelLarge?.copyWith(
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
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            fmt.format(op.createdAt!.toLocal()),
                            style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  FormatUtils.formatDecimalAmountDisplay(op.amount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _StatusChip(l10n: l10n, status: op.status),
            if (op.failureReason != null && op.failureReason!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  op.failureReason!,
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
                ),
              ),
            const SizedBox(height: 8),
            _IdRow(label: l10n.treasuryHistoryIdLabel, value: op.operationId, onCopy: onCopy),
            if (op.txHash != null && op.txHash!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _HashRow(l10n: l10n, hash: op.txHash!, onCopy: onCopy),
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
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: scheme.secondaryContainer,
                  child: Icon(
                    isFund ? Icons.south_west : Icons.north_east,
                    color: scheme.onSecondaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _TypeChip(l10n: l10n, typeCode: tx.type),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tx.chain,
                              style: theme.textTheme.labelLarge?.copyWith(
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
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            fmt.format(tx.createdAt!.toLocal()),
                            style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  FormatUtils.formatDecimalAmountDisplay(tx.amount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _StatusChip(l10n: l10n, status: tx.status),
            const SizedBox(height: 8),
            _IdRow(label: l10n.treasuryHistoryIdLabel, value: tx.txId, onCopy: onCopy),
            const SizedBox(height: 6),
            _AddressRow(
              label: l10n.treasuryHistoryFrom,
              address: tx.fromAddress,
              onCopy: onCopy,
            ),
            const SizedBox(height: 4),
            _AddressRow(
              label: l10n.treasuryHistoryTo,
              address: tx.toAddress,
              onCopy: onCopy,
            ),
            if (tx.txHash != null && tx.txHash!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _HashRow(l10n: l10n, hash: tx.txHash!, onCopy: onCopy),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.primary,
            letterSpacing: 0.5,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 44,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              fontFamilyFallback: const ['monospace'],
            ),
          ),
        ),
        IconButton(
          tooltip: AppLocalizations.of(context).copyAddressTooltip,
          icon: const Icon(Icons.copy_rounded, size: 18),
          visualDensity: VisualDensity.compact,
          onPressed: () => onCopy(value),
        ),
      ],
    );
  }
}

class _HashRow extends StatelessWidget {
  final AppLocalizations l10n;
  final String hash;
  final void Function(String) onCopy;

  const _HashRow({required this.l10n, required this.hash, required this.onCopy});

  String _short(String h) {
    if (h.length <= 18) return h;
    return '${h.substring(0, 10)}…${h.substring(h.length - 8)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.treasuryHistoryTxHash,
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  _short(hash),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontFamilyFallback: const ['monospace'],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                tooltip: AppLocalizations.of(context).copyAddressTooltip,
                icon: const Icon(Icons.copy_rounded, size: 18),
                visualDensity: VisualDensity.compact,
                onPressed: () => onCopy(hash),
              ),
            ],
          ),
        ),
      ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: Tooltip(
            message: address,
            child: SelectableText(
              _shortAddr(address),
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontFamilyFallback: const ['monospace'],
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: AppLocalizations.of(context).copyAddressTooltip,
          icon: const Icon(Icons.copy_rounded, size: 18),
          visualDensity: VisualDensity.compact,
          onPressed: () => onCopy(address),
        ),
      ],
    );
  }
}

class _TreasuryHistoryFilterBar extends StatelessWidget {
  final TextEditingController searchCtrl;
  final TreasuryProvider provider;

  const _TreasuryHistoryFilterBar({required this.searchCtrl, required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final menuHeight = MediaQuery.sizeOf(context).height * 0.35;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppDropdownField<String?>(
                value: provider.historyChain,
                labelText: l10n.treasuryChainLabel,
                hintText: l10n.treasuryFilterAll,
                menuMaxHeight: menuHeight,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.treasuryFilterAll),
                  ),
                  const DropdownMenuItem(value: 'TRON_NILE', child: Text('TRON_NILE')),
                  const DropdownMenuItem(value: 'TRON_SHASTA', child: Text('TRON_SHASTA')),
                  const DropdownMenuItem(value: 'ETH_SEPOLIA', child: Text('ETH_SEPOLIA')),
                ],
                onChanged: (value) async {
                  provider.setHistoryFilters(
                    chain: value,
                    type: provider.historyType,
                    status: provider.historyStatus,
                    query: provider.historyQuery,
                  );
                  await provider.loadHistory();
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
                  await provider.loadHistory();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: searchCtrl,
          decoration: InputDecoration(
            labelText: l10n.treasuryHistorySearchLabel,
            hintText: l10n.treasurySearchHint,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                provider.setHistoryFilters(
                  chain: provider.historyChain,
                  type: provider.historyType,
                  status: provider.historyStatus,
                  query: searchCtrl.text.trim().isEmpty ? null : searchCtrl.text.trim(),
                );
                await provider.loadHistory();
              },
            ),
          ),
          onSubmitted: (_) async {
            provider.setHistoryFilters(
              chain: provider.historyChain,
              type: provider.historyType,
              status: provider.historyStatus,
              query: searchCtrl.text.trim().isEmpty ? null : searchCtrl.text.trim(),
            );
            await provider.loadHistory();
          },
        ),
      ],
    );
  }
}
