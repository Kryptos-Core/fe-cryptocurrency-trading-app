import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class _CurrenciesListScreenState extends State<CurrenciesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _includeInactive = false;
  bool _showTradableOnly = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrenciesProvider>().fetchCurrencies(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currencies'),
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
                hintText: 'Search currencies...',
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
                  label: const Text('All'),
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
                  label: const Text('Active'),
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
                  label: const Text('Tradable'),
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
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Filter currencies client-side
                var displayedCurrencies = provider.currencies;
                
                // Apply tradable filter
                if (_showTradableOnly) {
                  displayedCurrencies = displayedCurrencies
                      .where((c) => c.isTradable)
                      .toList();
                }
                
                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  displayedCurrencies = displayedCurrencies
                      .where((c) {
                        final symbol = c.symbol.toLowerCase();
                        final name = c.name.toLowerCase();
                        return symbol.contains(_searchQuery) ||
                            name.contains(_searchQuery);
                      })
                      .toList();
                }

                // Show "No results" if search/filter returns empty
                if (displayedCurrencies.isEmpty) {
                  if (provider.currencies.isEmpty) {
                    return const Center(
                      child: Text('No currencies found'),
                    );
                  } else {
                    return const Center(
                      child: Text('No currencies match your search'),
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
                    itemCount: displayedCurrencies.length + (provider.hasMore ? 1 : 0),
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
}
