import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/presentation/providers/chart_provider.dart';
import 'package:crypto_trading_app/presentation/providers/currencies_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/market_row.dart';
import 'package:crypto_trading_app/screens/market_detail_screen.dart';

/// Markets List Screen
/// Displays list of all market pairs with search (as-you-type) and filters
class MarketsListScreen extends StatefulWidget {
  const MarketsListScreen({super.key});

  @override
  State<MarketsListScreen> createState() => _MarketsListScreenState();
}

class _MarketsListScreenState extends State<MarketsListScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<_MarketSearchBarState> _searchBarKey = GlobalKey<_MarketSearchBarState>();
  bool _isLoadingMore = false;
  bool _fallbackTickersRequested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MarketsProvider>();
      context.read<CurrenciesProvider>().fetchTradableCurrencies();
      provider.fetchMarkets(refresh: true, includeTickers: true);
      provider.fetchAllTickers();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore) {
        final provider = context.read<MarketsProvider>();
        if (provider.hasMore && !provider.isLoading) {
          _isLoadingMore = true;
          provider.loadMore().then((_) {
            _isLoadingMore = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
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
    return Scaffold(
      body: Consumer<MarketsProvider>(
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
              Expanded(
                child: provider.markets.isEmpty
                    ? Center(
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
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          _isLoadingMore = false;
                          _fallbackTickersRequested = false;
                          await provider.refreshKeepingPosition();
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: provider.markets.length +
                              (provider.hasMore && provider.isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == provider.markets.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final market = provider.markets[index];
                            final ticker = tickerByPairId[market.pairId];
                            return MarketRow(
                              market: market,
                              ticker: ticker,
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
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilters(
    BuildContext context,
    MarketsProvider provider,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _MarketSearchBar(
            key: _searchBarKey,
            hintText: l10n.searchMarketsHint,
            initialValue: provider.searchQuery,
            onDebouncedSearch: provider.setSearchQuery,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${l10n.filterQuote}: ',
                style: theme.textTheme.bodyMedium,
              ),
              Expanded(
                child: _QuoteFilterDropdown(
                  selectedQuoteSymbol: provider.filterQuoteSymbol,
                  onSelected: provider.setFilterQuoteSymbol,
                ),
              ),
              if (provider.hasActiveFilter)
                TextButton.icon(
                  onPressed: () {
                    _searchBarKey.currentState?.clear();
                    provider.clearSearchAndFilters();
                  },
                  icon: const Icon(Icons.filter_alt_off, size: 18),
                  label: Text(l10n.clearFilters),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Search bar that owns its controller and debounce so focus is preserved when parent rebuilds.
class _MarketSearchBar extends StatefulWidget {
  final String hintText;
  final String initialValue;
  final void Function(String) onDebouncedSearch;

  const _MarketSearchBar({
    super.key,
    required this.hintText,
    required this.initialValue,
    required this.onDebouncedSearch,
  });

  @override
  State<_MarketSearchBar> createState() => _MarketSearchBarState();
}

class _MarketSearchBarState extends State<_MarketSearchBar> {
  static const _debounceMs = 400;
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant _MarketSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue == '' && _controller.text.isNotEmpty) {
      _controller.clear();
    }
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: _debounceMs), () {
      if (!mounted) return;
      widget.onDebouncedSearch(_controller.text);
    });
  }

  void clear() {
    _controller.clear();
    widget.onDebouncedSearch('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, child) {
        return TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      widget.onDebouncedSearch('');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            isDense: true,
          ),
          textCapitalization: TextCapitalization.characters,
          onSubmitted: widget.onDebouncedSearch,
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
        return DropdownButtonFormField<String>(
          value: selectedQuoteSymbol != null && symbols.contains(selectedQuoteSymbol)
              ? selectedQuoteSymbol
              : null,
          menuMaxHeight: MediaQuery.of(context).size.height * 0.45,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            isDense: true,
          ),
          hint: Text(l10n.filterQuoteAll),
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
