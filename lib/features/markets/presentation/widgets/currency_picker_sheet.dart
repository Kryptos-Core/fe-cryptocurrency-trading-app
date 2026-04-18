import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/services/currency_bookmark_store.dart';
import 'package:crypto_trading_app/features/markets/domain/entities/currency.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/widgets/app_dropdown_field.dart';
import 'package:crypto_trading_app/features/markets/presentation/widgets/market_search_bar.dart';

/// Bottom sheet to pick a currency with search, [AppDropdownField] filter, and
/// optional favorites / recent (same UX pattern as the trading pair picker).
Future<Currency?> showCurrencyPickerBottomSheet(
  BuildContext context, {
  required List<Currency> currencies,
  String? selectedCurrencyId,
  CurrencyBookmarkStore? bookmarkStore,
}) {
  return showModalBottomSheet<Currency>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      final height = MediaQuery.sizeOf(ctx).height * 0.9;
      return SizedBox(
        key: const Key('currency_picker_sheet'),
        height: height,
        child: _CurrencyPickerBody(
          currencies: currencies,
          selectedCurrencyId: selectedCurrencyId,
          bookmarkStore: bookmarkStore,
        ),
      );
    },
  );
}

class _CurrencyPickerBody extends StatefulWidget {
  const _CurrencyPickerBody({
    required this.currencies,
    this.selectedCurrencyId,
    this.bookmarkStore,
  });

  final List<Currency> currencies;
  final String? selectedCurrencyId;
  final CurrencyBookmarkStore? bookmarkStore;

  @override
  State<_CurrencyPickerBody> createState() => _CurrencyPickerBodyState();
}

class _CurrencyPickerBodyState extends State<_CurrencyPickerBody> {
  static const _filterTradable = 'tradable';
  static const _filterNonTradable = 'non_tradable';

  final GlobalKey<MarketSearchBarState> _searchKey =
      GlobalKey<MarketSearchBarState>();

  String _searchQuery = '';
  String? _filterKind;
  List<CurrencyRef> _recentRefs = [];
  List<CurrencyRef> _favoriteRefs = [];

  @override
  void initState() {
    super.initState();
    _reloadBookmarks();
  }

  void _reloadBookmarks() {
    final store = widget.bookmarkStore;
    if (store == null) return;
    _recentRefs = store.recent;
    _favoriteRefs = store.favorites;
  }

  Currency? _currencyForRef(CurrencyRef ref) {
    for (final c in widget.currencies) {
      if (c.currencyId == ref.currencyId) return c;
    }
    return null;
  }

  Future<void> _pick(Currency c) async {
    await widget.bookmarkStore?.addRecent(c);
    if (mounted) Navigator.of(context).pop(c);
  }

  Future<void> _onPickRef(CurrencyRef ref) async {
    final c = _currencyForRef(ref);
    if (c != null) {
      await _pick(c);
    }
  }

  Future<void> _toggleFavorite(Currency c) async {
    final store = widget.bookmarkStore;
    if (store == null) return;
    await store.toggleFavorite(c);
    if (mounted) {
      setState(_reloadBookmarks);
    }
  }

  Future<void> _removeRecent(CurrencyRef r) async {
    await widget.bookmarkStore?.removeRecent(r.currencyId);
    if (mounted) {
      setState(_reloadBookmarks);
    }
  }

  Widget _recentChip(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    CurrencyRef r,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ActionChip(
            label: Text(r.symbol),
            onPressed: () => _onPickRef(r),
          ),
          Positioned(
            top: -2,
            right: -2,
            child: Tooltip(
              message: l10n.currencyPickerRemoveRecent,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () => _removeRecent(r),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.outline
                            .withValues(alpha: 0.35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.12),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: Center(
                        child: Icon(
                          Icons.close,
                          size: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Currency> get _baseList {
    switch (_filterKind) {
      case _filterTradable:
        return widget.currencies.where((c) => c.isTradable).toList();
      case _filterNonTradable:
        return widget.currencies.where((c) => !c.isTradable).toList();
      default:
        return List<Currency>.from(widget.currencies);
    }
  }

  List<Currency> get _filtered {
    final q = _searchQuery.trim().toLowerCase();
    var list = _baseList;
    if (q.isNotEmpty) {
      list = list.where((c) {
        return c.symbol.toLowerCase().contains(q) ||
            c.name.toLowerCase().contains(q);
      }).toList();
    }
    list.sort(
      (a, b) => a.symbol.toLowerCase().compareTo(b.symbol.toLowerCase()),
    );
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final store = widget.bookmarkStore;
    final list = _filtered;

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
                  l10n.selectCurrency,
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
            hintText: l10n.searchCurrenciesHint,
            initialValue: '',
            onDebouncedSearch: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: AppDropdownField<String?>(
            key: const Key('currency_picker_filter'),
            value: _filterKind,
            labelText: l10n.currencyPickerFilter,
            hintText: l10n.currencyPickerFilterAll,
            menuMaxHeight: MediaQuery.sizeOf(context).height * 0.4,
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(l10n.currencyPickerFilterAll),
              ),
              DropdownMenuItem<String?>(
                value: _filterTradable,
                child: Text(l10n.currencyPickerFilterTradable),
              ),
              DropdownMenuItem<String?>(
                value: _filterNonTradable,
                child: Text(l10n.currencyPickerFilterNonTradable),
              ),
            ],
            onChanged: (v) {
              setState(() => _filterKind = v);
            },
          ),
        ),
        if (store != null &&
            (_recentRefs.isNotEmpty || _favoriteRefs.isNotEmpty))
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
                    runSpacing: 8,
                    children: _recentRefs.map((r) {
                      return _recentChip(context, theme, l10n, r);
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        Expanded(
          child: widget.currencies.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.noActiveCurrencies,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : list.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.currencyPickerNoMatches,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final c = list[index];
                        final sel = c.currencyId == widget.selectedCurrencyId;
                        final letter = c.symbol.isNotEmpty
                            ? c.symbol.substring(0, 1).toUpperCase()
                            : '?';
                        final fav = store?.isFavorite(c.currencyId) ?? false;
                        return ListTile(
                          selected: sel,
                          selectedTileColor:
                              theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.35,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.15),
                            child: Text(
                              letter,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            c.symbol,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            c.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: store != null
                              ? IconButton(
                                  icon: Icon(
                                    fav ? Icons.star : Icons.star_border,
                                    color: fav
                                        ? theme.colorScheme.primary
                                        : null,
                                  ),
                                  tooltip: fav
                                      ? l10n.tradingPairRemoveFavorite
                                      : l10n.tradingPairAddFavorite,
                                  onPressed: () => _toggleFavorite(c),
                                )
                              : null,
                          mouseCursor: SystemMouseCursors.click,
                          onTap: () => _pick(c),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
