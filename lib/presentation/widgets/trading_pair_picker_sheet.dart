import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/services/trading_pair_bookmark_store.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/domain/repositories/markets_repository.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/widgets/app_dropdown_field.dart';
import 'package:crypto_trading_app/presentation/widgets/market_row.dart';
import 'package:crypto_trading_app/presentation/widgets/market_search_bar.dart';

/// Opens a searchable bottom sheet to pick a [MarketPair]. Does not use
/// [MarketsProvider] so the Markets tab filters stay untouched.
Future<MarketPair?> showTradingPairPickerBottomSheet(
  BuildContext context, {
  required MarketsRepository marketsRepository,
  TradingPairBookmarkStore? bookmarkStore,
  MarketPair? selected,
}) {
  return showModalBottomSheet<MarketPair>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      final height = MediaQuery.sizeOf(ctx).height * 0.9;
      return SizedBox(
        key: const Key('trading_pair_picker_sheet'),
        height: height,
        child: _TradingPairPickerBody(
          marketsRepository: marketsRepository,
          bookmarkStore: bookmarkStore,
          selected: selected,
        ),
      );
    },
  );
}

class _TradingPairPickerBody extends StatefulWidget {
  const _TradingPairPickerBody({
    required this.marketsRepository,
    this.bookmarkStore,
    this.selected,
  });

  final MarketsRepository marketsRepository;
  final TradingPairBookmarkStore? bookmarkStore;
  final MarketPair? selected;

  @override
  State<_TradingPairPickerBody> createState() => _TradingPairPickerBodyState();
}

class _TradingPairPickerBodyState extends State<_TradingPairPickerBody> {
  static const _pageSize = 40;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey<MarketSearchBarState> _searchKey = GlobalKey<MarketSearchBarState>();

  String _searchQuery = '';
  String? _quoteSymbol;
  final List<MarketPair> _markets = [];
  final Map<String, MarketTicker> _tickerByPairId = {};
  int _page = 1;
  int _total = 0;
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  List<TradingPairRef> _recentRefs = [];
  List<TradingPairRef> _favoriteRefs = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _reloadBookmarks();
    _fetch(refresh: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _reloadBookmarks() {
    final store = widget.bookmarkStore;
    if (store == null) return;
    _recentRefs = store.recent;
    _favoriteRefs = store.favorites;
  }

  Future<void> _fetch({bool refresh = false}) async {
    if (_loading || _loadingMore) return;
    if (refresh) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
        _markets.clear();
        _tickerByPairId.clear();
      });
    } else {
      setState(() {
        _loadingMore = true;
        _error = null;
      });
    }

    final requestPage = refresh ? 1 : _page;
    final result = await widget.marketsRepository.getMarkets(
      page: requestPage,
      limit: _pageSize,
      includeInactive: false,
      includeTickers: true,
      search: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
      quoteSymbol: _quoteSymbol,
      sortBy: 'symbol',
      sortOrder: 'asc',
      fuzzySearch: true,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _error = failure.message;
          _loading = false;
          _loadingMore = false;
        });
      },
      (paginated) {
        final tickers = paginated.tickers ?? [];
        for (final t in tickers) {
          if (t.pairId.isNotEmpty) _tickerByPairId[t.pairId] = t;
        }
        if (paginated.markets.isEmpty && !refresh) {
          _total = _markets.length;
        } else {
          if (refresh) {
            _markets
              ..clear()
              ..addAll(paginated.markets);
          } else {
            _markets.addAll(paginated.markets);
          }
          _total = paginated.total;
          final hasMore = _markets.length < paginated.total &&
              paginated.markets.length >= paginated.limit;
          _page = hasMore ? paginated.page + 1 : requestPage;
        }
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      },
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent * 0.85) {
      if (!_loadingMore &&
          !_loading &&
          _markets.length < _total &&
          _markets.isNotEmpty) {
        _fetch(refresh: false);
      }
    }
  }

  Future<void> _onPickRef(TradingPairRef ref) async {
    final r = await widget.marketsRepository.getMarketById(ref.pairId);
    if (!mounted) return;
    r.fold(
      (_) {},
      (pair) => Navigator.of(context).pop(pair),
    );
  }

  Future<void> _toggleFavorite(MarketPair pair) async {
    final store = widget.bookmarkStore;
    if (store == null) return;
    await store.toggleFavorite(pair);
    if (mounted) {
      setState(_reloadBookmarks);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final store = widget.bookmarkStore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.tradingPairPickerTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: MarketSearchBar(
            key: _searchKey,
            hintText: l10n.searchMarketsHint,
            initialValue: '',
            onDebouncedSearch: (q) {
              _searchQuery = q;
              _fetch(refresh: true);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: AppDropdownField<String?>(
            key: const Key('trading_pair_quote_filter'),
            value: _quoteSymbol,
            labelText: l10n.filterQuote,
            hintText: l10n.filterQuoteAll,
            menuMaxHeight: MediaQuery.sizeOf(context).height * 0.4,
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(l10n.filterQuoteAll),
              ),
              const DropdownMenuItem<String?>(
                value: 'USDT',
                child: Text('USDT'),
              ),
              const DropdownMenuItem<String?>(
                value: 'USDC',
                child: Text('USDC'),
              ),
              const DropdownMenuItem<String?>(
                value: 'TRY',
                child: Text('TRY'),
              ),
            ],
            onChanged: (v) {
              setState(() => _quoteSymbol = v);
              _fetch(refresh: true);
            },
          ),
        ),
        if (store != null && (_recentRefs.isNotEmpty || _favoriteRefs.isNotEmpty))
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_favoriteRefs.isNotEmpty) ...[
                  Text(
                    l10n.tradingPairSectionFavorites,
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _favoriteRefs.map((r) {
                      return ActionChip(
                        label: Text(r.symbol),
                        avatar: Icon(
                          Icons.star,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () => _onPickRef(r),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                ],
                if (_recentRefs.isNotEmpty) ...[
                  Text(
                    l10n.tradingPairSectionRecent,
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _recentRefs.map((r) {
                      return ActionChip(
                        label: Text(r.symbol),
                        onPressed: () => _onPickRef(r),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        if (_error != null && _markets.isEmpty && !_loading)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => _fetch(refresh: true),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Expanded(
            child: _loading && _markets.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount:
                        _markets.length + (_loadingMore && _markets.isNotEmpty ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _markets.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final m = _markets[index];
                      final ticker = _tickerByPairId[m.pairId];
                      final isSel = widget.selected?.pairId == m.pairId;
                      final fav = store?.isFavorite(m.pairId) ?? false;
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: isSel
                              ? theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.35)
                              : null,
                        ),
                        child: MarketRow(
                          market: m,
                          ticker: ticker,
                          onTap: () => Navigator.of(context).pop(m),
                          onFavoriteTap: store != null
                              ? () => _toggleFavorite(m)
                              : null,
                          isFavorite: fav,
                          favoriteTooltip: store != null
                              ? (fav
                                  ? l10n.tradingPairRemoveFavorite
                                  : l10n.tradingPairAddFavorite)
                              : null,
                        ),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}
