import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/utils/currency_amount_input.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/core/widgets/app_empty_state.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/markets/domain/dtos/create_currency_dto.dart';
import 'package:crypto_trading_app/features/markets/domain/dtos/update_currency_dto.dart';
import 'package:crypto_trading_app/features/markets/domain/entities/currency.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/currencies_provider.dart';

/// Admin screen for browsing and managing currencies/coins.
///
/// Role-aware:
///  - ADMIN / currencies:manage → full CRUD (create, edit, delete, toggle switches)
///  - RISK_OFFICER / SUPPORT_AGENT → read-only list with search, filters, expandable
///    detail panel, copy-symbol quick action and stats summary.
class AdminCurrenciesScreen extends StatefulWidget {
  const AdminCurrenciesScreen({super.key});

  @override
  State<AdminCurrenciesScreen> createState() => _AdminCurrenciesScreenState();
}

// Status filter values
enum _StatusFilter { all, active, inactive }

// Trading filter values
enum _TradableFilter { all, tradable, paused }

class _AdminCurrenciesScreenState extends State<AdminCurrenciesScreen> {
  final _scrollController = ScrollController();
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  // Local filter state — drives the provider
  _StatusFilter _statusFilter = _StatusFilter.all;
  _TradableFilter _tradableFilter = _TradableFilter.all;

