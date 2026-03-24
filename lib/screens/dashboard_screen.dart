import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/presentation/providers/dashboard_provider.dart';
import 'package:crypto_trading_app/presentation/providers/chart_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/wallet_card.dart';
import 'package:crypto_trading_app/presentation/widgets/market_row.dart';
import 'package:crypto_trading_app/screens/wallets_overview_screen.dart';
import 'package:crypto_trading_app/screens/markets_list_screen.dart';
import 'package:crypto_trading_app/screens/market_detail_screen.dart';

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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<DashboardProvider>().refresh(force: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPortfolioCard(l10n),
              const SizedBox(height: 16),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  if (!auth.canViewOpsDashboard) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBankProvidersHealthCard(context, l10n),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
              _buildSectionHeader(
                title: l10n.dashboardTopMarkets,
                seeAllLabel: l10n.dashboardSeeAll,
                onSeeAll: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MarketsListScreen(showAppBar: true),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildTopMarkets(l10n),
              const SizedBox(height: 24),
              _buildSectionHeader(
                title: l10n.dashboardMyWallets,
                seeAllLabel: l10n.dashboardSeeAll,
                onSeeAll: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WalletsOverviewScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildWalletsSummary(l10n),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioCard(AppLocalizations l10n) {
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
                Text(
                  l10n.dashboardTotalPortfolioValue,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
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
                    _buildStatItem(l10n.dashboardWallets, '${provider.walletCount}'),
                    _buildStatItem(l10n.dashboardActive, '${provider.activeWalletCount}'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Probe nội bộ: GET [ApiConstants.fiatWithdrawalsProvidersHealth] (đồng bộ với pull-to-refresh).
  Widget _buildBankProvidersHealthCard(BuildContext context, AppLocalizations l10n) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        final scheme = Theme.of(context).colorScheme;
        if (provider.bankProvidersHealthLoading && provider.bankProvidersHealth == null) {
          return Card(
            child: ListTile(
              leading: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              title: Text(l10n.dashboardBankProvidersHealthTitle),
              subtitle: Text(l10n.dashboardBankProvidersHealthLoading),
            ),
          );
        }
        if (provider.bankProvidersHealthError != null && provider.bankProvidersHealth == null) {
          return Card(
            child: ListTile(
              leading: Icon(Icons.cloud_off_outlined, color: scheme.error),
              title: Text(l10n.dashboardBankProvidersHealthTitle),
              subtitle: Text(l10n.dashboardBankProvidersHealthCouldNotCheck),
            ),
          );
        }
        final raw = provider.bankProvidersHealth;
        if (raw == null) {
          return const SizedBox.shrink();
        }
        final overallOk = raw['ok'] == true;
        final checkedAt = raw['checkedAt']?.toString() ?? '';
        final list = raw['providers'];
        final rows = list is List ? list.whereType<Map>().toList() : <Map<dynamic, dynamic>>[];

        return Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      overallOk ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                      color: overallOk ? scheme.primary : scheme.error,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.dashboardBankProvidersHealthTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                    if (provider.bankProvidersHealthLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  overallOk
                      ? l10n.dashboardBankProvidersHealthAllOperational
                      : l10n.dashboardBankProvidersHealthDegraded,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (checkedAt.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    checkedAt,
                    style: TextStyle(fontSize: 11, color: scheme.outline),
                  ),
                ],
                if (rows.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: rows.map((m) {
                      final id = m['id']?.toString() ?? '?';
                      final ok = m['ok'] == true;
                      final ms = m['latencyMs'];
                      final latency = ms is int ? ms : int.tryParse('$ms') ?? 0;
                      final via = m['checkedVia']?.toString() ?? '';
                      return Chip(
                        avatar: Icon(
                          ok ? Icons.circle : Icons.circle_outlined,
                          size: 12,
                          color: ok ? Colors.green : scheme.error,
                        ),
                        label: Text(
                          '$id · ${l10n.dashboardBankProvidersHealthMs(latency)}${via.isNotEmpty ? ' · $via' : ''}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
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
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String seeAllLabel,
    VoidCallback? onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: Text(seeAllLabel)),
      ],
    );
  }

  Widget _buildTopMarkets(AppLocalizations l10n) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && !provider.hasData) {
          return const _LoadingPlaceholder();
        }

        final markets = provider.topMarkets;
        if (markets.isEmpty) {
          return _EmptyState(message: l10n.dashboardNoMarketsAvailable);
        }

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

  Widget _buildWalletsSummary(AppLocalizations l10n) {
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
          return _EmptyState(message: l10n.dashboardNoFundedWallets);
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
        child: Text(message, style: TextStyle(color: Colors.grey.shade500)),
      ),
    );
  }
}
