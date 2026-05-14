import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/constants/platform_cash_currency.dart';
import 'package:crypto_trading_app/core/responsive/app_responsive.dart';
import 'package:crypto_trading_app/features/wallets/domain/entities/wallet.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:crypto_trading_app/features/wallets/presentation/providers/wallets_provider.dart';
import 'package:crypto_trading_app/features/wallets/presentation/widgets/wallet_card.dart';
import 'package:crypto_trading_app/features/wallets/presentation/screens/wallet_detail_screen.dart';
import 'package:crypto_trading_app/features/deposits/presentation/screens/deposits_screen.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

/// Wallets Overview Screen
///
/// Phân tách rõ ràng 2 nhóm ví:
///  1. Ví Tiền (USDT) — nhận toàn bộ tiền nạp (PayOS, TronLink, MetaMask)
///  2. Tài sản — coin sở hữu từ giao dịch (BTC, ETH, TRX...)
///
/// Tổng danh mục (_PortfolioHeader): [DashboardProvider.portfolioTotal] (GET /dashboard),
/// cùng nguồn với tab Ví.
class WalletsOverviewScreen extends StatefulWidget {
  const WalletsOverviewScreen({super.key});

  @override
  State<WalletsOverviewScreen> createState() => _WalletsOverviewScreenState();
}

class _WalletsOverviewScreenState extends State<WalletsOverviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().refresh(force: true);
      context.read<WalletsProvider>().fetchWallets(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myWallets),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardProvider>().refresh(force: true);
              context.read<WalletsProvider>().fetchWallets(refresh: true);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= AppBreakpoints.compact;
          return _buildBody(context, l10n, isWide);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n, bool isWide) {
    return Consumer2<WalletsProvider, DashboardProvider>(
      builder: (context, provider, dashboard, child) {
        if (provider.isLoading && provider.wallets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.wallets.isEmpty) {
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
                  onPressed: () => provider.fetchWallets(refresh: true),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          );
        }

        if (provider.wallets.isEmpty) {
          return Center(child: Text(l10n.noWalletsFound));
        }

        // Phân nhóm: Ví Tiền (USDT) vs Tài sản Coin
        final cashWallets = provider.wallets
            .where((w) =>
                w.currency.symbol.toUpperCase() ==
                kDefaultPlatformCashCurrencySymbol)
            .toList();
        final coinWallets = provider.wallets
            .where((w) =>
                w.currency.symbol.toUpperCase() !=
                kDefaultPlatformCashCurrencySymbol)
            .toList();

        return RefreshIndicator(
          onRefresh: () async {
            await dashboard.refresh(force: true);
            await provider.fetchWallets(refresh: true);
          },
          child: CustomScrollView(
            slivers: [
              // Tổng danh mục
              SliverToBoxAdapter(
                child: _PortfolioHeader(
                  totalValue: dashboard.portfolioTotal,
                  l10n: l10n,
                  isWide: isWide,
                ),
              ),

              // Nút nạp tiền
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 24 : 16,
                    vertical: 8,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DepositsScreen()),
                      );
                    },
                    icon: const Icon(Icons.account_balance_wallet),
                    label: Text(l10n.payosTopupVnd),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              // ── Section: Ví Tiền ──
              if (cashWallets.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _WalletSectionHeader(
                    title: l10n.cashWalletSectionTitle,
                    subtitle: l10n.cashWalletSectionSubtitle,
                    icon: Icons.account_balance_wallet_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (isWide)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 120,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildWalletItem(
                            context, cashWallets[index],
                            isCash: true),
                        childCount: cashWallets.length,
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildWalletItem(
                          context, cashWallets[index],
                          isCash: true),
                      childCount: cashWallets.length,
                    ),
                  ),
              ],

              // ── Section: Tài sản Coin ──
              if (coinWallets.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _WalletSectionHeader(
                    title: l10n.coinAssetsSectionTitle,
                    subtitle: l10n.coinAssetsSectionSubtitle,
                    icon: Icons.currency_bitcoin,
                    color: Colors.orange.shade700,
                  ),
                ),
                if (isWide)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 120,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildWalletItem(
                            context, coinWallets[index],
                            isCash: false),
                        childCount: coinWallets.length,
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildWalletItem(
                          context, coinWallets[index],
                          isCash: false),
                      childCount: coinWallets.length,
                    ),
                  ),
              ],

              // Padding cuối
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalletItem(BuildContext context, Wallet wallet,
      {required bool isCash}) {
    return WalletCard(
      wallet: wallet,
      usdValue: null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WalletDetailScreen(walletId: wallet.walletId),
          ),
        );
      },
    );
  }
}

/// Header tổng danh mục
class _PortfolioHeader extends StatelessWidget {
  final double totalValue;
  final AppLocalizations l10n;
  final bool isWide;

  const _PortfolioHeader({
    required this.totalValue,
    required this.l10n,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 32 : 24,
        vertical: isWide ? 28 : 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(20),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.primary.withAlpha(40),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            l10n.totalPortfolioValue,
            style: TextStyle(
              fontSize: isWide ? 15 : 13,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: isWide ? 8 : 6),
          Text(
            '${FormatUtils.formatQuoteAmount(totalValue)} USDT',
            style: TextStyle(
              fontSize: isWide ? 36 : 30,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Header của từng section (Ví Tiền / Tài sản)
class _WalletSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _WalletSectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
