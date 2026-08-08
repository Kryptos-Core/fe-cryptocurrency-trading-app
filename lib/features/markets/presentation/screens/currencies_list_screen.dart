import 'dart:async';

import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/responsive/app_responsive.dart';
import 'package:crypto_trading_app/core/widgets/app_empty_state.dart';
import 'package:crypto_trading_app/core/widgets/debounced_search_text_field.dart';

import 'package:crypto_trading_app/features/markets/domain/entities/currency.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/currencies_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/screens/currency_detail_screen.dart';
import 'package:crypto_trading_app/features/markets/presentation/widgets/currencies_filter_bar.dart';
import 'package:crypto_trading_app/features/markets/presentation/widgets/currencies_sort_dropdown.dart';
import 'package:crypto_trading_app/features/markets/presentation/widgets/currency_card.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Currencies List Screen
///
/// Displays all currencies with debounced search, two filter rows
/// (status + trading), a sort dropdown and an infinite-scroll list.
///
/// Filter, sort and pagination state all live in [CurrenciesProvider] so the
/// screen can rebuild cleanly on any state change.
class CurrenciesListScreen extends StatefulWidget {
  const CurrenciesListScreen({super.key});

  @override
  State<CurrenciesListScreen> createState() => _CurrenciesListScreenState();
}