  // Currently expanded currency id (inline detail panel)
  String? _expandedCurrencyId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CurrenciesProvider>().loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _applyFilters);
  }

  void _applyFilters() {
    final provider = context.read<CurrenciesProvider>();
    bool? isActive;
    bool includeInactive = true;

    switch (_statusFilter) {
      case _StatusFilter.all:
        includeInactive = true;
        isActive = null;
      case _StatusFilter.active:
        includeInactive = false;
        isActive = null;
      case _StatusFilter.inactive:
        includeInactive = true;
        isActive = false;
    }

    bool? isTradable;
    switch (_tradableFilter) {
      case _TradableFilter.all:
        isTradable = null;
      case _TradableFilter.tradable:
        isTradable = true;
      case _TradableFilter.paused:
        isTradable = false;
    }

    provider.applyFilters(
      search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      isActive: isActive,
      isTradable: isTradable,
      includeInactive: includeInactive,
    );
  }

  void _setStatusFilter(_StatusFilter f) {
    if (_statusFilter == f) return;
    setState(() => _statusFilter = f);
    _applyFilters();
  }

  void _setTradableFilter(_TradableFilter f) {
    if (_tradableFilter == f) return;
    setState(() => _tradableFilter = f);
    _applyFilters();
  }

  void _toggleExpanded(String currencyId) {
    setState(() {
      _expandedCurrencyId =
          _expandedCurrencyId == currencyId ? null : currencyId;
    });
  }

  Future<void> _refresh() async {
    final provider = context.read<CurrenciesProvider>();
    await provider.fetchCurrencies(refresh: true);
  }

  void _copySymbol(BuildContext context, String symbol) {
    final l10n = AppLocalizations.of(context);
    Clipboard.setData(ClipboardData(text: symbol));
    showAppSnackBar(
      context,
      message: l10n.adminCurrenciesCopySymbolDone(symbol),
      type: SnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthProvider>();
    final canManage = auth.canManageCurrencies;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.adminCurrenciesTitle),
            if (!canManage)
              Text(
                l10n.adminCurrenciesReadOnlySubtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
              ),
          ],
        ),
        titleSpacing: 16,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: l10n.adminCurrenciesRefreshTooltip,
          ),
          Consumer<CurrenciesProvider>(
            builder: (_, p, __) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('${p.total}'),
                visualDensity: VisualDensity.compact,
                avatar: const Icon(Icons.monetization_on_outlined, size: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Search bar ──────────────────────────────────────────────
          _buildSearchBar(context),

          // ── Filter chips ────────────────────────────────────────────
          _buildFilterChips(context),

          // ── Read-only banner (Risk Officer / Support) ──────────────
          if (!canManage) _buildReadOnlyBanner(context),

          // ── Stats summary ───────────────────────────────────────────
          _buildStatsSummary(context),

          const Divider(height: 1),

          // ── List ────────────────────────────────────────────────────
          Expanded(child: _buildList(context, canManage)),
        ],
      ),

      // FAB only for users who can manage currencies
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateSheet(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.adminCurrenciesCreateCoin),
            )
          : null,
    );
  }

  // ── Toolbar ───────────────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) {
          setState(() {});
          _onSearchChanged(v);
        },
        decoration: InputDecoration(
          hintText: l10n.adminCurrenciesSearchHint,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchCtrl.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    _applyFilters();
                    setState(() {});
                  },
                ),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: Text(l10n.adminCurrenciesStatusLabel),
                  selected: false,
                  visualDensity: VisualDensity.compact,
                  showCheckmark: false,
                  onSelected: null,
                ),
                const SizedBox(width: 6),
                FilterChip(
                  label: Text(l10n.adminCurrenciesFilterAll),
                  selected: _statusFilter == _StatusFilter.all,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) => _setStatusFilter(_StatusFilter.all),
                ),
                const SizedBox(width: 6),
                FilterChip(
                  label: Text(l10n.adminCurrenciesFilterActive),
                  selected: _statusFilter == _StatusFilter.active,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) => _setStatusFilter(_StatusFilter.active),
                ),
                const SizedBox(width: 6),
                FilterChip(
                  label: Text(l10n.adminCurrenciesFilterInactive),
                  selected: _statusFilter == _StatusFilter.inactive,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) => _setStatusFilter(_StatusFilter.inactive),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: Text(l10n.adminCurrenciesTradingLabel),
                  selected: false,
                  visualDensity: VisualDensity.compact,
                  showCheckmark: false,
                  onSelected: null,
                ),
                const SizedBox(width: 6),
                FilterChip(
                  label: Text(l10n.adminCurrenciesFilterAll),
                  selected: _tradableFilter == _TradableFilter.all,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) => _setTradableFilter(_TradableFilter.all),
                ),
                const SizedBox(width: 6),
                FilterChip(
                  label: Text(l10n.adminCurrenciesFilterTradable),
                  selected: _tradableFilter == _TradableFilter.tradable,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) =>
                      _setTradableFilter(_TradableFilter.tradable),
                ),
                const SizedBox(width: 6),
                FilterChip(
                  label: Text(l10n.adminCurrenciesFilterPaused),
                  selected: _tradableFilter == _TradableFilter.paused,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) => _setTradableFilter(_TradableFilter.paused),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Card(
        margin: EdgeInsets.zero,
        color: colorScheme.secondaryContainer.withValues(alpha: 0.35),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.secondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.adminCurrenciesReadOnlyBanner,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSummary(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<CurrenciesProvider>(
      builder: (_, provider, __) {
        if (provider.total == 0 && provider.currencies.isEmpty) {
          return const SizedBox.shrink();
        }
        // Local breakdown based on currently-loaded items (provider total
        // doesn't break down by status, so we approximate from the in-memory
        // list — accurate enough for the summary banner).
        var active = 0, inactive = 0, tradable = 0, paused = 0;
        for (final c in provider.currencies) {
          if (c.isActive) {
            active++;
          } else {
            inactive++;
          }
          if (c.isTradable) {
            tradable++;
          } else {
            paused++;
          }
        }
        // Prefer backend total when available.
        final total = provider.total > 0 ? provider.total : provider.currencies.length;
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
          child: Row(
            children: [
              Icon(
                Icons.insights_outlined,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.adminCurrenciesCountSummary(
                    total,
                    active,
                    inactive,
                    tradable,
                    paused,
                  ),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── List ──────────────────────────────────────────────────────────────────

  Widget _buildList(BuildContext context, bool canManage) {
    return Consumer<CurrenciesProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.currencies.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.currencies.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline,
            title: AppLocalizations.of(context).adminCurrenciesRetryAction,
            message: provider.error!,
            action: _refresh,
            actionLabel: AppLocalizations.of(context).adminCurrenciesRetryAction,
          );
        }

        if (!provider.isLoading && provider.currencies.isEmpty) {
          return AppEmptyState(
            icon: Icons.search_off_outlined,
            message: AppLocalizations.of(context).adminCurrenciesNoCoinsFound,
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            itemCount: provider.currencies.length +
                (provider.hasMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              if (i >= provider.currencies.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final currency = provider.currencies[i];
              return _CurrencyCard(
                currency: currency,
                canManage: canManage,
                expanded: _expandedCurrencyId == currency.currencyId,
                onToggleExpand: () => _toggleExpanded(currency.currencyId),
                onCopySymbol: () => _copySymbol(context, currency.symbol),
                onToggleActive: canManage
                    ? (v) => _handleToggle(
                          context,
                          () => provider.toggleActive(currency.currencyId, v),
                        )
                    : null,
                onToggleTradable: canManage
                    ? (v) => _handleToggle(
                          context,
                          () => provider.toggleTradable(currency.currencyId, v),
                        )
                    : null,
                onEdit: canManage
                    ? () => _showEditSheet(context, currency)
                    : null,
                onDelete: canManage
                    ? () => _confirmDelete(context, currency)
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _handleToggle(
    BuildContext context,
    Future<String?> Function() action,
  ) async {
    final err = await action();
    if (!context.mounted) return;
    if (err != null) {
      showAppSnackBar(context, message: err, type: SnackBarType.error);
    }
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CurrencyFormSheet(
        title: AppLocalizations.of(context).adminCurrenciesCreateTitle,
        onSubmit: (dto) async {
          final provider = context.read<CurrenciesProvider>();
          final err = await provider.createCurrency(dto);
          if (!context.mounted) return err;
          if (err != null) return err;
          Navigator.pop(context);
          showAppSnackBar(
            context,
            message: AppLocalizations.of(context).adminCurrenciesCreateSuccess,
            type: SnackBarType.success,
          );
          return null;
        },
      ),
    );
  }

  void _showEditSheet(BuildContext context, Currency currency) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CurrencyEditSheet(
        currency: currency,
        onSubmit: (dto) async {
          final provider = context.read<CurrenciesProvider>();
          final err = await provider.updateCurrency(currency.currencyId, dto);
          if (!context.mounted) return err;
          if (err != null) return err;
          Navigator.pop(context);
          showAppSnackBar(
            context,
            message: AppLocalizations.of(context).adminCurrenciesUpdateSuccess,
            type: SnackBarType.success,
          );
          return null;
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Currency currency) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.adminCurrenciesDeleteTitle),
        content: Text(
          l10n.adminCurrenciesDeleteConfirmWithPair(currency.symbol, currency.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.adminCurrenciesCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final provider = context.read<CurrenciesProvider>();
              final err = await provider.deleteCurrency(currency.currencyId);
              if (!context.mounted) return;
              if (err != null) {
                showAppSnackBar(context,
                    message: err, type: SnackBarType.error);
              } else {
                showAppSnackBar(
                  context,
                  message: l10n.adminCurrenciesDeleteSuccess,
                  type: SnackBarType.success,
                );
              }
            },
            child: Text(l10n.adminCurrenciesDeleteAction),
          ),
        ],
      ),
    );
  }
}

// ── Currency Card (expandable) ──────────────────────────────────────────────

class _CurrencyCard extends StatelessWidget {
  final Currency currency;
  final bool canManage;
  final bool expanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onCopySymbol;
  final ValueChanged<bool>? onToggleActive;
  final ValueChanged<bool>? onToggleTradable;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CurrencyCard({
    required this.currency,
    required this.canManage,
    required this.expanded,
    required this.onToggleExpand,
    required this.onCopySymbol,
    this.onToggleActive,
    this.onToggleTradable,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = currency.isActive;
    final isTradable = currency.isTradable;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: expanded
              ? colorScheme.primary.withValues(alpha: 0.4)
              : colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onToggleExpand,
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, l10n, colorScheme, isActive, isTradable),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: expanded
                    ? _buildDetail(context, l10n, colorScheme)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    bool isActive,
    bool isTradable,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: isActive
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          child: Text(
            currency.symbol.length > 4
                ? currency.symbol.substring(0, 4)
                : currency.symbol,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isActive
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      currency.symbol,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isActive ? null : colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (!isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        l10n.adminCurrenciesHide,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                currency.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _StatusBadge(
                    icon: isTradable
                        ? Icons.swap_horiz
                        : Icons.pause_circle_outline,
                    label: isTradable
                        ? l10n.adminCurrenciesTradableBadgeOn
                        : l10n.adminCurrenciesTradableBadgeOff,
                    color: isTradable ? Colors.green : colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isActive ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color:
                        isActive ? Colors.green : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.adminCurrenciesListMeta(
                      currency.precisionScale.toString(),
                      FormatUtils.formatDecimalAmountForScale(
                        currency.minWithdraw,
                        currency.precisionScale,
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          expanded ? Icons.expand_less : Icons.expand_more,
          color: colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildDetail(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 12),
          // Quick-action row: copy symbol
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onCopySymbol,
                icon: const Icon(Icons.copy_outlined, size: 16),
                label: Text(l10n.adminCurrenciesDetailCopySymbol),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const Spacer(),
              if (canManage && (onEdit != null || onDelete != null))
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        tooltip: l10n.adminCurrenciesEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: onEdit,
                      ),
                    if (onDelete != null)
                      IconButton(
                        tooltip: l10n.adminCurrenciesDeleteAction,
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: Colors.red),
                        onPressed: onDelete,
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          _DetailRow(
            label: l10n.adminCurrenciesDetailPrecision,
            value: currency.precisionScale.toString(),
          ),
          const SizedBox(height: 8),
          _DetailRow(
            label: l10n.adminCurrenciesDetailMinWithdraw,
            value: FormatUtils.formatDecimalAmountForScale(
              currency.minWithdraw,
              currency.precisionScale,
            ),
          ),
          const SizedBox(height: 8),
          _DetailRow(
            label: l10n.adminCurrenciesDetailStatus,
            value: currency.isActive
                ? l10n.adminCurrenciesStatusActive
                : l10n.adminCurrenciesStatusInactive,
            valueColor: currency.isActive ? Colors.green : colorScheme.error,
          ),
          const SizedBox(height: 8),
          _DetailRow(
            label: l10n.adminCurrenciesDetailTrading,
            value: currency.isTradable
                ? l10n.adminCurrenciesStatusTradable
                : l10n.adminCurrenciesStatusPaused,
            valueColor:
                currency.isTradable ? Colors.green : colorScheme.onSurfaceVariant,
          ),
          if (currency.createdAt != null) ...[
            const SizedBox(height: 8),
            _DetailRow(
              label: l10n.adminCurrenciesDetailCreatedAt,
              value: currency.createdAt!,
            ),
          ],
          if (currency.updatedAt != null) ...[
            const SizedBox(height: 8),
            _DetailRow(
              label: l10n.adminCurrenciesDetailUpdatedAt,
              value: currency.updatedAt!,
            ),
          ],
          if (canManage) ...[
            const SizedBox(height: 14),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: currency.isTradable,
              onChanged: onToggleTradable,
              title: Text(l10n.adminCurrenciesTradableLabel),
              dense: true,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: currency.isActive,
              onChanged: onToggleActive,
              title: Text(l10n.adminCurrenciesActiveLabel),
              dense: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Create Currency Sheet ────────────────────────────────────────────────────

class _CurrencyFormSheet extends StatefulWidget {
  final String title;
  final Future<String?> Function(CreateCurrencyDto) onSubmit;

  const _CurrencyFormSheet({
    required this.title,
    required this.onSubmit,
  });

  @override
  State<_CurrencyFormSheet> createState() => _CurrencyFormSheetState();
}

class _CurrencyFormSheetState extends State<_CurrencyFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _symbolCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _precisionCtrl = TextEditingController(text: '8');
  final _minWithdrawCtrl = TextEditingController(text: '0');
  bool _isTradable = true;
  bool _isActive = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _symbolCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _symbolCtrl.dispose();
    _nameCtrl.dispose();
    _precisionCtrl.dispose();
    _minWithdrawCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final dto = CreateCurrencyDto(
      symbol: _symbolCtrl.text.trim().toUpperCase(),
      name: _nameCtrl.text.trim(),
      precisionScale: int.tryParse(_precisionCtrl.text.trim()),
      minWithdraw: _minWithdrawCtrl.text.trim().isEmpty
          ? null
          : _minWithdrawCtrl.text.trim(),
      isTradable: _isTradable,
      isActive: _isActive,
    );
    final err = await widget.onSubmit(dto);
    if (mounted && err != null) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.adminCurrenciesSectionBasic,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _symbolCtrl,
                decoration: InputDecoration(
                  labelText: '${l10n.adminCurrenciesSymbolLabel} *',
                  hintText: 'BTC',
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? l10n.adminCurrenciesFieldRequired
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: '${l10n.adminCurrenciesNameInputLabel} *',
                  hintText: 'Bitcoin',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? l10n.adminCurrenciesFieldRequired
                        : null,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.adminCurrenciesSectionTrading,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _precisionCtrl,
                decoration: InputDecoration(
                  labelText: l10n.adminCurrenciesPrecisionScaleLabel,
                  hintText: '8',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _minWithdrawCtrl,
                decoration: CurrencyAmountInput.withCurrencySuffix(
                  context,
                  InputDecoration(
                    labelText: l10n.adminCurrenciesMinWithdrawLabel,
                    hintText: '0.001',
                    border: const OutlineInputBorder(),
                  ),
                  currencySymbol: _symbolCtrl.text.trim().toUpperCase(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.adminCurrenciesSectionStatus,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isTradable,
                onChanged: (v) => setState(() => _isTradable = v),
                title: Text(l10n.adminCurrenciesTradableLabel),
                dense: true,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                title: Text(l10n.adminCurrenciesActiveLabel),
                dense: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSubmitting ? null : () => Navigator.pop(context),
                      child: Text(l10n.adminCurrenciesCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            )
                          : Text(l10n.adminCurrenciesCreateAction),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Edit Currency Sheet ──────────────────────────────────────────────────────

class _CurrencyEditSheet extends StatefulWidget {
  final Currency currency;
  final Future<String?> Function(UpdateCurrencyDto) onSubmit;

  const _CurrencyEditSheet({
    required this.currency,
    required this.onSubmit,
  });

  @override
  State<_CurrencyEditSheet> createState() => _CurrencyEditSheetState();
}

class _CurrencyEditSheetState extends State<_CurrencyEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _precisionCtrl;
  late final TextEditingController _minWithdrawCtrl;
  late bool _isTradable;
  late bool _isActive;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final c = widget.currency;
    _nameCtrl = TextEditingController(text: c.name);
    _precisionCtrl =
        TextEditingController(text: c.precisionScale.toString());
    _minWithdrawCtrl = TextEditingController(text: c.minWithdraw);
    _isTradable = c.isTradable;
    _isActive = c.isActive;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _precisionCtrl.dispose();
    _minWithdrawCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final dto = UpdateCurrencyDto(
      name: _nameCtrl.text.trim(),
      precisionScale: int.tryParse(_precisionCtrl.text.trim()),
      minWithdraw: _minWithdrawCtrl.text.trim().isEmpty
          ? null
          : _minWithdrawCtrl.text.trim(),
      isTradable: _isTradable,
      isActive: _isActive,
    );
    final err = await widget.onSubmit(dto);
    if (mounted && err != null) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                l10n.adminCurrenciesEditTitle(widget.currency.symbol),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.adminCurrenciesSectionBasic,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: l10n.adminCurrenciesNameInputLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? l10n.adminCurrenciesFieldRequired
                        : null,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.adminCurrenciesSectionTrading,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _precisionCtrl,
                decoration: InputDecoration(
                  labelText: l10n.adminCurrenciesPrecisionScaleLabel,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _minWithdrawCtrl,
                decoration: CurrencyAmountInput.withCurrencySuffix(
                  context,
                  InputDecoration(
                    labelText: l10n.adminCurrenciesMinWithdrawLabel,
                    border: const OutlineInputBorder(),
                  ),
                  currencySymbol: widget.currency.symbol,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.adminCurrenciesSectionStatus,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isTradable,
                onChanged: (v) => setState(() => _isTradable = v),
                title: Text(l10n.adminCurrenciesTradableLabel),
                dense: true,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                title: Text(l10n.adminCurrenciesActiveLabel),
                dense: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSubmitting ? null : () => Navigator.pop(context),
                      child: Text(l10n.adminCurrenciesCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            )
                          : Text(l10n.adminCurrenciesSaveAction),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}