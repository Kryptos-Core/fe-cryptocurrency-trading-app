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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MarketsProvider>();
      // Load markets and tickers together; list is shown only when we have tickers
      // so we never show a list full of zeros (best practice).
      provider.fetchMarkets(refresh: true);
      provider.fetchAllTickers();
    });

    // Listen to scroll events to load more when near bottom
    _scrollController.addListener(_onScroll);
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

          // Best practice: only show list when we have ticker data, so we don't show zeros
          // for every row (tickers load after markets). When loading more, allTickers
          // already covers all pairs from GET /markets/tickers/all.
          if (provider.allTickers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading prices...'),
                ],
              ),
            );
          }

          final tickerByPairId = {
            for (final t in provider.allTickers) t.pairId: t
          };

          return RefreshIndicator(
            onRefresh: () async {
              _isLoadingMore = false;
              await Future.wait([
                provider.fetchMarkets(refresh: true),
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
