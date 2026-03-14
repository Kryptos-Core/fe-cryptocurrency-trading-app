import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/domain/entities/currency.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/currencies_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/currency_card.dart';
import 'package:crypto_trading_app/screens/currency_detail_screen.dart';

/// Currencies List Screen
/// Displays list of all currencies with search and filter
class CurrenciesListScreen extends StatefulWidget {
  const CurrenciesListScreen({super.key});

  @override
  State<CurrenciesListScreen> createState() => _CurrenciesListScreenState();
}

enum CurrencySortMode {
  topVolume,
  topGainers,
  topLosers,
  alphabet,
}

class _CurrenciesListScreenState extends State<CurrenciesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _includeInactive = false;
  bool _showTradableOnly = false;
  String _searchQuery = '';
  CurrencySortMode _sortMode = CurrencySortMode.topVolume;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrenciesProvider>().fetchCurrencies(refresh: true);
    });
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      context.read<CurrenciesProvider>().fetchCurrencies(
            includeInactive: _includeInactive,
            refresh: true,
          );
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.currencies),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CurrenciesProvider>().fetchCurrencies(refresh: true);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.currenciesSearchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase().trim();
                });
              },
            ),
          ),
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: Text(l10n.currenciesFilterAll),
                  selected: _includeInactive && !_showTradableOnly,
                  onSelected: (selected) {
                    setState(() {
                      _includeInactive = true;
                      _showTradableOnly = false;
                    });
                    context.read<CurrenciesProvider>().fetchCurrencies(
                          includeInactive: true,
                          refresh: true,
                        );
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(l10n.active),
                  selected: !_includeInactive && !_showTradableOnly,
                  onSelected: (selected) {
                    setState(() {
                      _includeInactive = false;
                      _showTradableOnly = false;
                    });
                    context.read<CurrenciesProvider>().fetchCurrencies(
                          includeInactive: false,
                          refresh: true,
                        );
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(l10n.currenciesTradable),
                  selected: _showTradableOnly,
                  onSelected: (selected) {
                    setState(() {
                      _showTradableOnly = selected;
                      _includeInactive = false;
                    });
                    // For tradable, we'll filter client-side for now
                    // Optional: add fetchTradableCurrencies() to CurrenciesProvider using repository.getTradableCurrencies()
                    context.read<CurrenciesProvider>().fetchCurrencies(
                          includeInactive: false,
                          refresh: true,
                        );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortChip(
                    label: l10n.currenciesSortTopVolume,
                    mode: CurrencySortMode.topVolume,
                  ),
                  const SizedBox(width: 8),
                  _buildSortChip(
                    label: l10n.currenciesSortTopGainers,
                    mode: CurrencySortMode.topGainers,
                  ),
                  const SizedBox(width: 8),
                  _buildSortChip(
                    label: l10n.currenciesSortTopLosers,
                    mode: CurrencySortMode.topLosers,
                  ),
                  const SizedBox(width: 8),
                  _buildSortChip(
                    label: l10n.currenciesSortAlphabet,
                    mode: CurrencySortMode.alphabet,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Currencies List
          Expanded(
            child: Consumer<CurrenciesProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.currencies.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.currencies.isEmpty) {
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
                            provider.fetchCurrencies(refresh: true);
                          },
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  );
                }

                // Filter currencies client-side
                var displayedCurrencies = provider.currencies;

                // Apply tradable filter
                if (_showTradableOnly) {
                  displayedCurrencies =
                      displayedCurrencies.where((c) => c.isTradable).toList();
                }

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  displayedCurrencies = displayedCurrencies.where((c) {
                    final symbol = c.symbol.toLowerCase();
                    final name = c.name.toLowerCase();
                    return symbol.contains(_searchQuery) ||
                        name.contains(_searchQuery);
                  }).toList();
                }

                displayedCurrencies = _sortCurrencies(displayedCurrencies);

                // Show "No results" if search/filter returns empty
                if (displayedCurrencies.isEmpty) {
                  if (provider.currencies.isEmpty) {
                    return Center(
                      child: Text(l10n.currenciesNoCurrenciesFound),
                    );
                  } else {
                    return Center(
                      child: Text(l10n.currenciesNoMatchSearch),
                    );
                  }
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await provider.fetchCurrencies(
                      includeInactive: _includeInactive,
                      refresh: true,
                    );
                  },
                  child: ListView.builder(
                    itemCount:
                        displayedCurrencies.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == displayedCurrencies.length) {
                        // Load more indicator
                        if (provider.hasMore) {
                          provider.loadMore();
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }

                      final currency = displayedCurrencies[index];
                      return CurrencyCard(
                        currency: currency,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CurrencyDetailScreen(
                                currencyId: currency.currencyId,
                                initialCurrency: currency,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip({
    required String label,
    required CurrencySortMode mode,
  }) {
    return FilterChip(
      label: Text(label),
      selected: _sortMode == mode,
      onSelected: (selected) {
        if (!selected) return;
        setState(() {
          _sortMode = mode;
        });
      },
    );
  }

  List<Currency> _sortCurrencies(List<Currency> input) {
    final sorted = [...input];

    switch (_sortMode) {
      case CurrencySortMode.topVolume:
        sorted.sort((a, b) =>
            _compareDesc(_parseDouble(a.volume24h), _parseDouble(b.volume24h)));
        break;
      case CurrencySortMode.topGainers:
        sorted.sort((a, b) => _compareDesc(
            _parseDouble(a.priceChangePercent24h),
            _parseDouble(b.priceChangePercent24h)));
        break;
      case CurrencySortMode.topLosers:
        sorted.sort((a, b) => _compareAsc(_parseDouble(a.priceChangePercent24h),
            _parseDouble(b.priceChangePercent24h)));
        break;
      case CurrencySortMode.alphabet:
        sorted.sort((a, b) => a.symbol.compareTo(b.symbol));
        break;
    }

    return sorted;
  }

  int _compareDesc(double? a, double? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return b.compareTo(a);
  }

  int _compareAsc(double? a, double? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }

  double? _parseDouble(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return double.tryParse(value);
  }
}
