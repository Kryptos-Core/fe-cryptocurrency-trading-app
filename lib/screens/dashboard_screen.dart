import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/presentation/providers/dashboard_provider.dart';
import 'package:crypto_trading_app/presentation/providers/chart_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/wallet_card.dart';
import 'package:crypto_trading_app/presentation/widgets/market_row.dart';
import 'package:crypto_trading_app/screens/wallets_overview_screen.dart';
import 'package:crypto_trading_app/screens/markets_list_screen.dart';
import 'package:crypto_trading_app/screens/market_detail_screen.dart';

/// Dashboard Screen — Home tab.
///
/// Data: DashboardProvider (REST initial load + WS live updates every 5s).
/// Sections:
///   1. Portfolio Summary card — total USDT value, wallet counts
///   2. Top Markets — 10 pairs sorted by 24h volume, with live tickers
///   3. My Wallets — top 3 wallets with balance, with estimated USD value
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
      context.read<DashboardProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<DashboardProvider>().refresh(force: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPortfolioCard(),
              const SizedBox(height: 24),
              _buildSectionHeader(
                title: 'Top Markets',
                onSeeAll: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MarketsListScreen(showAppBar: true),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildTopMarkets(),
              const SizedBox(height: 24),
              _buildSectionHeader(
                title: 'My Wallets',
                onSeeAll: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WalletsOverviewScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildWalletsSummary(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Portfolio Card ────────────────────────────────────────────────────────

  Widget _buildPortfolioCard() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        final portfolioTotal = provider.portfolioTotal;
        final formattedTotal = FormatUtils.formatPortfolioTotal(portfolioTotal);

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
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                provider.isLoading && !provider.hasData
                    ? const SizedBox(
                        height: 44,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white54,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : Text(
                        formattedTotal,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                const SizedBox(height: 4),
                const Text(
                  'USDT',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem('Wallets', '${provider.walletCount}'),
                    _buildStatItem('Active', '${provider.activeWalletCount}'),
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
          style: const TextStyle(fontSize: 12, color: Colors.white70),
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

  // ── Section Header ────────────────────────────────────────────────────────

  Widget _buildSectionHeader({required String title, VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('See All')),
      ],
    );
  }

  // ── Top Markets ───────────────────────────────────────────────────────────

  Widget _buildTopMarkets() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && !provider.hasData) {
          return const _LoadingPlaceholder();
        }

        final markets = provider.topMarkets;
        if (markets.isEmpty) {
          return const _EmptyState(message: 'No markets available');
        }

        // Show top 3 for dashboard overview
        final displayMarkets = markets.take(3).toList();

        return Column(
          children: displayMarkets.map((market) {
            final ticker = provider.tickerFor(market.symbol);
            return MarketRow(
              market: market,
              ticker: ticker,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => sl<ChartProvider>(),
                    child: MarketDetailScreen(pairId: market.pairId),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ── My Wallets ────────────────────────────────────────────────────────────

  Widget _buildWalletsSummary() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && !provider.hasData) {
          return const _LoadingPlaceholder();
        }

        final walletItems = provider.summary.wallets
            .where((w) => (double.tryParse(w.total) ?? 0) > 0)
            .take(3)
            .toList();

        if (walletItems.isEmpty) {
          return const _EmptyState(
            message: 'No funded wallets yet.\nDeposit or trade to see balances here.',
          );
        }

        return Column(
          children: walletItems.map((item) {
            final usdValue = provider.usdValueFor(item.currencySymbol);
            return WalletCard(
              wallet: item.toWallet(),
              usdValue: usdValue > 0 ? usdValue : null,
            );
          }).toList(),
        );
      },
    );
  }
}

// ── Private Helpers ───────────────────────────────────────────────────────────

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          style: TextStyle(color: Colors.grey.shade500),
        ),
      ),
    );
  }
}
