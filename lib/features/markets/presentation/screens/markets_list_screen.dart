import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/app/di/injection_container.dart';
import 'package:crypto_trading_app/core/responsive/app_responsive.dart';
import 'package:crypto_trading_app/features/markets/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/features/trading/presentation/providers/chart_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/currencies_provider.dart';
import 'package:crypto_trading_app/core/widgets/app_dropdown_field.dart';
import 'package:crypto_trading_app/features/markets/presentation/widgets/market_row.dart';
import 'package:crypto_trading_app/features/markets/presentation/widgets/market_search_bar.dart';
import 'package:crypto_trading_app/features/markets/presentation/screens/market_detail_screen.dart';
import 'package:crypto_trading_app/features/admin/markets/presentation/screens/admin_markets_screen.dart';

/// Markets List Screen
/// Displays list of all market pairs with search (as-you-type) and filters.
///
/// [showAppBar] — set to `true` when pushed as a standalone route (e.g. from
/// the Dashboard "See All" button) so that the AppBar back-button is visible.
/// Leave `false` (default) when embedded as a tab inside MainScreen, which
/// provides its own AppBar.
class MarketsListScreen extends StatefulWidget {
  final bool showAppBar;

  const MarketsListScreen({super.key, this.showAppBar = false});

  @override
  State<MarketsListScreen> createState() => _MarketsListScreenState();
}

