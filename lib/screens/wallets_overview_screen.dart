import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/presentation/providers/wallets_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/wallet_card.dart';
import 'package:crypto_trading_app/screens/wallet_detail_screen.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallets'),
        automaticallyImplyLeading: false, // Remove back button when in bottom nav
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
                // Wallets List
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.wallets.length,
                    itemBuilder: (context, index) {
                      final wallet = provider.wallets[index];
                      // Calculate USD value (mock)
                      final rates = {'BTC': 45000.0, 'ETH': 2850.0, 'USDT': 1.0, 'BNB': 350.0};
                      final rate = rates[wallet.currency.symbol] ?? 1.0;
                      final total = double.tryParse(wallet.total) ?? 0;
                      final usdValue = total * rate;

                      return WalletCard(
                        wallet: wallet,
                        usdValue: usdValue,
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
