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
      provider.fetchMarkets(refresh: true);
      // Tab Thị trường: GET /markets/tickers/all – giá, % đổi cho mọi pair active
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

          final tickerByPairId = {
            for (final t in provider.allTickers) t.pairId: t
          };

          return RefreshIndicator(
            onRefresh: () async {
              _isLoadingMore = false;
              await provider.fetchMarkets(refresh: true);
              await provider.fetchAllTickers();
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
