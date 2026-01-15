import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
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
  bool? _filterIsActive;
  bool? _filterIsTradable;

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
                // Implement search logic
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
                  selected: _filterIsActive == null && _filterIsTradable == null,
                  onSelected: (selected) {
                    setState(() {
                      _filterIsActive = null;
                      _filterIsTradable = null;
                    });
                    context.read<CurrenciesProvider>().fetchCurrencies(
                          isActive: null,
                          isTradable: null,
                          refresh: true,
                        );
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Active'),
                  selected: _filterIsActive == true,
                  onSelected: (selected) {
                    setState(() {
                      _filterIsActive = selected ? true : null;
                    });
                    context.read<CurrenciesProvider>().fetchCurrencies(
                          isActive: _filterIsActive,
                          refresh: true,
                        );
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Tradable'),
                  selected: _filterIsTradable == true,
                  onSelected: (selected) {
                    setState(() {
                      _filterIsTradable = selected ? true : null;
                    });
                    context.read<CurrenciesProvider>().fetchCurrencies(
                          isTradable: _filterIsTradable,
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

                if (provider.currencies.isEmpty) {
                  return const Center(
                    child: Text('No currencies found'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await provider.fetchCurrencies(refresh: true);
                  },
                  child: ListView.builder(
                    itemCount: provider.currencies.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.currencies.length) {
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

                      final currency = provider.currencies[index];
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