class _CurrenciesListScreenState extends State<CurrenciesListScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _autoRefreshTimer;
  bool _isLoadingMore = false;

  /// Minimum scroll extent needed before stopping the prefetch loop. When the
  /// first page is shorter than the viewport, [_onScroll] never fires, so we
  /// have to keep paging until the list overflows.
  static const double _minScrollExtentToSkipPrefetch = 48;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CurrenciesProvider>().fetchCurrencies(refresh: true);
    });
    _scrollController.addListener(_onScroll);

    // Refresh the first page every 30s so prices stay fresh without the user
    // having to pull-to-refresh.
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      context.read<CurrenciesProvider>().fetchCurrencies(refresh: true);
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) return;
    if (position.pixels < position.maxScrollExtent * 0.8) return;
    if (_isLoadingMore) return;

    final provider = context.read<CurrenciesProvider>();
    if (provider.hasMore && !provider.isLoading) {
      _isLoadingMore = true;
      provider.loadMore().whenComplete(() {
        if (mounted) _isLoadingMore = false;
      });
    }
  }

  Future<void> _prefetchUntilScrollableOrDone(CurrenciesProvider provider) async {
    if (!mounted) return;
    if (!provider.hasMore || provider.isLoading) return;
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent >= _minScrollExtentToSkipPrefetch) return;
    await provider.loadMore();
    if (!mounted) return;
    if (provider.error != null) return;
    await _prefetchUntilScrollableOrDone(provider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.currencies),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _Toolbar(
              onSearchChanged: (q) =>
                  context.read<CurrenciesProvider>().setSearch(q),
            ),
            const Divider(height: 1),
            Expanded(
              child: Consumer<CurrenciesProvider>(
                builder: (context, provider, _) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _prefetchUntilScrollableOrDone(provider);
                  });
                  return _buildBody(context, provider, l10n);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CurrenciesProvider provider,
    AppLocalizations l10n,
  ) {
    if (provider.isLoading && provider.currencies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.currencies.isEmpty) {
      return AppEmptyState(
        icon: Icons.error_outline,
        title: l10n.currenciesNoCurrenciesFound,
        message: provider.error!,
        action: () => provider.fetchCurrencies(refresh: true),
        actionLabel: l10n.currenciesRetryAction,
      );
    }

    final items = provider.sortedCurrencies;
    if (items.isEmpty) {
      if (provider.hasActiveFilter) {
        return AppEmptyState(
          icon: Icons.filter_alt_off_outlined,
          message: l10n.currenciesEmptyFiltered,
          action: () => provider.clearFilters(),
          actionLabel: l10n.currenciesClearFilters,
        );
      }
      return AppEmptyState(
        icon: Icons.inbox_outlined,
        message: l10n.currenciesNoCurrenciesFound,
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchCurrencies(refresh: true),
      child: _CurrencyList(
        scrollController: _scrollController,
        items: items,
        hasMore: provider.hasMore,
        isLoading: provider.isLoading,
        provider: provider,
        onCardTap: (currency) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CurrencyDetailScreen(
                currencyId: currency.currencyId,
                initialCurrency: currency,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.onSearchChanged});

  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final provider = context.watch<CurrenciesProvider>();

    CurrencyStatusFilter statusFilter;
    if (provider.filterIsActive == true) {
      statusFilter = CurrencyStatusFilter.activeOnly;
    } else if (provider.filterIsActive == false) {
      statusFilter = CurrencyStatusFilter.inactiveOnly;
    } else if (provider.includeInactive) {
      statusFilter = CurrencyStatusFilter.all;
    } else {
      statusFilter = CurrencyStatusFilter.activeOnly;
    }

    CurrencyTradingFilter tradingFilter;
    if (provider.filterTradable == true) {
      tradingFilter = CurrencyTradingFilter.tradableOnly;
    } else if (provider.filterTradable == false) {
      tradingFilter = CurrencyTradingFilter.pausedOnly;
    } else {
      tradingFilter = CurrencyTradingFilter.all;
    }

    return Container(
      color: scheme.surface,
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: DebouncedSearchTextField(
              hintText: l10n.currenciesSearchHint,
              onDebouncedChanged: onSearchChanged,
            ),
          ),
          CurrenciesFilterBar(
            statusFilter: statusFilter,
            tradingFilter: tradingFilter,
            shownCount: provider.sortedCurrencies.length,
            totalCount: provider.total,
            hasActiveFilter: provider.hasActiveFilter,
            onStatusFilterChanged: (next) {
              switch (next) {
                case CurrencyStatusFilter.all:
                  provider.setStatusFilter(isActive: null);
                  break;
                case CurrencyStatusFilter.activeOnly:
                  provider.setStatusFilter(isActive: true);
                  break;
                case CurrencyStatusFilter.inactiveOnly:
                  provider.setStatusFilter(isActive: false);
                  break;
              }
            },
            onTradingFilterChanged: (next) {
              switch (next) {
                case CurrencyTradingFilter.all:
                  provider.setTradingFilter(isTradable: null);
                  break;
                case CurrencyTradingFilter.tradableOnly:
                  provider.setTradingFilter(isTradable: true);
                  break;
                case CurrencyTradingFilter.pausedOnly:
                  provider.setTradingFilter(isTradable: false);
                  break;
              }
            },
            onClearFilters: () => provider.clearFilters(),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: CurrenciesSortDropdown(
                    value: provider.sortMode,
                    onChanged: provider.setSortMode,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyList extends StatelessWidget {
  const _CurrencyList({
    required this.scrollController,
    required this.items,
    required this.hasMore,
    required this.isLoading,
    required this.provider,
    required this.onCardTap,
  });

  final ScrollController scrollController;
  final List<Currency> items;
  final bool hasMore;
  final bool isLoading;
  final CurrenciesProvider provider;
  final ValueChanged<Currency> onCardTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final useGrid = AppBreakpoints.isTwoColumnGrid(width);

    final itemCount = items.length + (hasMore ? 1 : 0);

    if (useGrid) {
      return GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.only(bottom: 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 4,
          mainAxisExtent: 96,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == items.length) {
            return _LoadMoreFooter(hasMore: hasMore, isLoading: isLoading);
          }
          final currency = items[index];
          return CurrencyCard(
            currency: currency,
            variant: CurrencyCardVariant.compact,
            showStatus: false,
            onTap: () => onCardTap(currency),
          );
        },
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == items.length) {
          return _LoadMoreFooter(hasMore: hasMore, isLoading: isLoading);
        }
        final currency = items[index];
        return CurrencyCard(
          currency: currency,
          variant: CurrencyCardVariant.full,
          onTap: () => onCardTap(currency),
        );
      },
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({required this.hasMore, required this.isLoading});

  final bool hasMore;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!hasMore && !isLoading) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.currenciesLoadingMore,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
