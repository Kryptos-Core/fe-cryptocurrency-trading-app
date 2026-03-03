import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/presentation/providers/wallets_provider.dart';
import 'package:crypto_trading_app/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/wallet_card.dart';
import 'package:crypto_trading_app/presentation/widgets/market_row.dart';
import 'package:crypto_trading_app/screens/wallets_overview_screen.dart';
import 'package:crypto_trading_app/screens/markets_list_screen.dart';
import 'package:crypto_trading_app/screens/market_detail_screen.dart';

/// Dashboard Screen - Home tab
/// Shows portfolio overview, top markets, and quick stats
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load data for dashboard
      context.read<WalletsProvider>().fetchWallets(refresh: true);
      context.read<MarketsProvider>().fetchMarkets(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<WalletsProvider>().fetchWallets(refresh: true),
            context.read<MarketsProvider>().fetchMarkets(refresh: true),
          ]);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Portfolio Summary Card
              _buildPortfolioCard(),
              const SizedBox(height: 24),
              
              // Top Markets Section
              _buildSectionHeader(
                title: 'Top Markets',
                onSeeAll: () {
                  // Navigate to markets list
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MarketsListScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildTopMarkets(),
              const SizedBox(height: 24),
              
              // Wallets Summary Section
              _buildSectionHeader(
                title: 'My Wallets',
                onSeeAll: () {
                  // Navigate to wallets overview
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WalletsOverviewScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildWalletsSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioCard() {
    return Consumer<WalletsProvider>(
      builder: (context, provider, child) {
        final totalValue = provider.totalPortfolioValue;
        
        return Card(
          elevation: 4,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Portfolio Value',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${totalValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'USDT',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem('Wallets', '${provider.wallets.length}'),
                    _buildStatItem('Active', '${provider.wallets.where((w) => w.hasBalance).length}'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({required String title, VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('See All'),
          ),
      ],
    );
  }

  Widget _buildTopMarkets() {
    return Consumer<MarketsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.markets.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.markets.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No markets available'),
            ),
          );
        }

        // Show top 3 markets
        final topMarkets = provider.markets.take(3).toList();

        return Column(
          children: topMarkets.map((market) {
            return MarketRow(
              market: market,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MarketDetailScreen(
                      pairId: market.pairId,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildWalletsSummary() {
    return Consumer<WalletsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.wallets.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.wallets.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No wallets found'),
            ),
          );
        }

        // Show top 3 wallets with balance
        final topWallets = provider.wallets
            .where((w) => w.hasBalance)
            .take(3)
            .toList();

        if (topWallets.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No wallets with balance'),
            ),
          );
        }

        return Column(
          children: topWallets.map((wallet) {
            return WalletCard(
              wallet: wallet,
              usdValue: null,
            );
          }).toList(),
        );
      },
    );
  }
}