class _MarketsListScreenState extends State<MarketsListScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<MarketSearchBarState> _searchBarKey =
      GlobalKey<MarketSearchBarState>();
  bool _isLoadingMore = false;
  bool _fallbackTickersRequested = false;

  /// When the first page is shorter than the viewport, [maxScrollExtent] stays 0
  /// and the user cannot scroll — so [_onScroll] never fires and [loadMore] is
  /// never called. Prefetch until the list can scroll or there is no more data.
  static const double _minScrollExtentToSkipPrefetch = 48;

  MarketsProvider? _marketsProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<MarketsProvider>();
      _marketsProvider = provider;
      provider.addListener(_onMarketsProviderChanged);
      context.read<CurrenciesProvider>().fetchTradableCurrencies();
      // One request: GET /markets?includeTickers=true returns markets + tickers for current page (avoids slow GET /markets/tickers/all timeout).
      provider.fetchMarkets(refresh: true, includeTickers: true);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onMarketsProviderChanged() {
    if (!mounted) return;
    final p = _marketsProvider;
    if (p == null || p.isLoading) return;
    _schedulePrefetchIfListDoesNotScroll();
  }

  void _schedulePrefetchIfListDoesNotScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _prefetchUntilScrollableOrDone();
    });
  }

  Future<void> _prefetchUntilScrollableOrDone() async {
    if (!mounted) return;
    final provider = _marketsProvider ?? context.read<MarketsProvider>();
    if (!provider.hasMore || provider.isLoading) return;
    if (!_scrollController.hasClients) {
      _schedulePrefetchIfListDoesNotScroll();
      return;
    }
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent >= _minScrollExtentToSkipPrefetch) return;

    await provider.loadMore();
    if (!mounted) return;
    if (provider.error != null) return;
    _prefetchUntilScrollableOrDone();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) return;
    if (_scrollController.position.pixels < maxExtent * 0.8) return;
    if (!_isLoadingMore) {
      final provider = context.read<MarketsProvider>();
      if (provider.hasMore && !provider.isLoading) {
        _isLoadingMore = true;
        provider.loadMore().then((_) {
          if (mounted) _isLoadingMore = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _marketsProvider?.removeListener(_onMarketsProviderChanged);
    _marketsProvider = null;
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _maybeFetchTickersFallback(MarketsProvider provider) {
    if (_fallbackTickersRequested) return;
    if (provider.markets.isEmpty) return;
    final hasMeaningfulTicker = provider.allTickers.any((t) {
      final p = double.tryParse(t.lastPrice);
      final v = double.tryParse(t.volume24h);
      return (p != null && p != 0) || (v != null && v != 0);
    });
    if (hasMeaningfulTicker) return;
    _fallbackTickersRequested = true;
    final pairIds = provider.markets.take(15).map((m) => m.pairId).toList();
    if (pairIds.isEmpty) return;
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      context.read<MarketsProvider>().fetchTickersForPairs(pairIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final marketsBody = _buildMarketsBody(l10n);
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(title: Text(l10n.markets)) : null,
      body: widget.showAppBar
          ? AppCenteredContent(child: marketsBody)
          : marketsBody,
    );
  }

  Widget _buildMarketsBody(AppLocalizations l10n) {
    return Consumer<MarketsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.markets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.markets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.fetchMarkets(refresh: true);
                  },
                  child: Text(l10n.retry),
                ),
              ],
            ),
          );
        }

        if (provider.markets.isNotEmpty) {
          _maybeFetchTickersFallback(provider);
        }

        final tickerByPairId = {
          for (final t in provider.allTickers)
            if (t.pairId.isNotEmpty) t.pairId: t
        };

        return Column(
          children: [
            _buildSearchAndFilters(context, provider, l10n),
            if (provider.isLoading && provider.markets.isNotEmpty)
              LinearProgressIndicator(
                minHeight: 2,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (provider.markets.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(l10n.noMarkets, textAlign: TextAlign.center),
                          if (provider.hasActiveFilter) ...[
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () {
                                _searchBarKey.currentState?.clear();
                                provider.clearSearchAndFilters();
                              },
                              icon: const Icon(Icons.filter_alt_off, size: 18),
                              label: Text(l10n.clearFilters),
                            ),
                          ] else if (context
                              .read<AuthProvider>()
                              .canSyncExchange) ...[
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AdminMarketsScreen(),
                                ),
                              ),
                              icon: const Icon(Icons.sync, size: 18),
                              label: Text(l10n.syncBinance),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  final twoCol =
                      AppBreakpoints.isTwoColumnGrid(constraints.maxWidth);
                  final tail = provider.hasMore && provider.isLoading ? 1 : 0;
                  final itemCount = provider.markets.length + tail;

                  const scrollPhysics = AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  );
                  return RefreshIndicator(
                    onRefresh: () async {
                      _isLoadingMore = false;
                      _fallbackTickersRequested = false;
                      await provider.refreshKeepingPosition();
                    },
                    child: twoCol
                        ? GridView.builder(
                            controller: _scrollController,
                            physics: scrollPhysics,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 120,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 4,
                            ),
                            itemCount: itemCount,
                            itemBuilder: (context, index) {
                              if (index >= provider.markets.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final market = provider.markets[index];
                              final ticker = tickerByPairId[market.pairId];
                              return _marketRow(
                                context,
                                market: market,
                                ticker: ticker,
                                denseLayout: true,
                              );
                            },
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            physics: scrollPhysics,
                            itemCount: itemCount,
                            itemBuilder: (context, index) {
                              if (index >= provider.markets.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final market = provider.markets[index];
                              final ticker = tickerByPairId[market.pairId];
                              return _marketRow(
                                context,
                                market: market,
                                ticker: ticker,
                                denseLayout: false,
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _marketRow(
    BuildContext context, {
    required MarketPair market,
    required MarketTicker? ticker,
    required bool denseLayout,
  }) {
    return MarketRow(
      market: market,
      ticker: ticker,
      denseLayout: denseLayout,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (_) => sl<ChartProvider>(),
              child: MarketDetailScreen(
                pairId: market.pairId,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilters(
    BuildContext context,
    MarketsProvider provider,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wideFilters =
            AppBreakpoints.isMediumOrWider(constraints.maxWidth);
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MarketSearchBar(
                key: _searchBarKey,
                hintText: l10n.searchMarketsHint,
                initialValue: provider.searchQuery,
                onDebouncedSearch: provider.setSearchQuery,
              ),
              const SizedBox(height: 10),
              if (wideFilters) ...[
                Row(
                  children: [
                    Expanded(
                      child: _BaseFilterDropdown(
                        selectedBaseSymbol: provider.filterBaseSymbol,
                        onSelected: provider.setFilterBaseSymbol,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuoteFilterDropdown(
                        selectedQuoteSymbol: provider.filterQuoteSymbol,
                        onSelected: provider.setFilterQuoteSymbol,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SortDropdown(
                        selected: provider.sortOption,
                        onSelected: provider.setSortOption,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilterChip(
                      label: Text(l10n.marketsFuzzySearch),
                      selected: provider.fuzzySearch,
                      onSelected: provider.setFuzzySearch,
                    ),
                    Text(
                      provider.total > 0
                          ? '${provider.markets.length}/${provider.total} ${l10n.marketsResultSuffix}'
                          : '${provider.markets.length} ${l10n.marketsResultSuffix}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (provider.hasActiveFilter)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          _searchBarKey.currentState?.clear();
                          provider.clearSearchAndFilters();
                        },
                        icon: const Icon(Icons.filter_alt_off, size: 18),
                        label: Text(l10n.clearFilters),
                      ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: _BaseFilterDropdown(
                        selectedBaseSymbol: provider.filterBaseSymbol,
                        onSelected: provider.setFilterBaseSymbol,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuoteFilterDropdown(
                        selectedQuoteSymbol: provider.filterQuoteSymbol,
                        onSelected: provider.setFilterQuoteSymbol,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _SortDropdown(
                        selected: provider.sortOption,
                        onSelected: provider.setSortOption,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          FilterChip(
                            label: Text(l10n.marketsFuzzySearch),
                            selected: provider.fuzzySearch,
                            onSelected: provider.setFuzzySearch,
                          ),
                          Text(
                            provider.total > 0
                                ? '${provider.markets.length}/${provider.total} ${l10n.marketsResultSuffix}'
                                : '${provider.markets.length} ${l10n.marketsResultSuffix}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (provider.hasActiveFilter)
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () {
                                _searchBarKey.currentState?.clear();
                                provider.clearSearchAndFilters();
                              },
                              icon: const Icon(Icons.filter_alt_off, size: 18),
                              label: Text(l10n.clearFilters),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Dropdown for quote currency filter; options from API (tradable currencies).
class _QuoteFilterDropdown extends StatelessWidget {
  final String? selectedQuoteSymbol;
  final void Function(String?) onSelected;

  const _QuoteFilterDropdown({
    required this.selectedQuoteSymbol,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<CurrenciesProvider>(
      builder: (context, currenciesProvider, _) {
        final options = currenciesProvider.tradableCurrencies;
        final symbols = options.map((c) => c.symbol).toList();
        symbols.sort();
        return AppDropdownField<String>(
          value: selectedQuoteSymbol != null &&
                  symbols.contains(selectedQuoteSymbol)
              ? selectedQuoteSymbol
              : null,
          menuMaxHeight: MediaQuery.of(context).size.height * 0.45,
          labelText: l10n.filterQuote,
          hintText: l10n.filterQuoteAll,
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(l10n.filterQuoteAll),
            ),
            ...symbols.map((symbol) => DropdownMenuItem<String>(
                  value: symbol,
                  child: Text(symbol),
                )),
          ],
          onChanged: onSelected,
        );
      },
    );
  }
}

class _BaseFilterDropdown extends StatelessWidget {
  final String? selectedBaseSymbol;
  final void Function(String?) onSelected;

  const _BaseFilterDropdown({
    required this.selectedBaseSymbol,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<CurrenciesProvider>(
      builder: (context, currenciesProvider, _) {
        final options = currenciesProvider.tradableCurrencies;
        final symbols = options.map((c) => c.symbol).toList();
        symbols.sort();
        return AppDropdownField<String>(
          value:
              selectedBaseSymbol != null && symbols.contains(selectedBaseSymbol)
                  ? selectedBaseSymbol
                  : null,
          menuMaxHeight: MediaQuery.of(context).size.height * 0.45,
          labelText: l10n.filterBase,
          hintText: l10n.filterBaseAll,
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(l10n.filterBaseAll),
            ),
            ...symbols.map((symbol) => DropdownMenuItem<String>(
                  value: symbol,
                  child: Text(symbol),
                )),
          ],
          onChanged: onSelected,
        );
      },
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final MarketSortOption selected;
  final void Function(MarketSortOption) onSelected;

  const _SortDropdown({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = <(MarketSortOption, String)>[
      (MarketSortOption.topVolume, l10n.marketsSortTopVolume),
      (MarketSortOption.topGainers, l10n.marketsSortTopGainers),
      (MarketSortOption.topLosers, l10n.marketsSortTopLosers),
      (MarketSortOption.symbolAsc, l10n.marketsSortSymbolAsc),
      (MarketSortOption.symbolDesc, l10n.marketsSortSymbolDesc),
      (MarketSortOption.newest, l10n.marketsSortNewest),
      (MarketSortOption.oldest, l10n.marketsSortOldest),
    ];

    return AppDropdownField<MarketSortOption>(
      value: selected,
      labelText: l10n.marketsSortBy,
      items: options
          .map(
            (item) => DropdownMenuItem<MarketSortOption>(
              value: item.$1,
              child: Text(item.$2),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onSelected(value);
      },
    );
  }
}
