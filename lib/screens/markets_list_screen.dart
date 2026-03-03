import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/presentation/providers/chart_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/market_row.dart';
import 'package:crypto_trading_app/screens/market_detail_screen.dart';

/// Markets List Screen
/// Displays list of all market pairs
class MarketsListScreen extends StatefulWidget {
  const MarketsListScreen({super.key});

  @override
  State<MarketsListScreen> createState() => _MarketsListScreenState();
}

class _MarketsListScreenState extends State<MarketsListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _fallbackTickersRequested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MarketsProvider>();
      // Load pairs and tickers: GET /markets?includeTickers=true and GET /markets/tickers/all (so we get prices even if one source fails).
      provider.fetchMarkets(refresh: true, includeTickers: true);
      provider.fetchAllTickers();
    });

    // Listen to scroll events to load more when near bottom
    _scrollController.addListener(_onScroll);
  }

  /// When BE returns empty/zero tickers (e.g. /markets/tickers/all not populated), fetch per-pair (GET /markets/:id/ticker) for first page after a short delay.
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
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more when scrolled to 80% of the list
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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

          if (provider.markets.isEmpty) {
            return Center(
              child: Text(l10n.noMarkets),
            );
          }

          // Fallback: if we have markets but no real ticker data (all 0), fetch per-pair tickers once.
          _maybeFetchTickersFallback(provider);

          // Build map pairId -> ticker; rows without a ticker show "—" (data loading/missing).
          final tickerByPairId = {
            for (final t in provider.allTickers)
              if (t.pairId.isNotEmpty) t.pairId: t
          };

          return RefreshIndicator(
            onRefresh: () async {
              _isLoadingMore = false;
              _fallbackTickersRequested = false;
              await Future.wait([
                provider.fetchMarkets(refresh: true, includeTickers: true),
                provider.fetchAllTickers(),
              ]);
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: provider.markets.length +
                  (provider.hasMore && provider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator at the end if loading more
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
          );
        },
      ),
    );
  }
}
