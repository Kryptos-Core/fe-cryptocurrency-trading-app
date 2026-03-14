import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/presentation/providers/blockchain_provider.dart';
import 'package:crypto_trading_app/presentation/screens/blockchain/linked_wallets_screen.dart';
import 'package:crypto_trading_app/presentation/screens/blockchain/onchain_deposit_screen.dart';
import 'package:crypto_trading_app/presentation/screens/blockchain/onchain_withdraw_screen.dart';

class BlockchainHubScreen extends StatefulWidget {
  const BlockchainHubScreen({super.key});

  @override
  State<BlockchainHubScreen> createState() => _BlockchainHubScreenState();
}

class _BlockchainHubScreenState extends State<BlockchainHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlockchainProvider>().fetchLinkedWallets();
      context.read<BlockchainProvider>().fetchRecentTransactions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('On-chain Wallets'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Linked Wallets'),
            Tab(text: 'Deposit'),
            Tab(text: 'Withdraw'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final provider = context.read<BlockchainProvider>();
              await provider.fetchLinkedWallets();
              await provider.fetchRecentTransactions();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LinkedWalletsScreen(),
          OnchainDepositScreen(),
          OnchainWithdrawScreen(),
        ],
      ),
    );
  }
}
