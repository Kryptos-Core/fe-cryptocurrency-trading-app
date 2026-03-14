import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/presentation/providers/wallets_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/wallet_card.dart';
import 'package:crypto_trading_app/screens/wallet_detail_screen.dart';
import 'package:crypto_trading_app/screens/deposits_screen.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';

/// Wallets Overview Screen
/// Displays all user wallets with total portfolio value
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
      context.read<WalletsProvider>().fetchWallets(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallets'),
        automaticallyImplyLeading:
            false, // Remove back button when in bottom nav
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WalletsProvider>().fetchWallets(refresh: true);
            },
          ),
        ],
      ),
      body: Consumer<WalletsProvider>(
        builder: (context, provider, child) {
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
                    onPressed: () {
                      provider.fetchWallets(refresh: true);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.wallets.isEmpty) {
            return const Center(
              child: Text('No wallets found'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchWallets(refresh: true);
            },
            child: Column(
              children: [
                // Total Portfolio Value
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  color: Colors.blue.shade50,
                  child: Column(
                    children: [
                      const Text(
                        'Total Portfolio Value',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${provider.totalPortfolioValue.toStringAsFixed(2)} USDT',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                // Quick Actions
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
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
                    ],
                  ),
                ),
                const Divider(),
                // Wallets List
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.wallets.length,
                    itemBuilder: (context, index) {
                      final wallet = provider.wallets[index];
                      return WalletCard(
                        wallet: wallet,
                        usdValue: null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WalletDetailScreen(
                                walletId: wallet.walletId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
